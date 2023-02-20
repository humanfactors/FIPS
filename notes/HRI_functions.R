library(FIPS)
library(tidyverse)

start_date = as.POSIXct("2018-05-01 08:00:00")

bitvector_sequence = rep(rep(c(0,1,0), 6), each = 8)

FIPSdf_from_bitvec = parse_sleepwake_sequence(
  seq = bitvector_sequence,
  series.start = start_date,
  epoch = 60)

names(FIPSdf_from_bitvec) <- str_replace(names(FIPSdf_from_bitvec), "wake", "work")

FIPS_work_df = FIPSdf_from_bitvec %>%
  rename(shift.id = sleep.id) %>%
  mutate(switch_direction = case_when(
    switch_direction == "0" ~ "0",
    switch_direction == "Wake" ~ "Rest",
    switch_direction == "Sleep" ~ "Work"
  )) %>%
  mutate(work_status_int  = 1 - work_status_int, work_status = !work_status)


# Risk_C = build up of risk
v_C_up_exp_E =  0.0487
v_C_up_exp_L =  0.0250
v_C_up_exp_N =  0.1215

v_QR_threshold = 9
# Constant: value for Quick return function (value = 0.06)
v_QR_c = 0.06

# Risk_C
# time needed to travel from home to work (in hours)
v_commute_hours = 1

# if day off: time of the day to estimate recovery
v_day_off_time = "15:00"

# Initial Value
CT0 = 1






# @ @ @ @ @ @ @ @
# Functions Core
# !! ----------- !!

# Cumulative function
risk_C_function = function(prev_risk_c, gap_since_last_work, commute_time) {
  risk_c = 1 + (prev_risk_c - 1) * (exp(-0.7888 * (gap_since_last_work - 2 * commute_time) / 24))
  return(risk_c)
}

tod_component = function(decimal.time) {
  ToD_c1 = 1
  ToD_c2 = 0.5047
  risk =  ToD_c1 + ToD_c2 * cos(2*pi*((decimal.time)/24))
  return(risk)
}

get_shift_type = function(decimalhour_vector) {
# Case when style return from decinal hours
# TODO: Note set the shift-type at the start of loop in one go
}

risk_C_dutyLevel = function() {

}




# !! INIT LOOP !! ##
# ------------------


work_df = FIPS_work_df
work_df$risk_c <- as.double(0)
work_df$risk_tod <- as.double(0)
work_df$risk_hos <- as.double(0)

work_df$risk_tod = tod_component(work_df$time)



for (i in 1:nrow(work_df)) {

  # Initialise values
  if (i == 1) {
    work_df$risk_c[i] = CT0
  }

  # Captures first sequence if starts on work
  if (i > 1 & !is.na(work_df$shift.id[i]) & work_df$shift.id[i] == 1) {
    work_df$risk_c[i] = work_df$risk_c[i - 1]
  }

  # Captures first sequence if starts on rest
  if (i > 1 & !work_df$work_status[i]) {
    if (work_df$risk_c[i - 1] == 1) {
      work_df$risk_c[i] = 1
      # This should actually be T0, not 1

    # If it's not the first in the sequence, or if the prior value is not 1, then we need to recalculate (i.e., recovery)
    } else {
      work_df$risk_c[i] = risk_C_function(
        prev_risk_c = work_df$risk_c[i - 1],
        gap_since_last_work = work_df$status_duration[i],
        commute_time = 2)
    }
  }

  # TODO: Note that we need to set the cummulative risk at the shift level

  # Now we work out on shift risk (cumulative component risk C)
  if (work_df$work_status[i] & work_df$change_point[i] == 1) {
    if (work_df$shift.id[i] > 1) {


      # Main cummulative risk on SHIFT level
          }
    if (RSE_data$duty_or_off[i] == "duty" & RSE_data$shift_seq[i] > 1 ) { 
      
    #   if (RSE_data$gap_previous[i] >= 9) {
    #     RSE_data$Risk_C_formula[i] = "Sequence"
    #     if (RSE_data$shift_type[i]  == "E") {C_up_exp = v_C_up_exp_E }
    #     if (RSE_data$shift_type[i]  == "L") {C_up_exp = v_C_up_exp_L }
    #     if (RSE_data$shift_type[i]  == "N") {C_up_exp = v_C_up_exp_N }
    #     # old: RSE_data$Risk_C[i] =   Risk_C_first_in_seq*exp(C_up_exp*(RSE_data$shift_seq[i]-1))    
    #     RSE_data$Risk_C[i] =   RSE_data$Risk_C[i-1]*exp(C_up_exp)    



      # Quick returns
      if(work_df$total_prev[i] <= v_QR_threshold) {
        work_df$risk_c[i] = work_df$risk_c[i-1] + v_QR_c*(v_QR_threshold - work_df$total_prev[i])}
    }
  }


}



within(work_df, {
  HRI <- risk_c * risk_tod * risk_hos
})

view(work_df)
