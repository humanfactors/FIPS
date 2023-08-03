HRI_make_pvec <- function(
    # Risk_C = build up of risk
  v_C_up_exp_E =  0.0487,
  v_C_up_exp_L =  0.0250,
  v_C_up_exp_N =  0.1215,
  v_QR_threshold = 9,
  v_QR_c = 0.06, # Constant: value for Quick return function (value = 0.06)
  v_commute_hours = 1,
  v_day_off_time = "15:00" # if day off: time of the day to estimate recovery
) {
  # Essentially just allow user to change values, otherwise default
  return(c(
    v_C_up_exp_E = v_C_up_exp_E,
    v_C_up_exp_L = v_C_up_exp_L,
    v_C_up_exp_N = v_C_up_exp_N,
    v_QR_threshold = v_QR_threshold,
    v_QR_c = v_QR_c,
    v_commute_hours = v_commute_hours,
    v_day_off_time = v_day_off_time))
    }