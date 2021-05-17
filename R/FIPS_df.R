# Generic Function for as_FIPS_df
as_FIPS_df <- function (x, ...) {
  UseMethod("as_FIPS_df", x)
}

as_FIPS_df.data.frame <- function(df) {
  FIPS_df(df)
}

#' The FIPS_df
#'
#' All models implemented in FIPS are implemented to be run on a `FIPS_df` object ---
#' a dataframe containing a time series of all variables required to run [FIPS_simulate] to
#' generate a `FIPS_simulation` object (a subclass of `FIPS_df`).
#'
#' 
#' @param .data A dataframe that matches the required FIPS_df structure
#'
#' @section Specification:
#' The specification for a `FIPS_df` is a dataframe object that contains the following
#' variables (columns). The only input *required* to generate this is a series of sleep/wake times.
#' The FIPS_df is a tibble with the following variables (columns):
#'
#' - `datetime` = vector of datetime stamps separated at equidistance intervals.
#' - `sleep.id` = a supplementary variable indicating sleep episode identifier.
#' - `wake_status` =  Awake (`T`) or asleep (`F`) at that epoch interval/epoch
#' - `wake_status_int` = Awake (1) or asleep (0) at that epoch interval/epoch
#' - `change_point` = Whether the individual changed wake status at that interval/epoch.
#' - `switch_direction` = Whether switch was to sleep or to wake
#' - `status_duration` = How long individual has been in status at that current time point
#' - `total_prev` = If a switch has occured, how long were that in the previous status.
#' - `time` = time of day in decimal hour
#' - `day` =  days into simulation
#' - `sim_hours` = hours simulation has run for total
#' 
#' Note that is theoretically possible to generate a dataframe yourself and apply the `FIPS:::as_FIPS_df()` method. 
#' Be cautious however that as of FIPS 0.1.0 there is no validator at object instantiation time. This is because the validation occurs
#' in internal functions specified in the [parse_sleeptimes]. If the API for creating your own `FIPS_df` 
#' objects is opened to the user end this will be addressed.
#'
#' @md
#' @seealso
#' See FIPS_simulation (internal) for additional columns added after a simulation is run.
#'
#' Also see [parse_sleeptimes] for sleep times converter.
FIPS_df <- function(.data){
  class(.data) <- append("FIPS_df", class(.data))
  .data <- structure(.data, modeltype = FALSE, pvec = FALSE, simmed = FALSE)
  return(.data)
}

#' Test if the object is a [FIPS_df]
#'
#' This function returns `TRUE` for FIPS_df,
#' and `FALSE` for all other objects, including regular data frames.
#'
#' @param x An object
#' @return `TRUE` if the object inherits from the `inherits(x, "FIPS_df")`.
#' @export
#' @md
is_FIPS_df <- function(x) {
  inherits(x, "FIPS_df")
}
