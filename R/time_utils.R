# Generic function for converting time objects to decimal time
as.decimaltime <- function (x, ...) {
  UseMethod("as.decimaltime", x)
}

# POSIXct method for converting from base to decimal time
as.decimaltime.POSIXct <- function(stamp) {
  if (any(!inherits(stamp, c("POSIXt", "POSIXct", "POSIXlt", "Date"))))
    stop("date(s) not in POSIXt or Date format")

  hours = as.integer(lubridate::hour(stamp))
  minutes = as.integer(lubridate::minute(stamp))
  return(hours + minutes/60)
}


as.sequenced.days <- function(timedatevector) {
  dates = lubridate::as_date(timedatevector)
  as.integer(as.ordered(dates))
}
