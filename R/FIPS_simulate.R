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
#' @param metric_formula A string formula to be parsed by dplyr::mutate to
#' calculate the overall fatigue/alertness score.
#'
#' @md
#' @return a FIPS_simulation object
#' @export
FIPS_simulate <- function(FIPS_df, modeltype = NULL, pvec, metric_formula = NULL) {

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
    # sim = metric_output(sim, metric_formula)
  }
  return(sim)
}
