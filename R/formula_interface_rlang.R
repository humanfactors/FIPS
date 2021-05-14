validate_formula <- function(formula, .FIPS_sim) {
  # labels = attr(terms(test_formula), "term.labels")
  NULL
}


get_bmm_model_frame <- function(formula, .FIPS_sim) {
  validated_labs = attr(terms(formula), "term.labels")
  validated_labs = validated_labs[!grepl("I\\(", validated_labs)]
  model_frame = data.frame(.FIPS_sim[,c(validated_labs)])
  return(model_frame)
}

process_bmm_formula <- function(formula, .FIPS_sim) {
  validate_formula(formula, .FIPS_sim)
  bmm_model_frame = get_bmm_model_frame(formula, .FIPS_sim)
  pred_var_string = rlang::as_string(rlang::f_lhs(formula))
  form_out = rlang::f_rhs(formula)
  pred_out = rlang::eval_tidy(expr(with(bmm_model_frame, !!form_out)))

  # Add prediction column and ensure new name is a pred_col
  .FIPS_sim[,rlang::as_string(pred_var_string)] = pred_out
  attr(.FIPS_sim, "pred_cols") = c(attr(.FIPS_sim, "pred_cols"), pred_var_string)
  return(.FIPS_sim)
}

# Used for adding vectors to .FIPS_sim
add_formula_vector <- function(.FIPS_sim, pred_vector, pred_name) {
  .FIPS_sim[,pred_name] = pred_vector
  attr(.FIPS_sim, "pred_cols") = c(attr(.FIPS_sim, "pred_cols"), pred_name)
  return(.FIPS_sim)
}


