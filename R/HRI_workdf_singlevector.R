workrest_seq_is_binary <- function(x) {
  return(all(x == 0 | x == 1))
}

workrest_seq_is_logical <- function(x) {
  return(all(x == T | x == F))
}

validate_workrest_seq <- function(seq) {
  if(!workrest_seq_is_binary(seq)) {
    stop("Binary sequence must only contain 1's (work) and 0's (off-duty)")
  }
}

validate_epoch <- function(e) {
  # Check not decimal
  if(e %% 1 != 0) {
    stop("Epoch value must be an integer (i.e., decimals not permitted) in minutes.")
  }
  if(e > 360) {
    warning("Epoch value is in minutes. You have specified an epoch length longer than 360 minutes. Are you sure this is correct?")
  }
}

work_switch_direction = function(status_seq, change_point) {
  return(dplyr::case_when(
    status_seq == 0 & change_point == 1 ~ "Rest",
    status_seq == 1 & change_point == 1 ~ "Work",
    TRUE ~ "0"
  ))
}

# Caclulate time in previous status, but shift result so that it appears on an awake line"
HRI_shifted_time_status = function(statevec, changevec, epoch_mins) {
  out = shift((sequence(rle(statevec)$lengths)) * (epoch_mins / 60), 1)
  out[!changevec] = 0
  out
}

#' Parse Work // Offduty Binary/Integer Sequence
#'
#' It is common to have sleep wake history information in the form of a binary sequence.
#' This is the format used by SAFTE-FAST and other proprietary software.
#' Further, this format is often easily exported by actigraphy measurement software.
#'
#' @param seq A sequence of `0` (sleep) and `1` (wake) integers indicating sleep/wake status at that moment.
#' @param epoch Integer expressing length of each observations in the series (minutes).
#' @param series.start A POSIXct object indicating the start datetime of the simulation (i.e., pre-first sleep waking duration)
#' @md
#' @return `FIPS_df` formatted dataframe
#' @export
#'
#' @examples
#' start_date = as.POSIXct("2018-05-01 10:00:00")
#' bitvector_sequence = rep(rep(c(1,0), 6), sample(20:40, 12))
#' FIPSdf_from_bitvec = parse_workrest_sequence(
#'  seq = bitvector_sequence,
#'  series.start = start_date,
#'  epoch = 15)
#'
parse_workrest_sequence <- function(seq, epoch, series.start) {

  # Argument validation
  validate_epoch(epoch)
  validate_workrest_seq(seq)
  checkmate::assert_posixct(series.start, any.missing = F, len = 1)

  # Construct datetime sequence
  datetime = seq(from = series.start,
                 to = series.start + (60 * (length(seq) - 1) * epoch),
                 by = paste(epoch, "min"))

  # From datetime sequence, derive the decimal arguments
  time = as.decimaltime(datetime)
  day = as.sequenced.days(datetime)
  sim_hours = as.numeric(lubridate::interval(min(datetime), datetime), "hours")

  # Status based sequence
  work_status_int = seq
  shift.id = bitvec_to_cumcount(seq)
  work_status = as.logical(seq)
  change_point = change_points(seq)
  switch_direction = work_switch_direction(work_status_int, change_point)
  status_duration = time_in_status(work_status, epoch)
  total_prev = shifted_time_status(work_status, change_point, epoch)

  return(as_FIPS_df(data.frame(datetime,shift.id, time, day, sim_hours, work_status_int,
                               work_status, change_point, switch_direction, status_duration, total_prev, stringsAsFactors = F)))

}



