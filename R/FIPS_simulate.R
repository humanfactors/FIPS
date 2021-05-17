#' FIPS Simulation dispatcher
#'
#'`FIPS_simulate` is used to apply a particular BMM simulation to a `FIPS_df`.
#' It will dispatch to the selected model simulation type and then return the df with
#' the fitted model columns added on as a `FIPS_simulation` object.
#'
#' If the formula argument is omitted, then default prediction values will be returned:
#' KSS and alertness for TPM, and fatigue (i.e., lapses) for unified.
#'
#'
#' @param FIPS_df A valid FIPS_df series that has not already been modelled
#' @param modeltype String: either `"TPM"` (Three Process Model) or `"unified"`.
#' @param pvec Parameter vector (named list), see default pvecs for guidance.
#' @param model_formula An optional formula describing how the time-varying processes predictors should be calculated for the predicted output. See details.
#'
#' @details
#'
#' ### Formula Argument
#'
#' - The formula argument takes the form of an R formula expression (e.g., `y ~ c + s`).
#' - The term of the left-hand side (e.g., `y`) defines the variable name
#' - The term(s) on the right-hand side define how the variable is computed
#' - All variables must be defined in your enviornment or in the FIPS_simulation output (e.g., `s, c, l, w` for "TPM").
#' - Parameter vector and other variable arguments must be placed in `I(expression)` format. For example,
#' `fatigue ~ s + c + I(pvec[["KSS_beta"]])`.
#'
#' @md
#' @return a FIPS_simulation object
#' @export
FIPS_simulate <- function(FIPS_df, modeltype = NULL, pvec, model_formula = NULL) {

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
    sim = unified_simulation_dispatch(dat = FIPS_df, pvec = pvec, model_formula = model_formula)
  } else if (modeltype == "TPM") {
    sim = TPM_simulation_dispatch(dat = FIPS_df, pvec = pvec, model_formula = model_formula)
  }
  return(sim)
}
