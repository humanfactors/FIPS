# Setup sleep times minimal dataframe
unit_sleeptimes = tibble::tribble(
  ~sleep.id,          ~sleep.start,            ~sleep.end,
  1L, "2018-05-21 01:00:00", "2018-05-21 07:00:00",
  2L, "2018-05-21 23:00:00", "2018-05-22 04:00:00",
  3L, "2018-05-23 01:00:00", "2018-05-23 09:00:00"
) %>%
  dplyr::mutate(
    sleep.start = lubridate::ymd_hms(sleep.start, tz = "Australia/Perth"),
    sleep.end = lubridate::ymd_hms(sleep.end, tz = "Australia/Perth"))

## Base = as.POSIXct("2018-05-20 22:00:00", tz = "Australia/Perth"))
unit_simstart = lubridate::ymd_hms('2018-05-20 22:00:00', tz = "Australia/Perth")
unit_simend   = lubridate::ymd_hms('2018-05-23 10:00:00', tz = "Australia/Perth")

unit_parsedtimes = parse_sleeptimes(
  sleeptimes = unit_sleeptimes,
  series.start = unit_simstart,
  series.end = unit_simend,
  sleep.start.col = "sleep.start",
  sleep.end.col = "sleep.end",
  sleep.id.col = "sleep.id",
  roundvalue = 5)

unit_sequence = unit_parsedtimes$wake_status_int

test_that("Sleep wake vector parsing produces same results as from sleep times format", {

    unit_vecseq_parsed = parse_sleepwake_sequence(unit_sequence, 5, unit_simstart)

    expect_equal(unit_parsedtimes$datetime, unit_vecseq_parsed$datetime)
    expect_equal(unit_parsedtimes$wake_status, unit_vecseq_parsed$wake_status)
    expect_equal(unit_parsedtimes$wake_status_int, unit_vecseq_parsed$wake_status_int)
    expect_equal(unit_parsedtimes$change_point, unit_vecseq_parsed$change_point)
    expect_equal(unit_parsedtimes$switch_direction, unit_vecseq_parsed$switch_direction)
    expect_equal(unit_parsedtimes$status_duration, unit_vecseq_parsed$status_duration)
    expect_equal(unit_parsedtimes$sleep.id, unit_vecseq_parsed$sleep.id)
    expect_equal(unit_parsedtimes$total_prev, unit_vecseq_parsed$total_prev)
    expect_equal(unit_parsedtimes$time, unit_vecseq_parsed$time)
    expect_equal(unit_parsedtimes$day, unit_vecseq_parsed$day)
    expect_equal(unit_parsedtimes$sim_hours, unit_vecseq_parsed$sim_hours)

})

test_that("Sleep wake vector format can be modelled", {

  unit_vecseq_parsed = parse_sleepwake_sequence(unit_sequence, 5, unit_simstart)
  tpmrun = FIPS_simulate(unit_vecseq_parsed, "TPM", TPM_make_pvec())

  expect_equal(nrow(tpmrun), 721)
  expect_equal(get_FIPS_pvec(tpmrun), TPM_make_pvec())
  expect_true(get_FIPS_pred_stat(tpmrun) == "alertness")
  expect_true(attr(tpmrun, "simmed"))


})

test_that("Sleep wake vector error handlers operating", {

  expect_error(parse_sleepwake_sequence(c(1,2,3), 5, unit_simstart),
               "Binary sequence must only contain")

  expect_error(parse_sleepwake_sequence("Cats", 5, unit_simstart),
               "Binary sequence must only contain")

  expect_warning(parse_sleepwake_sequence(c(1,1,1,1,0,0,0,0), 85, unit_simstart),
                 regexp = "You have specified an epoch length longer than 30 minutes")

  expect_error(parse_sleepwake_sequence(c(1,1,1,1,0,0,0,0), 5.5, unit_simstart),
               "Epoch value must be an integer")

})









