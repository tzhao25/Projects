library(openxlsx)

# read data from excel
# GE
setwd("/Users/petra/Desktop/MyFile/Materials/LessonMaterials/UIUC/2019_Spring/Fin_Risk/HW/HW7")
GE = read.xlsx('F567C.s2019.HW7.GE data.xlsx',startRow = 6)
GE$date = convertToDateTime(GE$date + GE$time, origin='1900-01-01')
GE$time = NULL
GE$'time-step' = NULL
# Google
GOOGL = read.xlsx('F567C.s2019.HW7.GOOG data.xlsx',startRow = 6)
GOOGL$date = convertToDateTime(GOOGL$date + GOOGL$time, origin='1900-01-01')
GOOGL$time = NULL
GOOGL$'time-step' = NULL
GOOGL$X9 = NULL
GOOGL$X10 = NULL

# T1 & T3(a)
day_len = 391  # total 391 data points in one trading day
GE_RV1 = rep(NA,10)  # GE realized variance vector
GOOGL_RV1 = rep(NA,10)  # GOOGLE realized variance vector
for (i in 1:10){
  idx = i*day_len
  GE_close = GE$close[(idx-day_len+1):idx]
  GE_logrtn = diff(log(GE_close))
  GOOGL_close = GOOGL$close[(idx-day_len+1):idx]
  GOOGL_logrtn = diff(log(GOOGL_close))
  
  GE_RV1[i] = sum(GE_logrtn^2)
  GOOGL_RV1[i] = sum(GOOGL_logrtn^2)
}
T1_RV = cbind(GE_RV1, GOOGL_RV1)
T1_RV_avg = colMeans(T1_RV)
rm(i, idx, GE_logrtn, GE_close, GOOGL_logrtn, GOOGL_close, GE_RV1, GOOGL_RV1)

# T2(a)
cal_ARV = function(data,day_len,freq){
  this_ARV = rep(NA, 10)  # store average realized variance of 10 trading days
  # for each day in 10 trading days do the following
  for (i in 1:10){
    # select one day close price
    temp_idx = i*day_len
    data_close = data$close[(temp_idx-day_len+1):temp_idx]
    
    daily_ARV = rep(NA, freq)
    # calculate average realized variance of one trading day
    for (loop in 1:freq){
      idx = loop
      # index used to select specific minute price
      data_idx = c()
      while (idx <= length(data_close)){
        data_idx = c(data_idx, idx)
        idx = idx+freq
      }
      data_close = data_close[data_idx]
      
      # calculate log return
      logrtn = diff(log(data_close))
      daily_ARV[loop] = sum(logrtn^2)
    }
    
    this_ARV[i] = mean(daily_ARV)
  }
  return(this_ARV)
}
GOOGL_RVs = cbind(cal_ARV(GOOGL, day_len,1), cal_ARV(GOOGL, day_len, 2), cal_ARV(GOOGL, day_len, 5), cal_ARV(GOOGL, day_len, 10), cal_ARV(GOOGL, day_len, 15))
colnames(GOOGL_RVs) = c('1m','2m','5m','10m','15m')
GOOGL_RVs = rbind(GOOGL_RVs, colMeans(GOOGL_RVs))

# T2(b)
cal_ARV_T2b = function(data,day_len,freq){
  this_ARV = rep(NA, 10)  # store average realized variance of 10 trading days
  # for each day in 10 trading days do the following
  for (i in 1:10){
    # select one day close price
    temp_idx = i*day_len
    data_close = data$close[(temp_idx-day_len+1):temp_idx]
    
    daily_ARV = rep(NA, freq)
    # calculate average realized variance of one trading day
    for (loop in 1:freq){
      idx = loop
      # index used to select specific minute price
      data_idx = c()
      while (idx <= length(data_close)){
        data_idx = c(data_idx, idx)
        idx = idx+freq
      }
      data_close = data_close[data_idx]
      
      # calculate log return
      logrtn = diff(log(data_close))
      # store the first and last return when loop equal to 1
      if (loop == 1){
        first_rtn = logrtn[1]
        last_rtn = logrtn[length(logrtn)]
      }
      # if data does not start from the first data point
      else if (loop <= freq/2){
        logrtn = c(logrtn, last_rtn)  # add last return
      }
      else{
        logrtn = c(first_rtn, logrtn)  # add first return
      }
      
      daily_ARV[loop] = sum(logrtn^2)
    }
    
    this_ARV[i] = mean(daily_ARV)
  }
  return(this_ARV)
}
GOOGL_RVs_T2b = cbind(cal_ARV_T2b(GOOGL, day_len,1), cal_ARV_T2b(GOOGL, day_len, 2), cal_ARV_T2b(GOOGL, day_len, 5), cal_ARV_T2b(GOOGL, day_len, 10), cal_ARV_T2b(GOOGL, day_len, 15))

# T2(c)
colnames(GOOGL_RVs_T2b) = c('1m','2m','5m','10m','15m')
GOOGL_RVs_T2b = rbind(GOOGL_RVs_T2b, colMeans(GOOGL_RVs_T2b))
GOOGL_15to1_ratio = GOOGL_RVs_T2b[nrow(GOOGL_RVs_T2b),5] / GOOGL_RVs_T2b[nrow(GOOGL_RVs_T2b),1]
GOOGL_15to10_ratio = GOOGL_RVs_T2b[nrow(GOOGL_RVs_T2b),5] / GOOGL_RVs_T2b[nrow(GOOGL_RVs_T2b),4]

# T3(a)
GE_RVs_T3a = cbind(cal_ARV_T2b(GE, day_len, 1), cal_ARV_T2b(GE, day_len, 2), cal_ARV_T2b(GE, day_len, 5), cal_ARV_T2b(GE, day_len, 10), cal_ARV_T2b(GE, day_len, 15))
colnames(GE_RVs_T3a) = c('1m','2m','5m','10m','15m')
GE_RVs_T3a = rbind(GE_RVs_T3a, colMeans(GE_RVs_T3a))

# T3(b)
GE_15to1_ratio = GE_RVs_T3a[nrow(GE_RVs_T3a),5] / GE_RVs_T3a[nrow(GE_RVs_T3a),1]
GE_15to10_ratio = GE_RVs_T3a[nrow(GE_RVs_T3a),5] / GE_RVs_T3a[nrow(GE_RVs_T3a),4]







