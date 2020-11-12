# Internal function for instantiation of a FIPS_simulation
# Must be called at the end of a model loop run in a simulation_*.R file
FIPS_simulation <- function(dat, modeltype, pvec, pred_stat_name, pred_cols, pred_stat_default = NULL, pred_stat_used = NULL) {
  class(dat) <- append("FIPS_simulation", class(dat))
  attr(dat, "simmed") = TRUE
  attr(dat, "modeltype") = modeltype
  attr(dat, "pvec") = pvec
  attr(dat, "pred_stat_default") = pred_stat_default
  attr(dat, "pred_stat_used") = pred_stat_used
  attr(dat, "pred_stat_name") = pred_stat_name
  attr(dat, "pred_cols") = pred_cols
  return(dat)
}


#' Test if the object is a simmed FIPS_df
#'
#' This function returns `TRUE` for FIPS_df if a simulation has been run on it,
#' and `FALSE` for all other objects, including regular data frames.
#'
#' @param x An object
#' @return `TRUE` if the object inherits from the `inherits(x, "FIPS_df") & attr(x, "simmed") `.
#' @export
#' @md
is_FIPS_simulation <- function(x) {
  return(inherits(x, "FIPS_df") & inherits(x, "FIPS_simulation") & attr(x, "simmed") == TRUE)
}

# internal only - has a simulation been run on the FIPS_df?
is_simmed_FIPS_df <- function(x) {
  return(is_FIPS_df(x) & attr(x, "simmed") == TRUE)
}

# internal only -  extracting the pvec from a simmed FIPS_df object
get_FIPS_pvec <- function (x) {
  if(is_FIPS_simulation(x)) {
    pvec = attr(x, "pvec", T)
  } else {
    stop("Cannot extract extract pvec from an unsimmed FIPS_df")
  }
  return(pvec)
}

# internal only
get_FIPS_modeltype <- function (x) {
  if(is_FIPS_simulation(x)) {
    mt = attr(x, "modeltype", T)
  } else {
    stop("Cannot extract extract modeltype from an unsimmed FIPS_df")
  }
  return(mt)
}

# internal only
get_FIPS_pred_stat_name <- function (x) {
  if(is_FIPS_simulation(x)) {
    mt = attr(x, "pred_stat_name", T)
  } else {
    stop("Cannot extract extract pred_stat_name from an unsimmed FIPS_df")
  }
  return(mt)
}

# internal only
get_FIPS_pred_cols <- function (x) {
  if(is_FIPS_simulation(x)) {
    mt = attr(x, "pred_cols", T)
  } else {
    stop("Cannot extract extract pred_cols from an unsimmed FIPS_df")
  }
  return(mt)
}

# Tidyverse functions will remove attributes, this returns FALSE if attributes
# of Simulation have been lost, so that generic functions dispatch onwards.
FIPS_Simulation_lost_attributes <- function(x) {
  inherits(x, "FIPS_simulation") & any(
    is.null(attr(x, "pred_stat", T)), is.null(attr(x, "modeltype", T)), is.null(attr(x, "pvec", T))
    )
}


# print.FIPS_simulation
#
# @method print FIPS_simulation
#
# @export
print.FIPS_simulation <- function(x) {

  if(FIPS_Simulation_lost_attributes(x)) {
    warning("Your FIPS_Simulation object has lost attributes (have you wrangled the dataframe with dplyr (version < 1.0.0?). Dispatching method onwards.")
    NextMethod()
  } else {
    help_function = switch(get_FIPS_modeltype(x),
                           TPM = "help(FIPS::TPM_make_pvec)",
                           unified = "help(FIPS::unified_make_pvec)")
    cat("---------\n")
    cat(paste("Model Type:"), get_FIPS_modeltype(x), "\n")
    cat(paste("Epoch Value:"), (x$sim_hours[2] - x$sim_hours[1])*60, "minutes \n")
    cat(paste("Simulation duration:"), (max(x$sim_hours)), "hours \n")
    cat(paste("Time points:"), nrow(x), "\n")
    cat("Parameters used (pvec input):\n")
    print(get_FIPS_pvec(x))
    cat("For descriptions of these parameters, inspect: ", help_function, "\n")
    cat("---------\n")
    print(tibble::as_tibble(x[,c("datetime","time","wake_status","sim_hours",get_FIPS_pred_cols(x))]))
  }
}



# summary.FIPS_simulation
#
# @method summary FIPS_simulation
#
# @export
summary.FIPS_simulation <- function(x) {

  if(FIPS_Simulation_lost_attributes(x)) {
    warning("Your FIPS_Simulation object has lost attributes (have you wrangled the dataframe with dplyr?). Dispatching method onwards.")
    NextMethod()
  } else {
      help_function = switch(get_FIPS_modeltype(x),
                           TPM = "help(FIPS::TPM_make_pvec)",
                           unified = "help(FIPS::unified_make_pvec)")
    cat("---------\n")
    cat(paste("Model Type:"), get_FIPS_modeltype(x), "\n")
    cat(paste("Epoch Value:"), (x$sim_hours[2] - x$sim_hours[1])*60, "minutes \n")
    cat(paste("Simulation duration:"), (max(x$sim_hours)), "hours \n")
    cat(paste("Time points:"), nrow(x), "\n")
    cat("Parameters used (pvec input):\n")
    print(get_FIPS_pvec(x))
    cat("For descriptions of these parameters, inspect: ", help_function, "\n")
    cat("---------\n")
    summary.data.frame(x[,c("datetime","time","wake_status","sim_hours",get_FIPS_pred_cols(x))])
  }
}
