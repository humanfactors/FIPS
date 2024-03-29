
#' Parse Sleep Times to FIPS_df
#'
#' This function parses a standardised sleeptime dataframe into the full FIPS format, ready for simulation and modelling.
#' The sleeptime format requires a sleep.id column (vector), a series of sleep times, and a series of corresponding wake times.
#' This format is the simplest to work with for human-readable or human-generated dataframes. See [parse_sleepwake_sequence] for
#' binary input methods.
#'
#' It is crucial that that following conditions are met for all arguments:
#' * Ensure that all specified datetimes for all datetime arguments are in an identical timezone.
#' * Ensure that the minimum sleep start time is >= series.start
#' * Ensure that the maximum wake time (sleep end) is <= series.end
#' * Ensure that each sleep start is < the corresponding sleep.end
#'
#' @param sleeptimes A dataframe in the sleep time format (see help for more info)
#' @param series.start A POSIXct object indicating the start datetime of the simulation (i.e., pre-first sleep waking duration)
#' @param series.end  A POSIXct object indicating the end datetime of the simulation
#' @param roundvalue An whole numeric (integer) value to round the sleep times to in minutes (`default = 5 minutes`). Second precision not supported.
#' @param sleep.start.col [string] The column in the dataframe containing the sleep start times
#' @param sleep.end.col [string] The column name in the dataframe containing the sleep end times
#' @param sleep.id.col [string] A column name specifying the sleep id sequence (i.e., `1:n()`)
#'
#' @examples
#'
#'  my_sleeptimes = tibble::tribble(
#'    ~sleep.id,          ~sleep.start,            ~sleep.end,
#'    1L, "2018-05-21 01:00:00", "2018-05-21 07:00:00",
#'    2L, "2018-05-21 23:00:00", "2018-05-22 04:00:00",
#'    3L, "2018-05-23 01:00:00", "2018-05-23 09:00:00") %>%
#'    dplyr::mutate(
#'      sleep.start = lubridate::ymd_hms(sleep.start),
#'      sleep.end = lubridate::ymd_hms(sleep.end))
#'
#'  my_simstart = lubridate::ymd_hms('2018-05-20 22:00:00')
#'  my_simend   = lubridate::ymd_hms('2018-05-23 10:00:00')
#'
#'  my_FIPS_df = parse_sleeptimes(
#'    sleeptimes = my_sleeptimes,
#'    series.start = my_simstart,
#'    series.end = my_simend,
#'    sleep.start.col = "sleep.start",
#'    sleep.end.col = "sleep.end",
#'    sleep.id.col = "sleep.id",
#'    roundvalue = 5)
#'
#' @seealso
#' For binary input parsing see: [parse_sleepwake_sequence]
#'
#' @return FIPS_df
#'
#' @export
#' @md
#'
#' @importFrom rlang := .data
parse_sleeptimes <- function(sleeptimes, series.start, series.end,
                             roundvalue = 5, sleep.start.col, sleep.end.col, sleep.id.col) {

  # Assert all colnames specified are actually in sleeptimes
  valid_names = checkmate::check_names(
    names(sleeptimes), permutation.of = c(sleep.id.col, sleep.start.col, sleep.end.col), what = "colnames")

  # Let's give a very useful message for this one.
  if(valid_names != T) {
    stop("At least one of the column strings you have specified does not exist in the sleeptimes dataframe. ",
         valid_names)}

  # Assert that series.start <= min(sleep.start.col) & length 1 & is a datetime & same timezones
  checkmate::assert_posixct(series.start, upper = min(sleeptimes[[sleep.start.col]]),
                            len = 1, .var.name = "series start datetime")
  # Assert that simulation end time >= max(sleep.end.col) & length 1 & is a datetime & same timezones
  checkmate::assert_posixct(series.end, lower = max(sleeptimes[[sleep.end.col]]),
                            len = 1, .var.name = "series end datetime")
  # Assert all sleep ends are less than simulation end times
  checkmate::assert_posixct(sleeptimes[[sleep.end.col]], upper = series.end, .var.name = "sleep.end datetimes")
  # Assert all sleep start times are less than sleep end times
  checkmate::assert_true(all(sleeptimes[[sleep.start.col]] < sleeptimes[[sleep.end.col]]))
  # Assert that ALL sleep end times <= series.end & all are a datetime & same timezone
  checkmate::assert_posixct(sleeptimes[[sleep.start.col]], lower = series.start, .var.name = "sleep.start datetimes")

  # roundvalue checks for whole number, as second precision not supported
  if(roundvalue < 1) stop("roundvalue must be a whole number > 1. FIPS does not support second-level precision")
  if(!(roundvalue%%1==0)) {
    # Print warning
    warning(paste("roundvalue must be a whole number > 1. FIPS does not support second-level precision.",
                  "User set round value of", roundvalue, "now set to", round(roundvalue)))
    # round userinput
    roundvalue = round(roundvalue)}



  # Now rename the user supplied sleeptime columns to "sleep.id", "sleep.start", and "sleep.end".
  sleeptimes = sleeptimes %>%
    dplyr::rename("sleep.id" := !!sym(sleep.id.col),
                  "sleep.start" := !!sym(sleep.start.col),
                  "sleep.end" := !!sym(sleep.end.col))

  # Round sleep and wake times to the desired epoch value
  rounded.sleeptimes <- sleeptimes %>%
    round_times("sleep.start", round_by = roundvalue) %>%
    round_times("sleep.end", round_by = roundvalue)

  # This makes the end of the sleep period occur 5 mins prior so that wake period starts at correct epoch
  rounded.sleeptimes <- rounded.sleeptimes %>%
    dplyr::mutate(sleep.end = .data$sleep.end - lubridate::minutes(roundvalue))

  # Assign minimum sleep start
  minimum.sleepstart = min(rounded.sleeptimes[["sleep.start"]])
  maximum.sleepend = max(rounded.sleeptimes[["sleep.end"]])

  # Now expand out the series of sleep wake times
  processed.sleeptimes <- expand_sleep_series(rounded.sleeptimes, expand_by = roundvalue)

  presleep.times <- NULL
  postwake.times <- NULL

  if(series.start < minimum.sleepstart) {
    presleep.times <- generate_presleep_times(series.start, minimum.sleepstart, roundvalue)
  }
  if(series.end > maximum.sleepend) {
    postwake.times <- generate_postwake_times(series.end, maximum.sleepend, roundvalue)
  }

  joined.times <- dplyr::bind_rows(presleep.times, processed.sleeptimes) %>%
    dplyr::bind_rows(postwake.times) %>%
    dplyr::mutate(wake_status_int = as.integer(.data$wake_status)) %>%
    dplyr::mutate(change_point = change_points(.data$wake_status_int)) %>%
    dplyr::mutate(switch_direction = status_dir(.data$wake_status_int, .data$change_point)) %>%
    dplyr::mutate(status_duration = time_in_status(.data$wake_status, roundvalue)) %>%
    dplyr::mutate(total_prev = shifted_time_status(.data$wake_status, .data$change_point, roundvalue)) %>%
    generate_decimal_timeunits("datetime")

  return(as_FIPS_df(joined.times))
}

#' @export
#' @rdname parse_sleeptimes
sleeptimes_to_FIPSdf = parse_sleeptimes


#' Fill pre-observation wake times
#'
#' The first sleep is unlikely to also be the start of the mission simulation
#' Thus, this function fills the start of the tibble with the all times between
#' The mission start time and the first instance of sleep, intervaled by X minutes
#'
#' @param simulationstart start of simulation
#' @param firstsleep first sleep in the sleep dataframe
#' @param expand_by expand
#' @return returns expanded tibble containing sleep.id = NA (due to waking) and wake_status = T
#' @keywords internal
generate_presleep_times <- function(simulationstart, firstsleep, expand_by = 5) {
    if (simulationstart >= firstsleep)
      stop("[Developer] Simulation Start must before first sleep if using this function")
    emins = paste(expand_by, "mins")
    tibble::tibble(
      datetime = seq(simulationstart, firstsleep - lubridate::minutes(expand_by), by = emins),
      sleep.id = NA,
      wake_status = T
    )
}

#' Fill post-observation wake times
#'
#' The last wake moment is unlikely to also be the end of the series.
#' This function fills constructs a tibble with the all times between
#' the final wake episode and the end of the series, intervaled by `expand_by` minutes
#'
#' @param simulationend start of simulation
#' @param lastwake first sleep in the sleep dataframe
#' @param expand_by expand value
#'
#' @return returns expanded tibble containing sleep.id = NA (due to waking) and wake_status = T
#' @keywords internal
#' @importFrom tibble tibble
generate_postwake_times <- function(simulationend, lastwake, expand_by = 5) {
  if (simulationend <= lastwake)
    stop("[Developer] Simulation end must after last sleep if using this function")
  emins = paste(expand_by, "mins")
  tibble::tibble(
    datetime = seq(lastwake + lubridate::minutes(expand_by), simulationend, by = emins),
    sleep.id = NA,
    wake_status = T
  )
}


#' Round times by column
#'
#' @param .stdata The sleeptimes dataframe
#' @param colname the column required to be rounded
#' @param round_by Amount (in minutes) to round sleep times to
#'
#' @return The sleep dataframe with all sleep.start and sleep.end rounded to X minute interval
#' @importFrom dplyr mutate
#' @importFrom lubridate round_date
#'
#'
#' @export
round_times <- function(.stdata, colname, round_by = 5) {
  if(round_by < 5) warning("Rounding less than 5 will result in an excessively large dataframe for long series")

  colname = rlang::ensym(colname)
  .stdata %>%
    dplyr::mutate(!!colname := lubridate::round_date(!!colname, paste(round_by, "mins")))
}

#' Expand Sleep Times to full vector
#'
#' Turns the paired sleeptimes into a long single vectored datetime sequence
#'
#' @param .stdata A sleeptimes dataframe
#' @param expand_by Amount (in minutes) to expand sleep times by
#'
#' @importFrom rlang .data
#'
#' @return Sleeptimedataframe with single columns vector for datetime and wake status
#' @keywords internal
expand_sleep_series <- function(.stdata, expand_by = 5) {

  emins = paste(expand_by, "mins")

  .stdata %>%
    dplyr::group_by(.data$sleep.id) %>%
    tidyr::expand(datetime = seq(min(.data$sleep.start), max(.data$sleep.end), by = emins)) %>%
    dplyr::mutate(wake_status = F) %>%
    dplyr::ungroup() %>%
    tidyr::complete(datetime = seq(min(.data$datetime), max(.data$datetime), by = emins), fill = list(wake_status = T))
}

