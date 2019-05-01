sp500 = read.csv(file="/Users/tianhaozhao/Desktop/GSPC.csv")
dji = read.csv(file="/Users/tianhaozhao/Desktop/DJI.csv")
ixic = read.csv(file="/Users/tianhaozhao/Desktop/IXIC.csv")
RUT = read.csv(file="/Users/tianhaozhao/Desktop/RUT.csv")
logReturn_sp500 = diff(log(sp500$Adj.Close))
logReturn_dji = diff(log(dji$Adj.Close))
logReturn_ixic = diff(log(ixic$Adj.Close))
logReturn_rut = diff(log(RUT$Adj.Close))
sp500$log <- c(0,logReturn_sp500)
dji$log <- c(0,logReturn_dji)
ixic$log <- c(0,logReturn_ixic)
RUT$log <- c(0,logReturn_rut)

mean(tail(logReturn_sp500,2000))
mean(tail(logReturn_dji,2000))
mean(tail(logReturn_ixic,2000))
mean(tail(logReturn_rut,2000))

quantile(tail(logReturn_sp500,2000),0.05)
quantile(tail(logReturn_dji,2000),0.05)
quantile(tail(logReturn_ixic,2000),0.05)
quantile(tail(logReturn_rut,2000),0.05)






