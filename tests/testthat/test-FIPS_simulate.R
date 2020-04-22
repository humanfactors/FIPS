test_that("Error handling working correctly", {

  expect_error(FIPS_simulate(c(1,2,3), "unified", unified_make_pvec()),
               regexp = "This FIPS_df isn't of FIPS_df class.")

  expect_error(FIPS_simulate(test_simulation_unified, "unified", unified_make_pvec()),
               regexp = "You have already run a simulation on this FIPS_df.")

  expect_error(FIPS_simulate(test_simulation_unified, "TPM", TPM_make_pvec()),
               regexp = "You have already run a simulation on this FIPS_df.")


  expect_error(FIPS_simulate(simulation_df, "choccytoppy", unified_make_pvec()),
               regexp = "'arg' should be one of")

})

test_that("Simulate runs and can access attributes post simulation", {

  simrun = FIPS_simulate(simulation_df, "unified", unified_make_pvec())
  tpmrun = FIPS_simulate(simulation_df, "TPM", TPM_make_pvec())

  expect_equal(nrow(simrun), 2821)
  expect_equal(get_FIPS_pvec(simrun), unified_make_pvec())
  expect_true(get_FIPS_pred_stat(simrun) == "fatigue")
  expect_true(attr(simrun, "simmed"))

  expect_equal(get_FIPS_pvec(tpmrun), TPM_make_pvec())
  expect_true(get_FIPS_pred_stat(tpmrun) == "alertness")
  expect_true(attr(tpmrun, "simmed"))

})

test_that("Attribute loss is handled", {

  test_mutate = mutate(test_simulation_unified, cw = c + w)
  expect_warning(capture_output({print(test_mutate)}))
  expect_warning(capture_output({summary(test_mutate)}))
  expect_error(plot(test_mutate))

})



