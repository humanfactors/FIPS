# TODO: Perform some form of validation on model_formula
validate_formula <- function(.FIPS_sim, model_formula) {
  # labels = attr(terms(model_formula), "term.labels")
  NULL
}


#' get_bmm_model_frame
#'
#' @param .FIPS_sim A FIPS_Simulation object
#' @param model_formula A formula describing how the time-varying processes predictors should be calculated for the predicted output.
#'
#' @return Minimal dataframe with only requird columns for computation
#' @importFrom stats terms
get_bmm_model_frame <- function(.FIPS_sim, model_formula) {
  validated_labs = attr(terms(model_formula), "term.labels")
  validated_labs = validated_labs[!grepl("I\\(", validated_labs)]
  model_frame = data.frame(.FIPS_sim[,c(validated_labs)])
  return(model_frame)
}

#' process_bmm_formula
#'
#' The pvec is required to ensure it is contained in the environment for expression evaluation.
#'
#' @param .FIPS_sim A FIPS_Simulation object
#' @param model_formula A formula describing how the time-varying processes predictors should be calculated for the predicted output.
#' @param pvec A required pvec argument for the .FIPS_sim
#'
#' @return Minimal dataframe with only requird columns for computation
process_bmm_formula <- function(.FIPS_sim, model_formula, pvec) {
  validate_formula(.FIPS_sim, model_formula)
  # Get a reduced .FIPS_sim with only required columns
  bmm_model_frame = get_bmm_model_frame(.FIPS_sim, model_formula)
  # User specified predictor name
  pred_var_string = rlang::as_string(rlang::f_lhs(model_formula))
  form_out = rlang::f_rhs(model_formula)
  pred_out = rlang::eval_tidy(expr(with(bmm_model_frame, !!form_out)))

  # Add prediction column and ensure new name is a pred_col
  .FIPS_sim[,rlang::as_string(pred_var_string)] = pred_out
  attr(.FIPS_sim, "pred_cols") = c(attr(.FIPS_sim, "pred_cols"), pred_var_string)
  .FIPS_sim = set_pred_stat(.FIPS_sim, pred_var_string)
  return(.FIPS_sim)
}

# Used for adding vectors to .FIPS_sim object (i..e, column binding)
# and ensures attributes as set.
add_formula_vector <- function(.FIPS_sim, pred_vector, pred_name) {
  .FIPS_sim[,pred_name] = pred_vector
  attr(.FIPS_sim, "pred_cols") = c(attr(.FIPS_sim, "pred_cols"), pred_name)
  return(.FIPS_sim)
}

# Set the pred_stat object
set_pred_stat <- function(.FIPS_sim, pred_stat_name) {
    attr(.FIPS_sim, "pred_stat") = pred_stat_name
    return(.FIPS_sim)
}