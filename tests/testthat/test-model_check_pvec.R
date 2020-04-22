test_that("Check that check_pvec detects bad parameters with custom messages returned", {

good_pvec = unified_make_pvec()
bad_pvec1 = append(good_pvec, c(badparms = 12))
bad_pvec2 = good_pvec[1:6]
TPM_badpvec = TPM_make_pvec()[1:7]
TPM_badpvec2 = append(TPM_make_pvec(), c(badparms = 7))

  # Check we get custom error message for too many parameters
  expect_error(
    { FIPS_simulate(
    FIPS_df = simulation_df ,
    modeltype = "unified",
    bad_pvec1) },
    regexp = "Unified model fit halted!")

  # Check we get custom error message for missing parameters
  expect_error(
    { FIPS_simulate(
      FIPS_df = simulation_df ,
      modeltype = "unified",
      bad_pvec2) },
    regexp = "Unified model fit halted!")

  # Also check for TPM for too many parameters
  expect_error(
    { FIPS_simulate(
      FIPS_df = simulation_df ,
      modeltype = "TPM",
      TPM_badpvec2) },
    regexp = "Three Process Model fit halted!")

  # Also check for TPM for missing parameters
  expect_error(
    { FIPS_simulate(
      FIPS_df = simulation_df ,
      modeltype = "TPM",
      TPM_badpvec) },
    regexp = "Three Process Model fit halted!")

})