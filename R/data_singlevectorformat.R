wakesleep_seq_is_binary <- function(x) {
    return(all(x == 0 | x == 1))
}

validate_wakesleep_seq <- function(seq) {
    if(!wakesleep_seq_is_binary(seq)) {
        stop("Binary sequence must only contain 1's (wake) and 0's (sleep)")
    }
}

validate_epoch <- function(e) {
    # Check not decimal
    if(e %% 1 != 0) {
        stop("Epoch value must be an integer (i.e., decimals not permitted) in minutes.")
    }
    if(e > 30) {
        warning("Epoch value is in minutes. You have specified an epoch length longer than 30 minutes. Are you sure this is correct?")
    }
}

#' Parse Sleep Wake Binary/Integer Sequence
#'
#' It is common to have sleep wake history information in the form of a binary sequence.
#' This is the format used by SAFTE-FAST and other proprietary software.
#' Further, this format is often easily exported by actigraphy measurement software.
#'
#' @param seq A sequence of `0` (sleep) and `1` (wake) integers indicating sleep/wake status at that moment.
#' @param epoch Integer expressing length of each observations in the series (minutes).
#' @param series.start A POSIXct object indicating the start datetime of the simulation (i.e., pre-first sleep waking duration)
#'
#' @md
#' @return `FIPS_df` formatted dataframe
#' @export
#'
parse_sleepwake_sequence <- function(seq, epoch, series.start) {

    # Argument validation
    validate_epoch(epoch)
    validate_wakesleep_seq(seq)
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
    wake_status_int = seq
    wake_status = as.logical(seq)
    change_point = change_points(seq)
    switch_direction = status_dir(seq, change_point)
    status_duration = time_in_status(wake_status, epoch)
    total_prev = shifted_time_status(wake_status, change_point, epoch)

    return(as_FIPS_df(data.frame(datetime, time, day, sim_hours, wake_status_int,
    wake_status, change_point, switch_direction, status_duration, total_prev, stringsAsFactors = F)))

}


