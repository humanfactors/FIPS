# tpmrun = FIPS_simulate(simulation_df, "TPM", TPM_make_pvec())
#
#
# test_that("Formula interface produces results identical to manual method", {
#   new = metric_output(tpmrun, formula_argument = "10.6 + -0.6 * (s + c + u + w)")
#   expect_equal(new$pred_stat, new$KSS)})
#
#
# test_that("Formula interface bad inputs", {
#   expect_error({
#     metric_output(tpmrun, formula_argument = "10.6 + -0.6 * (s + c + u + w + p)")
#   }, regexp = "The formula specifies variables")})
#
#
# # Here we run the simulation, demonstrating that the formula function above works
#
#
# # all.equal()
# #
# # new = metric_output(tpmrun, formula_argument = "s + c + u + w")
# # all.equal(new$new_output, new$alertness)
# #
# # new = metric_output(tpmrun, formula_argument = "s + c + u + w")
# # all.equal(new$new_output, new$alertness)
# #
# # # Solution to extract the names of variables within the formula, to check they are valid for model of interest
# # # This also serves to ensure that the formula (at a high level) is somewhat valid
# # test_form = formula(paste("~", "10.6 + -0.6 * (s + c + u)"))
# # all.vars(test_form)
