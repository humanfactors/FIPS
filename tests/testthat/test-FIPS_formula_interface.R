test_that("Formulas can be handled", {

  # simrun = FIPS_simulate(simulation_df, "unified", unified_make_pvec())
  tpmrun_sc = FIPS_simulate(simulation_df, "TPM", TPM_make_pvec(), model_formula = s_c_fatigue ~ s + c)
  expect_true(get_FIPS_pred_stat(tpmrun_sc) == "s_c_fatigue")
  expect_true(attr(tpmrun_sc, "simmed"))
  expect_equal(
    tpmrun_sc$s_c_fatigue, (tpmrun_sc$c + tpmrun_sc$s)
  )

  tpmrun_custi = FIPS_simulate(simulation_df, "TPM", TPM_make_pvec(),
                               model_formula = param_fat ~ s + c * I(TPM_make_pvec()["KSS_beta"]))
  expect_true(get_FIPS_pred_stat(tpmrun_custi) == "param_fat")
  expect_true(attr(tpmrun_custi, "simmed"))
  expect_equal(
    tpmrun_custi$param_fat, (tpmrun_custi$s + tpmrun_custi$c * TPM_make_pvec()["KSS_beta"])
  )
})

test_that("Formula is working with custom pvec", {
  # TODO: This test is a bit botched due to caller environments... Maybe a fix one day.
  my_random_vec = TPM_make_pvec(Um = 5)
  mysim = FIPS_simulate(simulation_df, "TPM", pvec = my_random_vec, model_formula = alertness ~ c * I(pvec["Um"]))
  expect_equal(mysim$alertness, mysim$c * 5)
})
