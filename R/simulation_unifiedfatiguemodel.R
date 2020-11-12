#' Check Unified Parameter Vector
#'
#' Checks the pvec contains required parameters.
#'
#' @param pvec The pvec to check contains all required three process model parameters
#'
#' @return logical
unified_check_pvec <- function(pvec) {
  accepted_names = c("U0", "L0", "S0", "phi", "kappa", "tau_s", "tau_w", "tau_la", "sigma", "wc", "wd")
  diffvals = setdiff(names(pvec), accepted_names)
  if(length(diffvals) > 0) {
    error_msg = sprintf("Unified model fit halted!:\n [%s] \n is/are unsupported parameters\n Please remove these parameters before continuing.", diffvals)
    stop(call. = F, error_msg)
  }
  if(!all(accepted_names %in% names(pvec))) {
    stop(call. = F, "Unified model fit halted!:
         You have parameters missing (or renamed) in the supplied pvec.
         Please see help(unified_make_pvec) for information about the required parameters.")
  }
}


#' Make Model Default (pvec) Parameters
#'
#' The default unified model parameters from:
#' Ramakrishnan, S., Wesensten, N. J., Balkin, T. J., \& Reifman, J.
#' (2016). A Unified Model of Performance: Validation of its Predictions
#' across Different Sleep/Wake Schedules. \emph{Sleep}, \emph{39}(1),
#' 249--262. \url{https://doi.org/10.5665/sleep.5358}
#' @param U0 Upper asymptote (defaults to = 24.12)
#' @param L0 Lower asymptote(defaults to = 0,   # (0.88 * 3 - 2)*1.74)
#' @param S0 Initial starting point of S process (defaults to = 0,   # 1.11 + (1.74-1.11)*0.64)
#' @param phi Phase at beginning of the simulation (defaults to = 2.02)
#' @param kappa Relative influence of C process (defaults to = 4.13)
#' @param tau_s Controls rate of decay in S during sleep (defaults to = 1)
#' @param tau_w  Controls rate of rise in S during wake (defaults to = 40)
#' @param tau_la Rate of change in lower asymptote (defaults to = 4.06*24)
#' I don't think we have any particular reason to claim sigma is Bayesian error.
#' @param sigma Bayesian error - ignore unless you have error calculations (defaults to = 1)
#' @param wc Sleep inertia: extent of alertness reduction at time of waking (typically = -5.72) (defaults to = 1.14)
#' @param wd Sleep inertia: exponential recovery of alertness (typically = -1.51) (defaults to = -0.4)
#'
#' @export
unified_make_pvec <- function(
  U0 = 24.12,
  L0 = 0,
  S0 = 0,
  phi = 2.02,
  kappa = 4.13,
  tau_s = 1,
  tau_w = 40,
  tau_la = 4.06*24,
  sigma = 1,
  wc = 1.14,
  wd = -0.46) {
    # Essentially just allow user to change values, otherwise default
    pvec <- c(U0 = U0,  L0 = L0, S0 = S0, phi = phi, kappa = kappa, tau_s = tau_s,
    tau_w = tau_w, tau_la = tau_la, sigma = sigma, wc = wc, wd = wd)
    return(pvec)
}

#' Unified Model Default (pvec) Parameters
#'
#' The default unified model parameters from:
#'
#' Ramakrishnan, S., Wesensten, N. J., Balkin, T. J., \& Reifman, J.
#' (2016). A Unified Model of Performance: Validation of its Predictions
#' across Different Sleep/Wake Schedules. \emph{Sleep}, \emph{39}(1),
#' 249--262. \url{https://doi.org/10.5665/sleep.5358}
#'
#'
#' @export
unified_pvec = unified_make_pvec()

#' S Wake (Unified)
#' Calculates S during wake
#' @param s_at_wake S upon waking
#' @param taw Time awake
#' @param tau_w Controls rate of rise in S during wake
#' @param U0 Upper asymptote
unified_Sfun <- function(s_at_wake, taw, tau_w, U0) {
  r_coef = exp(-taw / tau_w)
  S = U0 - (U0 - s_at_wake) * r_coef
  return(S)
}

#' S Sleep (Unified)
#' Calculates S during sleep
#' @param ss S upon falling asleep
#' @param tas Time asleep
#' @param tau_s Controls rate of decay in S during sleep
#' @param U0 Upper asymptote
#' @param tau_la Rate of change in lower asymptote
#' @param ls Lower asymptote at sleep onset
unified_Spfun <- function(ss, tas, tau_s, U0, tau_la, ls) {
  term1 = ss * exp(-tas / tau_s)
  term2 = -2 * U0 * (1 - exp(-tas / tau_s))
  term3 = (((ls + 2 * U0) * tau_la) / (tau_la - tau_s)) *
          (exp(-tas / tau_la) - exp(-tas / tau_s))
  Sp = term1 + term2 + term3
  return(Sp)
}

#' Sleep Debt Penalty (L) Function during Wake
#' Calculates L / Sleep Debt Process during wake
#' @param l_at_wake  Lower asymptote at wake onset
#' @param taw Time awake
#' @param tau_la Rate of change in lower asymptote
#' @param U0 Upper asymptote
unified_Lfun <- function(l_at_wake, taw, tau_la, U0) {
  term1 = l_at_wake * exp(-taw / tau_la)
  term2 = U0 * (1 - exp(-taw / tau_la))
  L = term1 + term2
  return(L)
}

#' Sleep Debt Penalty (L) Function during Sleep
#' calculates L during sleep
#' @param ls Lower asymptote upon falling asleep
#' @param tas Time asleep
#' @param tau_la Rate of change in lower asymptote
#' @param U0 Upper asymptote
unified_Lpfun <- function(ls, tas, tau_la, U0) {
  L = ls * exp(-tas / tau_la) - (2 * U0) * (1 - exp(-tas / tau_la))
  return(L)
}

#' Unified Circadian Process (C)
#' calculates C (circadian process)
#' @param tod Time of day (in decimal hours)
#' @param phi Phase at beginning of the simulation (I think this should be 0 if t = tod)
#' @param tau Period of C process
#' @param A Amplitute of process
unified_Cfun <- function(tod, phi, tau = 24, A = 1) {
  omega = 2 * pi / tau
  term1 = 0.97 * sin(omega * (tod + phi))
  term2 = 0.22 * sin(2 * omega * (tod + phi))
  term3 = 0.07 * sin(3 * omega * (tod + phi))
  term4 = 0.03 * sin(4 * omega * (tod + phi))
  term5 = 0.0001 * sin(5 * omega * (tod + phi))
  C = A * (term1 + term2 + term3 + term4 + term5)
  return(C)
}

#' Sleep inertia function (direct 3PM import)
#' Caclulates effect of sleep intertia on alterness
#' @param taw Time awake
#' @param wc  Extent of alertness reduction at time of waking (typically = -5.72)
#' @param wd Rate of recovery of alterness (typically = -1.51)
unified_Wfun <- function(taw, wc, wd) {
  W = wc * exp(wd * taw)
  return(W)
}

unified_cols = c("s", "l", "c", "w", "lapses", "fatigue")
unified_append_model_cols <- function(.FIPS_df) {
  .FIPS_df[,unified_cols] = NA
  return(.FIPS_df)
}

#' Simulate: Unified Model
#'
#' Runs a full simulation of the 'Unified Model'.
#'
#' @section References:
#'
#' Rajdev, P., Thorsley, D., Rajaraman, S., Rupp, T. L., Wesensten, N. J.,
#' Balkin, T. J., \& Reifman, J. (2013). A unified mathematical model to
#' quantify performance impairment for both chronic sleep restriction and
#' total sleep deprivation. \emph{Journal of Theoretical Biology},
#' \emph{331}, 66--77. \url{https://doi.org/10.1016/j.jtbi.2013.04.013}
#'
#' Ramakrishnan, S., Wesensten, N. J., Balkin, T. J., \& Reifman, J.
#' (2016). A Unified Model of Performance: Validation of its Predictions
#' across Different Sleep/Wake Schedules. \emph{Sleep}, \emph{39}(1),
#' 249--262. \url{https://doi.org/10.5665/sleep.5358}
#'
#' @param pvec a vector of default parameters, see [unified_pvec]
#' @param dat input dataframe (ensure this is a FIPS_df)
#'
#' @seealso unified_make_pvec
#'
#' @return simulated dataset complete
#' @export
unified_simulate <- function(pvec, dat) {
  # check pvec
  unified_check_pvec(pvec)
  # Add the unified model columns
  dat = unified_append_model_cols(dat)

  # Initialise S and L
  if (dat$wake_status[1]) {
    s_at_wake = pvec["S0"]
    l_at_wake = pvec["L0"]
  } else {
    s_at_sleep = pvec["S0"]
    l_at_sleep = pvec["L0"]
  }

  # Simulation loop over FIPSdf
  for (i in 1:nrow(dat)) {

    # Calculate S and L at start of wake
    if (i > 1 & dat$change_point[i] == 1 & dat$switch_direction[i] == "Wake") {
      s_at_wake = unified_Spfun(s_at_sleep, dat$total_prev[i], pvec["tau_s"], pvec["U0"], pvec["tau_la"], l_at_sleep)
      l_at_wake = unified_Lpfun(l_at_sleep, dat$total_prev[i], pvec["tau_la"], pvec["U0"])
    }
    # Calculate S and L at start of sleep
    if (i > 1 & dat$change_point[i] == 1 & dat$switch_direction[i] == "Sleep") {
      s_at_sleep = unified_Sfun(s_at_wake, dat$total_prev[i], pvec["tau_w"], pvec["U0"])
      l_at_sleep = unified_Lfun(l_at_wake, dat$total_prev[i], pvec["tau_la"], pvec["U0"])
    }

    #Calculate S, L, and W at that point in time
    # wake_status == T == Awake
    if (dat$wake_status[i]) {
      dat$s[i] = unified_Sfun(s_at_wake, dat$status_duration[i], pvec["tau_w"], pvec["U0"])
      dat$l[i] = unified_Lfun(l_at_wake, dat$status_duration[i], pvec["tau_la"], pvec["U0"])
      dat$w[i] = unified_Wfun(dat$status_duration[i], pvec["wc"], pvec["wd"])
    } else {
      dat$s[i] = unified_Spfun(s_at_sleep, dat$status_duration[i], pvec["tau_s"], pvec["U0"], pvec["tau_la"], l_at_sleep)
      dat$l[i] = unified_Lpfun(l_at_sleep, dat$status_duration[i], pvec["tau_la"], pvec["U0"])
      dat$w[i] = 0
    }

    dat$c[i] = unified_Cfun(dat$time[i], pvec["phi"])
    dat$lapses[i] = dat$s[i] + pvec["kappa"] * dat$c[i]
    dat$fatigue[i] = dat$s[i] + pvec["kappa"] * dat$c[i]
  }


  # Assign as FIPS_simulation given the simulation is now successful
  dat <- FIPS_simulation(dat, modeltype = "unified", pvec = pvec, pred_stat_name = "fatigue", pred_cols = unified_cols)


  return(dat)

}
