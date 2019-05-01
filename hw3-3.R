## Dale W.R. Rosenthal, 2018
## You are free to distribute and use this code so long as you attribute
## it to me or cite the text.
## The legal disclaimer in _A Quantitative Primer on Investments with R_
## applies to this code.  Use or distribution without these comment lines
## is forbidden.
library(xts)
library(Quandl)
library(quantmod)

# Get risk-free rate
# daily
rf.raw <- Quandl("FRED/DGS3MO", type="xts")/100
rf.raw <- rf.raw/250
colnames(rf.raw) <- c("T3M")

# Get S&P 500, Russell 2000, and stock returns
adj.close <- 6  # 6th field is adjusted close
equity.tickers <- c("^GSPC","^RUT","BA","GD","HON","LMT","NOC","QCOM","RTN","UTX")
prices <- getSymbols(equity.tickers[1], source="yahoo", auto.assign=FALSE,
                     return.class="xts")[,adj.close]
for (i in 2:length(equity.tickers)) {
  prices.tmp <- getSymbols(equity.tickers[i], source="yahoo",
                           auto.assign=FALSE, return.class="xts")[,adj.close]
  prices <- cbind(prices, prices.tmp)
}
equity.names <- c("SPX","RUT","BA","GD","HON","LMT","NOC","QCOM","RTN","UTX")
colnames(prices) <- equity.names
returns <- diff(log(prices))

# Now we join all of the datasets together and trim to recent
alldata <- cbind(rf.raw, returns)["20141001/20181001"]

# create excess returns
equity.names.xs <- paste(equity.names, ".xs", sep="")
# now in a for loop subtract off a daily risk-free rate, for example:
#alldata$SPX.xs <- alldata$SPX - alldata$T3M/250

# If your ticker were DAL and you wanted to model returns
# (not excess returns) using ESTOX and SMI, you would do like so:
#simple.wrong.model <- lm(DAL ~ ESTOX + SMI, data=alldata)
#summary(simple.wrong.model)
# NOTE that this is not the model you are supposed to do

#***3.1***
#----------------------------------SP500--------------------------------
# create excess returns
alldata$SPX.xs <- alldata$SPX - alldata$T3M

#1) BA
BA_data <-cbind(alldata$BA, alldata$T3M, alldata$SPX.xs)
BA_data <- na.omit(BA_data)

BA.model <- lm(BA_data$BA - BA_data$T3M ~ BA_data$SPX.xs, BA_data)
summary(BA.model)

#2) GD
GD_data <-cbind(alldata$GD, alldata$T3M, alldata$SPX.xs)
GD_data <- na.omit(GD_data)

GD.model <- lm(GD_data$GD - GD_data$T3M ~ GD_data$SPX.xs, GD_data)
summary(GD.model)

#3) HON
HON_data <-cbind(alldata$HON, alldata$T3M, alldata$SPX.xs)
HON_data <- na.omit(HON_data)

HON.model <- lm(HON_data$HON - HON_data$T3M ~ HON_data$SPX.xs, HON_data)
summary(HON.model)

#4) LMT
LMT_data <-cbind(alldata$LMT, alldata$T3M, alldata$SPX.xs)
LMT_data <- na.omit(LMT_data)

LMT.model <- lm(LMT_data$LMT - LMT_data$T3M ~ LMT_data$SPX.xs, LMT_data)
summary(LMT.model)

#5) NOC
NOC_data <-cbind(alldata$NOC, alldata$T3M, alldata$SPX.xs)
NOC_data <- na.omit(NOC_data)

NOC.model <- lm(NOC_data$NOC - NOC_data$T3M ~ NOC_data$SPX.xs, NOC_data)
summary(NOC.model)

#6) QCOM
QCOM_data <-cbind(alldata$QCOM, alldata$T3M, alldata$SPX.xs)
QCOM_data <- na.omit(QCOM_data)

QCOM.model <- lm(QCOM_data$QCOM - QCOM_data$T3M ~ QCOM_data$SPX.xs, QCOM_data)
summary(QCOM.model)

#7) RTN
RTN_data <-cbind(alldata$RTN, alldata$T3M, alldata$SPX.xs)
RTN_data <- na.omit(RTN_data)

RTN.model <- lm(RTN_data$RTN - RTN_data$T3M ~ RTN_data$SPX.xs, RTN_data)
summary(RTN.model)

#8) UTX
UTX_data <-cbind(alldata$UTX, alldata$T3M, alldata$SPX.xs)
UTX_data <- na.omit(UTX_data)

UTX.model <- lm(UTX_data$UTX - UTX_data$T3M ~ UTX_data$SPX.xs, UTX_data)
summary(UTX.model)

#----------------------------------Russell2000--------------------------------
# create excess returns
alldata$RUT.xs <- alldata$RUT - alldata$T3M
#1) BA
BA_data <-cbind(alldata$BA, alldata$T3M, alldata$RUT.xs)
BA_data <- na.omit(BA_data)

BA.model <- lm(BA_data$BA - BA_data$T3M ~ BA_data$RUT.xs, BA_data)
summary(BA.model)

#2) GD
GD_data <-cbind(alldata$GD, alldata$T3M, alldata$RUT.xs)
GD_data <- na.omit(GD_data)

GD.model <- lm(GD_data$GD - GD_data$T3M ~ GD_data$RUT.xs, GD_data)
summary(GD.model)

#3) HON
HON_data <-cbind(alldata$HON, alldata$T3M, alldata$RUT.xs)
HON_data <- na.omit(HON_data)

HON.model <- lm(HON_data$HON - HON_data$T3M ~ HON_data$RUT.xs, HON_data)
summary(HON.model)

#4) LMT
LMT_data <-cbind(alldata$LMT, alldata$T3M, alldata$RUT.xs)
LMT_data <- na.omit(LMT_data)

LMT.model <- lm(LMT_data$LMT - LMT_data$T3M ~ LMT_data$RUT.xs, LMT_data)
summary(LMT.model)

#5) NOC
NOC_data <-cbind(alldata$NOC, alldata$T3M, alldata$RUT.xs)
NOC_data <- na.omit(NOC_data)

NOC.model <- lm(NOC_data$NOC - NOC_data$T3M ~ NOC_data$RUT.xs, NOC_data)
summary(NOC.model)

#6) QCOM
QCOM_data <-cbind(alldata$QCOM, alldata$T3M, alldata$RUT.xs)
QCOM_data <- na.omit(QCOM_data)

QCOM.model <- lm(QCOM_data$QCOM - QCOM_data$T3M ~ QCOM_data$RUT.xs, QCOM_data)
summary(QCOM.model)

#7) RTN
RTN_data <-cbind(alldata$RTN, alldata$T3M, alldata$RUT.xs)
RTN_data <- na.omit(RTN_data)

RTN.model <- lm(RTN_data$RTN - RTN_data$T3M ~ RTN_data$RUT.xs, RTN_data)
summary(RTN.model)

#8) UTX
UTX_data <-cbind(alldata$UTX, alldata$T3M, alldata$RUT.xs)
UTX_data <- na.omit(UTX_data)

UTX.model <- lm(UTX_data$UTX - UTX_data$T3M ~ UTX_data$RUT.xs, UTX_data)
summary(UTX.model)

#------------------------SP500 & Russell2000--------------------------------
#1) BA
BA_data <-cbind(alldata$BA, alldata$T3M, alldata$SPX.xs, alldata$RUT.xs)
BA_data <- na.omit(BA_data)

BA.model <- lm(BA_data$BA - BA_data$T3M ~ BA_data$SPX.xs + BA_data$RUT.xs, BA_data)
summary(BA.model)

#2) GD
GD_data <-cbind(alldata$GD, alldata$T3M, alldata$SPX.xs,alldata$RUT.xs)
GD_data <- na.omit(GD_data)

GD.model <- lm(GD_data$GD - GD_data$T3M ~ GD_data$SPX.xs+GD_data$RUT.xs, GD_data)
summary(GD.model)

#3) HON
HON_data <-cbind(alldata$HON, alldata$T3M, alldata$SPX.xs,alldata$RUT.xs)
HON_data <- na.omit(HON_data)

HON.model <- lm(HON_data$HON - HON_data$T3M ~ HON_data$SPX.xs + HON_data$RUT.xs, HON_data)
summary(HON.model)

#4) LMT
LMT_data <-cbind(alldata$LMT, alldata$T3M, alldata$SPX.xs,alldata$RUT.xs)
LMT_data <- na.omit(LMT_data)

LMT.model <- lm(LMT_data$LMT - LMT_data$T3M ~  LMT_data$SPX.xs+ LMT_data$RUT.xs, LMT_data)
summary(LMT.model)

#5) NOC
NOC_data <-cbind(alldata$NOC, alldata$T3M, alldata$SPX.xs,alldata$RUT.xs)
NOC_data <- na.omit(NOC_data)

NOC.model <- lm(NOC_data$NOC - NOC_data$T3M ~ NOC_data$SPX.xs+NOC_data$RUT.xs, NOC_data)
summary(NOC.model)

#6) QCOM
QCOM_data <-cbind(alldata$QCOM, alldata$T3M, alldata$SPX.xs,alldata$RUT.xs)
QCOM_data <- na.omit(QCOM_data)

QCOM.model <- lm(QCOM_data$QCOM - QCOM_data$T3M ~ QCOM_data$SPX.xs + QCOM_data$RUT.xs, QCOM_data)
summary(QCOM.model)

#7) RTN
RTN_data <-cbind(alldata$RTN, alldata$T3M, alldata$SPX.xs,alldata$RUT.xs)
RTN_data <- na.omit(RTN_data)

RTN.model <- lm(RTN_data$RTN - RTN_data$T3M ~ RTN_data$SPX.xs + RTN_data$RUT.xs, RTN_data)
summary(RTN.model)

#8) UTX
UTX_data <-cbind(alldata$UTX, alldata$T3M, alldata$SPX.xs,alldata$RUT.xs)
UTX_data <- na.omit(UTX_data)

UTX.model <- lm(UTX_data$UTX - UTX_data$T3M ~ UTX_data$SPX.xs + UTX_data$RUT.xs, UTX_data)
summary(UTX.model)

