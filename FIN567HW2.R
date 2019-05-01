##  FIN567 HW2 Q1
sp500 = read.csv(file="/Users/tianhaozhao/Desktop/FIN567/GSPC.csv")
dji = read.csv(file="/Users/tianhaozhao/Desktop/FIN567/DJI.csv")
ixic = read.csv(file="/Users/tianhaozhao/Desktop/FIN567/IXIC.csv")
RUT = read.csv(file="/Users/tianhaozhao/Desktop/FIN567/RUT.csv")

sp500.open <- sp500[1:1511,2]
sp500.close <- sp500[1:1511,6]
dji.open <- dji[1:1511,2]
dji.close <- dji[1:1511,6]
ixic.open <- ixic[1:1511,2]
ixic.close <- ixic[1:1511,6]
rut.open <- RUT[1:1511,2]
rut.close <- RUT[1:1511,6]

sp500.daychange <- c()
dji.daychange <- c()
ixic.daychange <- c()
rut.daychange <- c()
sp500.9change <- c()
dji.9change <- c()
ixic.9change <- c()
rut.9change <- c()
for(b in c(2:1511))
{
  sp500.daychange[b-1] <- (sp500.close[b] - sp500.open[b])/sp500.open[b]
  dji.daychange[b-1] <- (dji.close[b] - dji.open[b])/dji.open[b]
  ixic.daychange[b-1] <- (ixic.close[b] - ixic.open[b])/ixic.open[b]
  rut.daychange[b-1] <- (rut.close[b] - rut.open[b])/rut.open[b]
}
for(b in c(1:1510))
{
  sp500.9change[b] <- (sp500.open[b+1]-sp500.close[b])/sp500.close[b]
  dji.9change[b] <- (dji.open[b+1]-dji.close[b])/dji.close[b]
  ixic.9change[b] <- (ixic.open[b+1]-ixic.close[b])/ixic.close[b]
  rut.9change[b] <- (rut.open[b+1]-rut.close[b])/rut.close[b]
}
sp500.change <- sp500.9change+sp500.daychange
dji.change <- dji.9change+dji.daychange
ixic.change <- ixic.9change+ixic.daychange
rut.change <- rut.9change+rut.daychange

pos = 100000

sp500.PL <- (pos*sp500.change)
dji.PL <- (pos*dji.change)
ixic.PL <- (pos*ixic.change)
rut.PL <- (pos*rut.change)

var.sp500 <- c()
var.dji <- c()
var.ixic <- c()
var.rut <- c()

for (c in c(1006:1511))
{
  var.sp500[c-1005] <- -(quantile(sp500.PL[c-1000:c],0.01))
  var.dji[c-1005] <- -(quantile(dji.PL[c-1000:c],0.01))
  var.ixic[c-1005] <- -(quantile(ixic.PL[c-1000:c],0.01))
  var.rut[c-1005] <- -(quantile(rut.PL[c-1000:c],0.01))
}
dd <- dji$Date
date<-dd[1006:1511]
plot(date,var.sp500,xlim=c(1006,1511),ylim=c(500,3000), main = "VaR",xlab = "Date",ylab = "VaR")
lines(date,var.sp500, type = 'l', col = 'black')
lines(date,var.dji, type = 'l', col = 'green')
lines(date,var.ixic, type = 'l', col = 'blue')
lines(date,var.rut, type = 'l', col = 'red')
legend("bottomright",legend = c("SP500","DJI","IXIC","RUT"), col = c("black","green","blue","red"),lty = 1)

var.port <- var.sp500+var.dji+var.ixic+var.rut
plot(date,var.port, main = "Portfolio VaR", type = 'l', xlab = "Date",ylab = "VaR",xlim=c(1006,1511),col = 'black')
lines(date,var.port,type='l',col = 'black')


 