check_formula_argument <- function(formula_argument) {
  NULL
}

metric_output = function(FIPS_simulation, formula_argument) {
  # Validate argument is appropriate for model (model specific required)
  check_formula_argument(formula_argument)
  # Mutate dataframe to include output as formula
  FIPS_simulation %>%
    dplyr::mutate(new_output = !!rlang::parse_expr(formula_argument))
}

