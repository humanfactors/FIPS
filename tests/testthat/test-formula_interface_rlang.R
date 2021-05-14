# example.sleeptimes <- tibble::tibble(
#   sleep.start = seq(
#     from = lubridate::ymd_hms('2018-05-03 00:00:00', tz = "Australia/Perth"),
#     to = lubridate::ymd_hms('2018-05-09 00:00:00', tz = "Australia/Perth"),
#     by = '24 hours'),
#   sleep.end = sleep.start + lubridate::dhours(8),
#   sleep.id = rank(sleep.start))
#
# # Simulation start date time (i.e., when you want first predictions to begin)
# simulation.start = lubridate::ymd_hms('2018-05-03 00:00:00', tz = "Australia/Perth")
# # Simulation end date time (i.e., when you want predictions to end)
# simulation.end = lubridate::ymd_hms('2018-05-09 21:00:00', tz = "Australia/Perth")
#
# simulated.dataframe = parse_sleeptimes(
#   sleeptimes = example.sleeptimes,
#   series.start = simulation.start,
#   series.end = simulation.end,
#   sleep.start.col = "sleep.start",
#   sleep.end.col = "sleep.end",
#   sleep.id.col = "sleep.id",
#   roundvalue = 5)
#
# TPM.simulation.results = FIPS_simulate(
#   FIPS_df = simulated.dataframe, # The FIPS_df
#   modeltype = "TPM",         # three process model
#   pvec = TPM_make_pvec()      # paramater vector
# )
#
# process_bmm_formula(tirednessbro ~ s + c + u + w, TPM.simulation.results)
#
# Introduce model data required to env
# model_df = data.frame(TPM.simulation.results[,c("s", "c", "u")])
#
# # A basic user-supplied formula argument
# test_formula = formula(alertness ~ s + c + u + I(100))
#
# # Extract term for new column
# pred_var = rlang::f_lhs(test_formula)
# form_out = rlang::f_rhs(test_formula)
# pred_out = rlang::eval_tidy(expr(with(model_mat, !!form_out)))
# model_mat[, rlang::as_string(pred_var)] = pred_out
#
# dplyr::bind_cols(TPM.simulation.results, alertness = pred_out)

