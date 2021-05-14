#' FIPS Simulation dispatcher
#'
#'`FIPS_simulate` is used to apply a particular BMM simulation to a `FIPS_df`.
#' It will dispatch to the selected model simulation type and then return the df with
#' the fitted model columns added on as a `FIPS_simulation` object.
#'
#'
#' @param FIPS_df A valid FIPS_df series that has not already been modelled
#' @param modeltype String: either `"TPM"` (Three Process Model) or `"unified"`.
#' @param pvec Parameter vector (named list), see default pvecs for guidance.
#' @param formula A formula to be parsed to calculate the overall fatigue/alertness score (see details).
#'
#' @md
#' @return a FIPS_simulation object
#' @export
FIPS_simulate <- function(FIPS_df, modeltype = NULL, pvec, formula = NULL) {

  if(!is_FIPS_df(FIPS_df)) {
    stop("This dataframe isn't of FIPS_df class. Please double check you got this right...")
  }

  if(is_simmed_FIPS_df(FIPS_df)) {
    stop("You have already run a simulation on this FIPS_df.
         Please submit a non-simulated FIPS_df dataframe.")
  }

  # Returns a match.arg after tryCatch.
  modeltype <- match.arg(arg = modeltype, choices = c("TPM", "unified"), several.ok = F)

  if (modeltype == "unified") {
    sim = unified_simulate(dat = FIPS_df, pvec = pvec)
    # sim = metric_output(sim, metric_formula)

  } else if (modeltype == "TPM") {
    sim = TPM_simulate(dat = FIPS_df, pvec = pvec)

     # Add KSS for default TPM simulation
    is_pvec_default = all(pvec == pvec.threeprocess)
    if (is_pvec_default) {
      kss_vector = TPM_get_KSS_vector(sim)
      sim = add_formula_vector(sim, kss_vector, "KSS")
    }

    # Do any custom formula stuff
    if (!is.null(formula)) {
      sim = process_bmm_formula(formula, sim)
    }


  }
  return(sim)
}
