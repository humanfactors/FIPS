# SETUP: Generate data for testing
perth = "Australia/Perth"


# Setup sleep times minimal dataframe
unit_sleeptimes = tibble::tribble(
  ~sleep.id,          ~sleep.start,            ~sleep.end,
  1L, "2018-05-21 01:00:00", "2018-05-21 07:00:00",
  2L, "2018-05-21 23:00:00", "2018-05-22 04:00:00",
  3L, "2018-05-23 01:00:00", "2018-05-23 09:00:00"
) %>%
  dplyr::mutate(
    sleep.start = lubridate::ymd_hms(sleep.start, tz = perth),
    sleep.end = lubridate::ymd_hms(sleep.end, tz = perth))

unit_simstart = ymd_hms('2018-05-20 22:00:00', tz = perth)
unit_simend   = ymd_hms('2018-05-23 10:00:00', tz = perth)

unit_sleeptimes_renamed = unit_sleeptimes %>%
  dplyr::rename(sleep_id = sleep.id, sleep_start = sleep.start, sleep_end = sleep.end)

test_that(
  "parse_sleeptimes executes and expands out correctly.", {
    unit_parsedtimes = parse_sleeptimes(
      sleeptimes = unit_sleeptimes,
                     series.start = unit_simstart,
                     series.end = unit_simend,
                     sleep.start.col = "sleep.start",
                     sleep.end.col = "sleep.end",
                     sleep.id.col = "sleep.id",
                     roundvalue = 5)

    # Conversion has occured
    expect_s3_class(unit_parsedtimes, "FIPS_df")
    # FIPS_df length should be 1 unit longer than entire interval (due to inclusion of final instance)
    expect_equal((lubridate::int_length(unit_simstart %--% unit_simend)/60/5), 721-1)
    # Check this as well with actual dataframe
    expect_equal(lubridate::int_length(unit_simstart %--% unit_simend)/60/5, length(unit_parsedtimes$datetime) - 1)
    # Maximum in any status -- i.e., wake -- should be 21 hours
    expect_true(max(unit_parsedtimes$total_prev) * 60 == 1260)
    # Check status duration equal to 23 hours minus 5 as well
    expect_equal(max(unit_parsedtimes$status_duration)*60, 1260-5, tolerance = .001)
    # Now let's make sure that all cases where switches have occured have the correct information
    unitpar_switches = unit_parsedtimes %>% dplyr::filter(change_point == 1)
    # All switch points should be associated with a status duration of zero
    expect_equal(sum(unitpar_switches$status_duration), 0)
    # all switch directions to sleep should be associated with a wake_status of F
    expect_true(all(dplyr::filter(unitpar_switches, wake_status == F)[["switch_direction"]] == "Sleep"))
  })


test_that("parse_sleeptimes handles series.start and ends named differently from default", {

  unit_parsedtimes = parse_sleeptimes(
    sleeptimes = unit_sleeptimes_renamed,
    series.start = unit_simstart,
    series.end = unit_simend,
    sleep.start.col = "sleep_start",
    sleep.end.col = "sleep_end",
    sleep.id.col = "sleep_id",
    roundvalue = 5)

  expect_s3_class(unit_parsedtimes, "FIPS_df")

})

test_that("If column name not found, a useful error message is provided", {
  expect_error(
    parse_sleeptimes(
    sleeptimes = unit_sleeptimes_renamed,
    series.start = unit_simstart,
    series.end = unit_simend,
    sleep.start.col = "sleep_start",
    sleep.end.col = "sleep_end",
    sleep.id.col = "sleep_x_id",
    roundvalue = 5), regexp = "At least one of the column")

})



test_that("If user supplies roundvalue > 1 and not whole number, it is handled.", {

  expect_warning(
    parse_sleeptimes(
      sleeptimes = unit_sleeptimes,
      series.start = unit_simstart,
      series.end = unit_simend,
      sleep.start.col = "sleep.start",
      sleep.end.col = "sleep.end",
      sleep.id.col = "sleep.id",
      roundvalue = 6.3), regexp = "roundvalue must be a whole number")

})


test_that("If user supplies roundvalue < 1, error handled and thrown.", {
  expect_error(
    parse_sleeptimes(
      sleeptimes = unit_sleeptimes,
      series.start = unit_simstart,
      series.end = unit_simend,
      sleep.start.col = "sleep.start",
      sleep.end.col = "sleep.end",
      sleep.id.col = "sleep.id",
      roundvalue = 0.5), regexp = "roundvalue must be a whole number")

})


test_that("parse_sleeptimes handles series.start and ends that are identical to max/min sleeps", {

    simstart_same = ymd_hms('2018-05-21 01:00:00', tz = perth) # starts at same time
    simend_same = ymd_hms('2018-05-23 09:00:00', tz = perth) # starts too early

    finlen = parse_sleeptimes(
      sleeptimes = unit_sleeptimes,
      series.start = simstart_same,
      series.end = simend_same,
      sleep.start.col = "sleep.start",
      sleep.end.col = "sleep.end",
      sleep.id.col = "sleep.id",
      roundvalue = 5)
    expect_length(finlen$datetime, 673)
    expect_equal(lubridate::int_length(simstart_same %--% simend_same)/60/5, length(finlen$datetime) -1)
})


test_that(
  "parse_sleeptimes handles incorrect data inputs", {
    error_unit_simstart = ymd_hms('2018-05-21 23:00:00', tz = perth) # starts too late
    error_unit_simend   = ymd_hms('2018-05-22 6:55:00', tz = perth) # ends too early
    error_unit_tz = ymd_hms('2018-05-23 22:55:00', tz = "GMT")

    expect_error({parse_sleeptimes(
      sleeptimes = unit_sleeptimes,
      series.start = unit_simstart,
      series.end = error_unit_tz,
      sleep.start.col = "sleep.start",
      sleep.end.col = "sleep.end",
      sleep.id.col = "sleep.id",
      roundvalue = 5)}, regexp = "Timezones of 'x' and 'lower' must match")

    expect_error({parse_sleeptimes(
      sleeptimes = unit_sleeptimes,
      series.start = error_unit_simstart,
      series.end = unit_simend,
      sleep.start.col = "sleep.start",
      sleep.end.col = "sleep.end",
      sleep.id.col = "sleep.id",
      roundvalue = 5)}, regexp = "Element 1 is not <=")

    expect_error(parse_sleeptimes(
      sleeptimes = unit_sleeptimes,
      series.start = unit_simstart,
      series.end = error_unit_simend,
      sleep.start.col = "sleep.start",
      sleep.end.col = "sleep.end",
      sleep.id.col = "sleep.id",
      roundvalue = 5), regexp = "Assertion on 'series end datetime' failed: Element 1 is not")

  }
)


# Testing roundsleeptimes function
test_that(
  "roundsleeptimes rounds to 5 minute intervals",
  expect_equivalent(
    # Rounded version
    round_times(tibble::tibble(
      sleep.start = ymd_hms('2018-05-21 01:01:00', tz = perth)), sleep.start, 5),
    # Manually rounded
    tibble::tibble(
      sleep.start = ymd_hms('2018-05-21 01:00:00', tz = perth))
  )
)


