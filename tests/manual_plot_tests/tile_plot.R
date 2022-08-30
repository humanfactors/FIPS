library(tidyverse)

sleeptimes_common <- tibble::tibble(
  sleep.start = seq(
    from = lubridate::ymd_hms('2018-05-09 23:00:00', tz = "Australia/Perth"),
    to = lubridate::ymd_hms('2018-05-11 23:00:00', tz = "Australia/Perth"),
    by = '24 hours'),
  sleep.end = sleep.start + lubridate::dhours(8),
  sleep.id = rank(sleep.start)+7)

wake_datetime = lubridate::ymd_hms('2018-05-03 7:00:00', tz = "Australia/Perth")
ndays = 7
sleep_hrs = 8

sleeptimes <- rbind(
  tibble(
    sleep.start = seq(
      from = wake_datetime - hours(sleep_hrs),
      to = wake_datetime - hours(sleep_hrs) + days(ndays - 1),
      by = '24 hours'),
    sleep.end = sleep.start + lubridate::dhours(sleep_hrs),
    sleep.id = rank(sleep.start)
  ),
  sleeptimes_common
)

simulation_df = parse_sleeptimes(
  sleeptimes = sleeptimes ,
  series.start = lubridate::ymd_hms('2018-05-02 21:55:00', tz = "Australia/Perth"),
  series.end = lubridate::ymd_hms('2018-05-12 23:00:00', tz = "Australia/Perth"),
  sleep.start.col = "sleep.start",
  sleep.end.col = "sleep.end",
  sleep.id.col = "sleep.id",
  roundvalue = 15
)

simulation_df <- simulation_df %>%
  dplyr::filter(datetime>=sleeptimes$sleep.start[1])

test_simulation_unified <- FIPS_simulate(
  FIPS_df = simulation_df ,
  modeltype = "unified",
  pvec = unified_make_pvec(
    U0 = 24.12,
    L0 = 0,
    S0 = 0,
    phi = 2.02,
    kappa = 4.13,
    tau_s = 1,
    tau_w = 40,
    tau_la = 97.44,
    sigma = 1,
    wc = 1.14,
    wd = -0.46
  )
)


x = tileplot_dataprep_FIPS_sim(test_simulation_unified)
x
plotly::ggplotly(x, tooltip = "fill")
