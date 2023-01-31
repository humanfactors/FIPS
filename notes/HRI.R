library(tidyverse)
library(lubridate)
  

input_data  = read_delim("HRI_input.csv") 
input_data = input_data[, c('RSE_ID','PrestDate', 'Begin', 'End','Duty_ID', 'Duty_Name'  )]
no_of_RSE = length(unique(unlist(input_data$RSE_ID)))


# Parameters

# Risk_C = build up of risk
v_C_up_exp_E =  0.0487
v_C_up_exp_L =  0.0250
v_C_up_exp_N =  0.1215

# Risk_C 
# time needed to travel from home to work (in hours)
v_commute_hours = 1 

# if day off: time of the day to estimate recovery
v_day_off_time = "15:00"  


# -----------------
mod_data = input_data

mod_data$duty_or_off  = ifelse(!is.na(as.character(mod_data$Begin)),    "duty" ,  "off")

mod_data$PrestDate =  strptime( mod_data$PrestDate, format="%d/%m/%Y", tz = "EST") 

mod_data$timestamp_begin = strptime( ifelse(mod_data$duty_or_off != "off",   
                                            paste(mod_data$PrestDate, mod_data$Begin)  , 
                                            # day off: = day_off_time, eg 15:00
                                            paste(mod_data$PrestDate, v_day_off_time)   ), format="%Y-%m-%d %H:%M", tz = "EST")  

mod_data$timestamp_begin = as.POSIXlt( ifelse(mod_data$duty_or_off != "off",   
                                              paste(mod_data$PrestDate, mod_data$Begin)  , 
                                              # day off: = day_off_time, eg 15:00
                                              paste(mod_data$PrestDate, v_day_off_time)   ), format="%Y-%m-%d %H:%M")

mod_data$timestamp_end =  as.POSIXlt(ifelse(   (strptime(mod_data$End, format = "%H:%M:%OS", tz = "EST") - strptime(mod_data$Begin, format = "%H:%M:%OS", tz = "EST")  > 0), 
                                               paste(mod_data$PrestDate, mod_data$End), 
                                               paste(  format(mod_data$PrestDate + 1*24*60*60, format = "%Y-%m-%d") ,   mod_data$End)),format="%Y-%m-%d %H:%M")   

mod_data$duty_length = as.numeric(difftime( mod_data$timestamp_end, mod_data$timestamp_begin , units ="hours"))
# mod_data$timestamp_end -  mod_data$timestamp_begin 



# determine shift type (E, L, N or day off)
mod_data$hour_begin = as.numeric(format( mod_data$timestamp_begin , format = "%H"))
mod_data$shift_type  = ifelse(mod_data$duty_or_off == "off",    "off" , 
                              ifelse(mod_data$hour_begin < 9, "E", ifelse(mod_data$hour_begin > 19, "N", "L"))) 



# HRI components
mod_data$Risk_C_formula = as.character(NA) 
mod_data$Risk_C= as.numeric(NA) 

mod_data$shift_seq =  as.numeric(NA) 
mod_data$last_shift_end = as.POSIXct(NA)
mod_data$gap_previous =  as.POSIXct(NA)

mod_data$Risk_C_formula = as.character(NA)
# mod_data$Risk_C_first_in_seq = as.character(NA)
mod_data$Risk_C =   as.numeric(NA)

mod_data$Risk_C_formula[1] = "Start"
mod_data$Risk_C = as.numeric(NA)



staff_IDs <- unique(unlist(mod_data$RSE_ID))
staff_IDs



# TODO: FOCUS ON A SINGLE RSEID


# CAN REMOVE THIS

  RSE_data = subset(mod_data, RSE_ID == "50575975")
  # first record
  RSE_data$shift_seq[1] =  1 
  
  
  for(i in 2:nrow(RSE_data)) { 
    
    # determine  sequence (shifts or days off): 
    #-------------------------------------------------------
    if (   RSE_data$duty_or_off[i] != RSE_data$duty_or_off[i-1])
      # first in new sequence of shifts
    {
      RSE_data$shift_seq[i] = 1  
      # if (   RSE_data$duty_or_off[i] == "off"){  RSE_data$last_shift_end[i] =  RSE_data$timestamp_end[i-1]}
    } 
    else
    {
      RSE_data$shift_seq[i] = RSE_data$shift_seq[i-1] + 1}
    # RSE_data$last_shift_end[i] =  RSE_data$last_shift_end[i-1]
    
    
    # if day off: end time of last shift
    
    if (   RSE_data$duty_or_off[i] == "off"  &  RSE_data$shift_seq[i] == 1){  RSE_data$last_shift_end[i] =  RSE_data$timestamp_end[i-1]}
    if (   RSE_data$duty_or_off[i] == "off"  &  RSE_data$shift_seq[i] > 1){  RSE_data$last_shift_end[i] =  RSE_data$last_shift_end[i-1]}
    if (   RSE_data$duty_or_off[i] == "duty" &  RSE_data$shift_seq[i] == 1){  RSE_data$last_shift_end[i] =  RSE_data$last_shift_end[i-1]}
    if (   RSE_data$duty_or_off[i] == "duty" &  RSE_data$shift_seq[i] > 1 ){  RSE_data$last_shift_end[i] =  RSE_data$timestamp_end[i-1]}
    #RSE_data$last_shift_end[i] =  RSE_data$timestamp_end[i-1]
  }
  
  RSE_data$gap_previous = difftime(RSE_data$timestamp_begin, RSE_data$last_shift_end)
  
  # **************************************************************
  # perform HRI calculations
  # ************************************************************** 
  # first day (duty or off): always start with  Risk_C = 1 at the beginning of roster data
  RSE_data$Risk_C[1] = 1
  # Risk_C_first_in_seq = 1
  
  # --------------------------- 
  # A. DAILY: Risk_C = cumulative risk
  # --------------------------- 
  
  for(i in 2:nrow(RSE_data)) { 
    
    # for debugging
    # print(paste( RSE_data$RSE_ID[i], ' ',  RSE_data$Duty_ID[i]))
    
    if (RSE_data$duty_or_off[i] == "off"  ) { 
      RSE_data$Risk_C_formula[i] = "Recovery"
      if (RSE_data$Risk_C[i-1] == 1 ) {
        RSE_data$Risk_C[i] = 1     # if previous days are first days in data => no RSE_data$gap_previous needed, and risk_C = 1
      } else {    
        RSE_data$Risk_C[i] = 1 + (RSE_data$Risk_C[i-1] -1)*exp(-0.7888*(as.numeric(RSE_data$gap_previous[i] -2*v_commute_hours)/24))
      }  
      #Risk_C_first_in_seq[i] = RSE_data$Risk_C[i] 
    }
    if (RSE_data$duty_or_off[i] == "duty" & RSE_data$shift_seq[i] == 1 ) { 
      RSE_data$Risk_C_formula[i] = "Sequence (1st)"
      
      if (RSE_data$Risk_C[i-1] == 1 ) {
        RSE_data$Risk_C[i] = 1     # if previous days are first days in data => no RSE_data$gap_previous needed, and risk_C = 1
      }else{    
        RSE_data$Risk_C[i] = 1+ (RSE_data$Risk_C[i-1] -1)*exp(-0.7888*(as.numeric(RSE_data$gap_previous[i] -2*v_commute_hours)/24))
      }  
      # Risk_C_first_in_seq = RSE_data$Risk_C[i] 
    }
    if (RSE_data$duty_or_off[i] == "duty" & RSE_data$shift_seq[i] > 1 ) { 
      
      if (RSE_data$gap_previous[i] >= 9) {
        RSE_data$Risk_C_formula[i] = "Sequence"
        if (RSE_data$shift_type[i]  == "E") {C_up_exp = v_C_up_exp_E }
        if (RSE_data$shift_type[i]  == "L") {C_up_exp = v_C_up_exp_L }
        if (RSE_data$shift_type[i]  == "N") {C_up_exp = v_C_up_exp_N }
        # old: RSE_data$Risk_C[i] =   Risk_C_first_in_seq*exp(C_up_exp*(RSE_data$shift_seq[i]-1))    
        RSE_data$Risk_C[i] =   RSE_data$Risk_C[i-1]*exp(C_up_exp)    
      } else {    
        RSE_data$Risk_C_formula[i] = "Quick return"
        RSE_data$Risk_C[i] =   RSE_data$Risk_C[i-1] + 0.06*(9- RSE_data$gap_previous[i])    
      }
    }
  }
  
  
  # --------------------------- 
  # B. HOURLY
  # --------------------------- 
  
  # duplicate rows with daily data => hourly data
  # RSE_data$gap_previous[1] = 1  # tijdelijk => start = 1 "uur"
  # dat_hourly = data.frame(lapply(dat, rep, RSE_data$gap_previous))
  
  # duplicate duplicate duty_length times if duty_or_off = "duty". No duplication if day off
  RSE_data_hourly <- RSE_data[rep(row.names(RSE_data), ifelse(RSE_data$duty_or_off=="duty",RSE_data$duty_length,1) ),]
  
  # RSE_data[rep(row.names(RSE_data), ifelse(RSE_data$duty_or_off=="duty",RSE_data$duty_length,1) ),]
  
  
  
  # **************
  # add fields = 
  # **************
  
  RSE_data_hourly$Date = as.POSIXct(NA)
  RSE_data_hourly$HoS = as.numeric(NA)
  RSE_data_hourly$ToD = as.numeric(NA)
  
  RSE_data_hourly$Risk_HoS = as.numeric(NA) 
  RSE_data_hourly$Risk_ToD = as.numeric(NA) 
  RSE_data_hourly$HRI= as.numeric(NA) 
  
  # add Date of HRI (< > PrestDate = Duty starting date)
  RSE_data_hourly$Date = RSE_data_hourly$PrestDate # correct further on for midnight
  
  
  # **************************************************************
  # perform hourly calculations (only within duties)
  # ************************************************************** 
  
  # if i = 1 (first record) and first hour in duty: set HoS = 1
  if(RSE_data_hourly$duty_or_off[1] == "duty" )  {
    RSE_data_hourly$HoS[1] = 1
    RSE_data_hourly$ToD[1] =  RSE_data_hourly$hour_begin[1]
    RSE_data_hourly$Date[1] = RSE_data_hourly$PrestDate[1]
  }
  
  # next hours 
  for(i in 2:nrow(RSE_data_hourly)) { 
    # if Duty
    if(RSE_data_hourly$duty_or_off[i] =="duty"   ){
      # --------------------------- 
      # B. HOURLY: Risk_HoS = Hours-on_Shift risk
      # --------------------------- 
      
      #  check if same shift 
      # !!! => DIT NOG VERBTEREN !! is nog te veel om issues in HMY data op te vangen en dus niet generiek
      # eventueel bij controles vooraf: er mag maar ��n duty record zijn per dag 
      if ((RSE_data_hourly$Duty_ID[i] == RSE_data_hourly$Duty_ID[i-1])  & (RSE_data_hourly$timestamp_begin[i] == RSE_data_hourly$timestamp_begin[i-1])) 
        
      {
        RSE_data_hourly$HoS[i] = RSE_data_hourly$HoS[i-1] + 1
      }else{
        RSE_data_hourly$HoS[i] = 1
      }
      # RSE_data_hourly$Risk_HoS[i]  = -0.048  + 0.892*RSE_data_hourly$HoS[i] - 0.203*(RSE_data_hourly$HoS[i]^2) + 0.014*(RSE_data_hourly$HoS[i]^3)
      
      
      # --------------------------- 
      # B. HOURLY: Risk_ToD = Time-of_Day
      # ---------------------------  
      RSE_data_hourly$ToD[i] =  RSE_data_hourly$hour_begin[i] + (RSE_data_hourly$HoS[i] -1) 
      # correct for night shifts
      if(RSE_data_hourly$ToD[i] > 23){
        RSE_data_hourly$Date[i] = format(RSE_data_hourly$Date[i] + 1*24*60*60, format = "%Y-%m-%d")     # correct the Date
        RSE_data_hourly$ToD[i] = RSE_data_hourly$ToD[i] -24                               # correct the ToD
        
      }
      
      
      
      
      
    }
    
  }   
  
  # --------------------------- 
  #  calculate risks
  # --------------------------- 
  
  RSE_data_hourly$Risk_HoS  = -0.048  + 0.892*RSE_data_hourly$HoS - 0.203*(RSE_data_hourly$HoS^2) + 0.014*(RSE_data_hourly$HoS^3)
  RSE_data_hourly$Risk_ToD = 1 + 0.5047*cos(2*pi*((RSE_data_hourly$ToD + 0.5)/24))  # ToD risk (at mid hour) 
  RSE_data_hourly$HRI = RSE_data_hourly$Risk_C*RSE_data_hourly$Risk_ToD*RSE_data_hourly$Risk_HoS
  
  # **************************************************************
  # export results
  # **************************************************************
  
  
  if(RSE==1){
    dat_results = RSE_data_hourly
  }else{
    dat_results =  rbind(dat_results, RSE_data_hourly) 
  }
  
} # next RSE_ID     

