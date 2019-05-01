## Dale W.R. Rosenthal, 2018
## You are free to distribute and use this code so long as you attribute
## it to me or cite the text.
## The legal disclaimer in _A Quantitative Primer on Investments with R_
## applies to this code.  Use or distribution without these comment lines
## is forbidden.
library(xts)
library(quantmod)
library(Quandl)
library(rugarch)

# get CMT USTs: 3M, 2Y, 10Y, 30Y

## Download Fama-French data
french.base <- "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp"
factor.file <- "F-F_Research_Data_Factors_daily_CSV.zip"
french.url <- paste(french.base, factor.file, sep="/")
temp.file <- tempfile()
download.file(french.url, destfile=temp.file)
ff.tmp <- read.csv(unz(temp.file, "F-F_Research_Data_Factors_daily.CSV"),
                   header = TRUE, skip = 3)
unlink(temp.file)

# (1) industrial production growth, compute log-returns (% changes)
indprod <- Quandl("FRED/INDPRO", type="xts")
colnames(indprod) <- c("INDPROD")
indprod.logret <- diff(log(indprod))
indprod.logret <- indprod.logret['20141001/20181001']
### Handle monthly data
# For expected CPI and realized CPI, only get the first column of
# data... like so:
# (2) change in expected inflation
exinfl <- Quandl("FRBC/EXIN", type="xts")[,1]
colnames(exinfl) <- c("EXINFL")
exinfl_change<-diff(exinfl)
colnames(exinfl_change)<-c("EXINFL_CHANGE")
exinfl_change <- exinfl_change['20141001/20181001']

# (3) inflation surprise
cpi <- Quandl("FRBC/USINFL", type="xts")[,1]
colnames(cpi) <- c("CPI")

excpi <- cpi*(1+exinfl)  # expected CPI in twelve months
cpi.surprise <- log(cpi) - log(lag(excpi, 12))  # % CPI surprise
colnames(cpi.surprise) <- c("INFLSURP")
cpi.surprise <- cpi.surprise['20141001/20181001']


# (4) credit spread
#COMPANY
baa<-Quandl("FRED/BAA10Y", type="xts")/100
baa<-baa['20141001/20181001']

#10year
ust.tickers <- c("FRED/DGS3MO", "FRED/DGS10", "FRED/DGS30")
ust.raw <- Quandl(ust.tickers, type="xts")/100
colnames(ust.raw) <- c("T3M", "T10Y", "T30Y")
ust<-ust.raw['20141001/20181001']

credit_spread<- baa-ust$T10Y
colnames(credit_spread) <- c("CS")

# (5) yield curve slope 
slope<-ust$T30Y-ust$T3M
colnames(slope) <- c("YCslope")
slope <- slope['20141001/20181001']

#***combine all
all_factors_temp1 <- cbind(credit_spread, slope, indprod.logret, exinfl_change, cpi.surprise)
all_factors  <-na.locf(all_factors_temp1, na.rm = TRUE)

#all_factors_temp2 <- na.omit(all_factors_temp1)
#---------------------------------------------------------------------

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
returns.daily <- diff(log(prices))
returns<-returns.daily*250                      #***convert to yearly scale for the daily data***
returns <- returns["20141001/20181001"]
returns <- na.omit(returns)

#Combine stocks with 5 factors
all_temp <- cbind(all_factors, returns)
#all <-na.locf(all_temp, na.rm = TRUE)
all <- na.omit(all_temp)
#---------------------------------------------------------------------*******************get data for HW3 end-----------------------

# remove obnoxious last line, scale percentages, create xts object
ff.tmp <- ff.tmp[-length(ff.tmp[,1]),]
ff.data <- as.xts(ff.tmp[,c("SMB","HML")],
                  order.by=as.POSIXct(ff.tmp[[1]], format="%Y%m%d"))

## Download Carhart (momentum) data; skip absurd number of comment lines
factor.file <- "F-F_Momentum_Factor_daily_CSV.zip"
french.url <- paste(french.base, factor.file, sep="/")
temp.file <- tempfile()
download.file(french.url, destfile=temp.file)
umd.tmp <- read.csv(unz(temp.file, "F-F_Momentum_Factor_daily.CSV"),
                    header = TRUE, skip = 13)
unlink(temp.file)
# remove obnoxious last line, scale percentages, create xts object
umd.tmp <- umd.tmp[-length(umd.tmp[,1]),]
umd.data <- as.xts(umd.tmp[,c("Mom")], order.by=as.POSIXct(umd.tmp[[1]], format="%Y%m%d"))
colnames(umd.data) <- c("UMD")






# Get index and stock prices; create returns

# Now we join all of the datasets together
alldata.full <- cbind(ust, exinfl, cpi.surprise, ltcorpbond, indprod, ff.data, umd.data, returns)

# For monthly data: Last Observation Carried Forward (until new number)
alldata <- na.locf(alldata.full)["'20141001/20181001'"]

# create excess returns for indices, stocks

# Handy way to compute a function for each column
apply(alldata, 2, mean, na.rm=TRUE)  # "2" = by columns; "1" = by rows

# If your ticker were DAL and you wanted to model returns (not excess
# returns) using HML and SMB, you would do like so:
hml.wrong.model <- lm(DAL ~ HML + SMB, data=alldata)
summary(hml.wrong.model)
# NOTE that this is not a model you are supposed to do for the homework




#5.a
#-------------------------------Q5 GARCH-in-mean model, micro factor model---------------------------------------------------
# Now do GARCH-in-mean models
#SPX
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.spx <- ugarchfit(data=all$SPX, spec=gim.spec)
show(garch.in.mean.spx)

#RUT
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.rut <- ugarchfit(data=all$RUT, spec=gim.spec)
show(garch.in.mean.rut )

#BA
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.BA <- ugarchfit(data=all$BA, spec=gim.spec)
show(garch.in.mean.BA)

#GD
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.GD <- ugarchfit(data=all$GD, spec=gim.spec)
show(garch.in.mean.GD)

#HON 
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.HON <- ugarchfit(data=all$HON, spec=gim.spec)
show(garch.in.mean.HON)

#LMT
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.LMT <- ugarchfit(data=all$LMT, spec=gim.spec)
show(garch.in.mean.LMT)

#NOC
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.NOC <- ugarchfit(data=all$NOC, spec=gim.spec)
show(garch.in.mean.NOC)

#QCOM
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.QCOM <- ugarchfit(data=all$QCOM, spec=gim.spec)
show(garch.in.mean.QCOM)

#RTN
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.RTN <- ugarchfit(data=all$RTN, spec=gim.spec)
show(garch.in.mean.RTN)

#RTN
gim.spec <- ugarchspec(variance.model=list(model="sGARCH", archm=TRUE, archpow=2),
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE))
garch.in.mean.UTX <- ugarchfit(data=all$UTX, spec=gim.spec)
show(garch.in.mean.UTX)