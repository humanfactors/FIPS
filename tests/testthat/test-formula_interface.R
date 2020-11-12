

test_that("Simulation results are equivilent to ground truth", {
  tpmrun = FIPS_simulate(simulation_df, "TPM", TPM_make_pvec())

  new = metric_output(tpmrun, formula_argument = "10.6 + -0.6 * (s + c + u)")
  expect_equal(new$new_output, new$KSS)


})


# Here we run the simulation, demonstrating that the formula function above works


# all.equal()
#
# new = metric_output(tpmrun, formula_argument = "s + c + u + w")
# all.equal(new$new_output, new$alertness)
#
# new = metric_output(tpmrun, formula_argument = "s + c + u + w")
# all.equal(new$new_output, new$alertness)
#
# # Solution to extract the names of variables within the formula, to check they are valid for model of interest
# # This also serves to ensure that the formula (at a high level) is somewhat valid
# test_form = formula(paste("~", "10.6 + -0.6 * (s + c + u)"))
# all.vars(test_form)
