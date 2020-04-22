test_that("Simulation actually runs through in full", {
  expect_true(get_FIPS_modeltype(test_simulation_unified) == "unified")
  expect_true(length(!is.na(test_simulation_unified$fatigue)) == 2821)
})

test_that("Simulation results are equivilent to ground truth", {
  verified_simulation_unified <- readRDS("simulation_unified.Rds")
  ground_truth = verified_simulation_unified$FIPS_df$fatigue
  tested_fatvec = test_simulation_unified$fatigue
  expect_equal(ground_truth, tested_fatvec)
})


