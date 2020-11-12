get_custom_formula_variables <- function(formula_argument) {
  test_form = formula(paste("~", formula_argument))
  return(all.vars(test_form[test_form!="pvec"]))
}


check_formula_argument <- function(FIPS_simulation, formula_argument) {
  form_vars = get_custom_formula_variables(formula_argument)
  if (all(form_vars %in% names(FIPS_simulation))) {
     TRUE
  } else {
     stop("The formula specifies variables (i.e., columns) that do not exist in your supplied FIPS_df")
  }
}


# internal only
get_pred_stat_custom <- function (x) {
  if(is_FIPS_simulation(x)) {
    return(attr(x, "pred_stat_custom", T))
  } else {
    stop("Cannot extract extract pred_stat_custom from an unsimmed FIPS_df")
  }
}


metric_output = function(FIPS_simulation, formula_argument) {
  # Validate argument is appropriate for model (model specific required)
  check_formula_argument(FIPS_simulation, formula_argument)
  pvec = get_FIPS_pvec(FIPS_simulation)
  # Mutate dataframe to include output as formula
  return(pvec)
  if(is.null(formula_argument)) return(FIPS_simulation)

  FIPS_simulation %>%
    dplyr::mutate(pred_stat = !!rlang::parse_expr(formula_argument))
}

