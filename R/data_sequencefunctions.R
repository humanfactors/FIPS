# Generate Decimal Time dates from a timedate object
#
# Requires a datetime.col, will return the time day and hours since first timedate
# all in decimal time
generate_decimal_timeunits <- function(.data, datetime.col) {
  datetime.col = rlang::ensym(datetime.col)
  .data %>%
    mutate(
      time = as.decimaltime(!!datetime.col),
      day = as.sequenced.days(!!datetime.col),
      sim_hours = as.numeric(lubridate::interval(min(!!datetime.col), !!datetime.col), "hours")
    )
}

# Identify points of change in status
change_points <- function(statevec) {
  outvec = rep(0, length(statevec))
  for (i in 2:length(statevec)) {
    v_i = statevec[i]; v_lag = statevec[i-1]
    outvec[i] = ifelse(v_i != v_lag, 1, 0)
  }
  return(outvec)
}

# Identify if change was them going to Sleep or Waking
# This would be used by model_sim functions
status_dir <- function(statevec, changevec) {
  directionality = rep("0", length(statevec))
  for (i in 2:length(changevec)) {
    v_i = statevec[i]; v_lag = statevec[i-1]
    if (changevec[i]) {
      directionality[i] = ifelse(v_i - v_lag == -1, "Sleep", "Wake")
    }
  }
  return(as.character(directionality))
}

# This shows how long has been in that status, meaning we don't need $taw and $tas.
time_in_status = function(statevec, epoch_mins) {
  (sequence(rle(statevec)$lengths) - 1) * (epoch_mins / 60)
}

# But we can get out the total time in last period like this
shift <- function(x, shift) c(rep(NA,times=shift), x[1:(length(x)-shift)])

# Caclulate time in previous status, but shift result so that it appears on an awake line"
shifted_time_status = function(statevec, changevec, epoch_mins) {
  out = shift((sequence(rle(statevec)$lengths)) * (epoch_mins / 60), 1)
  out[!changevec] = 0
  out
}

# Return sleep IDs from the wakestatus vector
bitvec_to_cumcount <- function(bitvec) {
  # Let's make sure we know what we operating on
  wakesleep_seq_is_binary(as.integer(bitvec))
  # We want sleep times so flip wake vector
  bitvec = 1 - as.integer(bitvec)
  # Now let's do the rme magic
  rle_bv = rle(bitvec)
  # Because zero * new value = 0
  rle_bv$values <- with(rle_bv, cumsum(values) * values)
  out = inverse.rle(rle_bv)
  return(replace(out, out == 0, NA))
}


