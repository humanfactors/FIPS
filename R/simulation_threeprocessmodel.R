#' Check Three Process Parameter Vector
#'
#' Checks the pvec contains required parameters.
#'
#' @param pvec The pvec to check contains all required three process model parameters
#'
#' @return logical
TPM_check_pvec <- function(pvec) {
  accepted_names = c("la", "ha", "d", "g", "bl", "Cm", "Ca", "p", "Um", "Ua", "Wc", "Wd", "S0", "KSS_intercept", "KSS_beta")
  diffvals = setdiff(names(pvec), accepted_names)
  if(length(diffvals) > 0) {
    error_msg = sprintf("Three Process Model fit halted!:\n [%s] \n is/are unsupported parameters\n Please remove these parameters before continuing.", diffvals)
    stop(call. = F, error_msg)
  }
  if(!all(accepted_names %in% names(pvec))) {
    stop(call. = F, "Three Process Model fit halted!:
         You have parameters missing (or renamed) in the supplied pvec.
         Please see help(TPM_make_pvec) for information about the required parameters.")
  }
}




#' Make Three Process Model (TPM) Parameter Vector
#'
#' Creates and checks a TPM parameter vector. No arguments returns default settings from
#' Ingre, M., Van Leeuwen, W., Klemets, T., Ullvetter, C., Hough, S., Kecklund, G., Karlsson, D., & Åkerstedt, T. (2014). Validating and Extending the Three Process Model of Alertness in Airline Operations. *PLoS ONE*, *9*(10), e108679. <https://doi.org/10.1371/journal.pone.0108679>
#'
#' @param la Low asymptote. Minimum alertness allowed by homeostatic process (S)
#' @param ha High asymptote. Maximum alertness allowed by homeostatic process (S)
#' @param d Alertness decay rate. Rate at which alterness decays when awake (homestatic process)
#' @param g Fatigue recovery rate per unit time. Rate at which alertness recovers when asleep
#' @param bl Alertness level that breaks Sprime function. The alertness level at which low pressure sleep kicks in
#' @param Cm Mesor of C process (average level) for 24-hour circadian (C) process
#' @param Ca Amplitude of C process (extent to which peaks deviate from average level) for 24-hour circadian (C) process
#' @param p  Default C process phase (i.e., peak) for 24-hour circadian (C) process
#' @param Um Mesor of U process (average level) for 12-hour circadian (U) process (dip in afternoon)
#' @param Ua Amplitude of U process process (extent to which peaks deviate from average level) for 12-hour circadian (U) process (dip in afternoon)
#' @param Wc Initial reduction in alertness for sleep inertia (W) process
#' @param Wd Recovery rate for sleep inertia (W) process
#' @param S0 Initial value of homeostatic process (S)
#' @param KSS_intercept KSS transformation intercept
#' @param KSS_beta KSS transformation beta
#'
#' @md
#' @return parameter vector
#' @export
TPM_make_pvec <- function(
  la = 2.4,
  ha = 14.3,
  d = -0.0353,
  g = log((14.3 - 14) / (14.3 - 7.96)) / 8,
  bl = 12.2,
  Cm = 0,
  Ca = 2.5,
  p = 16.8,
  Um = -0.5,
  Ua = 0.5,
  Wc = -5.72,
  Wd = -1.51,
  S0 = 7.96,
  KSS_intercept = 10.6,
  KSS_beta = -0.6) {
  # Essentially just allow user to change values, otherwise default
  pvec <- c(la = la, ha = ha, d = d, g = g, bl = bl, Cm = Cm, Ca = Ca, p = p,
            Um = Um, Ua = Ua, Wc = Wc, Wd = Wd, S0 = S0, KSS_intercept = KSS_intercept,
            KSS_beta = KSS_beta)
  TPM_check_pvec(pvec)
  return(pvec)
}

#' pvec.threeprocess
#' Here for compatability - will likely remove soon
#' @export
pvec.threeprocess <- TPM_default_pvec <- TPM_make_pvec()

#' TPM Wake S Function
#'
#' Calculates S process during wake
#'
#' @param la Lower asymptote (typically = 2.4)
#' @param d Decay in alertness (typically = -0.0353)
#' @param sw S upon waking
#' @param taw Time awake (hours)
#'
#' @return S
TPM_Sfun <- function(la, d, sw, taw) {
  S = la + (sw - la) * exp(d * taw)
  return(S)
}



#' TPM Sleep S Function
#'
#' Calculates S during sleep
#'
#' @param ha High asymptote (typically = 14.3)
#' @param g Rate of recovery (typically about -0.3813)
#' @param bl Break point of sleep recovery (typically 12.2)
#' @param ss S at falling asleep
#' @param tas Time asleep (hours)
#'
#' @return S
TPM_Spfun <- function(ha, g, bl, ss, tas) {
  breaktime = TPM_breaktimefun(ha, g, bl, ss)
  if (tas <= breaktime) { S = TPM_Sp1fun(ha, g, bl, ss, tas) }
  if (tas > breaktime) { S = TPM_Sp2fun(ha, g, bl, tas, breaktime) }
  return(S)
}



#' TPM_Sp1fun
#'
#' Calculates S during high pressure component of sleep before break point is reached
#' @param ha High asymptote (typically = 14.3)
#' @param g Rate of recovery (typically about -0.3813)
#' @param bl Break point (typically 12.2)
#' @param ss S upon falling asleep
#' @param tas Time asleep (hours)
#'
#' @return S
TPM_Sp1fun <- function(ha, g, bl, ss, tas) {
  Sp1 = ss + tas * (g * (bl - ha))
  return(Sp1)
}



#' TPM_Sp2fun
#'
#' Calculates S during lower pressure component of sleep after break point is reached
#'
#' @param ha High asymptote (typically = 14.3)
#' @param g Rate of recovery (typically about -0.3813)
#' @param bl Break point (typically 12.2)
#' @param tas Time asleep (hours)
#' @param breaktime Break time (time from sleep until breakpoint is reached)
#'
#' @return S
TPM_Sp2fun <- function(ha, g, bl, tas, breaktime) {
  Sp2 = ha - (ha - bl) * exp(g * (tas - breaktime))
  return(Sp2)
}



#' Break time function (i.e., bt function)
#'
#' @param ha High asymptote (typically = 14.3)
#' @param g Rate of recovery (typically about -0.3813)
#' @param bl Break point (typically 12.2)
#' @param ss S upon falling asleep
#'
#' @return breaktime
TPM_breaktimefun <- function(ha, g, bl, ss) {
  breaktime = (bl - ss) / (g * (bl - ha))
  return(breaktime)
}



#' Sleep Inertia (W) Function
#'
#' Calculates effect of sleep inertia on alertness
#'
#' @param Wc Extent of alertness reduction at time of waking (typically = -5.72)
#' @param Wd Exponential recovery of alertness (typically = -1.51)
#' @param taw Time awake (hours)
#'
#' @return W
TPM_Wfun <- function(Wc, Wd, taw) {
  W = Wc * exp(Wd * taw)
  return(W)
}



#' TPM C Function (24-hour circadian process)
#'
#' Calculates 24-hour circadian process.
#'
#' @param Cm Mesor of C process (typically = 0)
#' @param Ca Amplitude of C process (typically = 2.5)
#' @param p Default C phase (i.e., time of peak typically 16.8)
#' @param tod Time of day (in decimal hours)
#'
#' @return C
TPM_Cfun <- function(Cm, Ca, p, tod) {
  C = Cm + Ca * cos((2 * pi / 24) * (tod - p))
  return(C)
}



#' TPM U Function (12-hour circadian process)
#'
#' Calculates 12-hour circadian process.
#'
#' @param Um Mesor of U process (typically = -0.5)
#' @param Ua Amplitude of U process (typically = 0.5)
#' @param p Default C phase (i.e., time of peak typically 16.8)
#' @param tod Time of day (in decimal hours)
#'
#' @return U
TPM_Ufun <- function(Um, Ua, p, tod) {
  U = Um + Ua * cos((2 * pi / 12) * (tod - p - 3))
  return(U)
}

TPM_cols = c("s", "c", "w", "u", "alertness", "KSS")
TPM_append_model_cols <- function(.FIPS_df) {
  .FIPS_df[,TPM_cols] <- NA
  return(.FIPS_df)
}


#' Simulate: Three Process Model
#'
#' Simulates three process model over specified period.
#' Default parameters (la through S0) are constants used in previous applications of the model.
#'
#' Access the modelled tibble directly via `simulation.object$FIPS_df`. This also enables you to choose
#' which parameters you would like in your final model.
#'
#' @section Parameters:
#'
#' S function (homeostatic process)
#' la = low asymptote (default = 2.4)
#' ha = high asymptote (default = 14.3)
#' d = rate of decay in alertness when awake (default = -0.0353)
#' g = rate of recovery in alertness when asleep (default = log((ha-14)/(ha-7.96))/8)
#' bl = break level in alertness, time at which low pressure sleep kicks in (default = 12.2)
#'
#'
#' C function (24-circadian process)
#'   Cm = average level of process (i.e., mesor; default = 0)
#'   Ca = amplitude of process (default = 2.5)
#'   p = phase or time at which process reaches its peak (default = 16.8)
#'
#' U function (12-hour circadian process)
#'   Um = average level of process (i.e., mesor; default = -0.5)
#'   Ua = amplitude of process (default = 0.5)
#'
#' W function (sleep intertia process)
#'   Wc = Initial reduction in alertness at time of waking (default = -5.72)
#'   Wd = Rate of recovery of alertness (default = -1.51)
#'
#' Regression equation for converting alertness to KSS fatigue ratings
#' a = intercept (default = 10.6)
#' b = coefficient (default = -0.6)
#'
#' @param pvec a vector of default parameters
#' @param dat input dataframe (ensure this is in FIPS format)
#' @seealso TPM_make_pvec
#' @return dataframe with simulated values - where fatigue middle is estimate (if no error terms)
#' @md
#' @export
TPM_simulate <- function(pvec, dat) {

  TPM_check_pvec(pvec)
  dat = TPM_append_model_cols(dat)

  for (i in 1:nrow(dat)) {

    # Initialise S for first observation
    if (i == 1) {
      s_at_wake = pvec["S0"]
      s_at_sleep = pvec["S0"]
    }

    # Calculate S at start of wake
    if (i > 1 & dat$change_point[i] == 1 & dat$switch_direction[i] == "Wake") {
      s_at_wake = TPM_Spfun(pvec["ha"], pvec["g"], pvec["bl"], ss = s_at_sleep, tas = dat$total_prev[i])
    }
    # Calculate S at start of sleep
    if (i > 1 & dat$change_point[i] == 1 & dat$switch_direction[i] == "Sleep") {
      s_at_sleep = TPM_Sfun(la = pvec["la"], d = pvec["d"], sw = s_at_wake, taw = dat$total_prev[i])
    }
    # If Awake, else sleep
    if (dat$wake_status[i]) {
      dat$s[i] = TPM_Sfun(la = pvec["la"], d = pvec["d"], sw = s_at_wake, taw = dat$status_duration[i])
      dat$w[i] = TPM_Wfun(Wc = pvec["Wc"], Wd = pvec["Wd"], taw = dat$status_duration[i])
    } else {
      dat$s[i] = TPM_Spfun(pvec["ha"], pvec["g"], pvec["bl"], s_at_sleep, dat$status_duration[i])
      dat$w[i] = 0
    }

    dat$c[i] = TPM_Cfun(Cm = pvec["Cm"], Ca = pvec["Ca"], p = pvec["p"],tod = dat$time[i])
    dat$u[i] = TPM_Ufun(Um = pvec["Um"], Ua = pvec["Ua"], p = pvec["p"],tod = dat$time[i])

    dat$alertness[i] = dat$s[i] + dat$c[i] + dat$u[i]
    dat$KSS[i] = pvec["KSS_intercept"] + pvec["KSS_beta"] * (dat$s[i] + dat$c[i] + dat$u[i])

  }

  # Assign as FIPS_simulation given the simulation is now successful
  dat <- FIPS_simulation(dat, modeltype = "TPM", pvec = pvec, pred_stat = "alertness", pred_cols = TPM_cols)

  return(dat)

}




