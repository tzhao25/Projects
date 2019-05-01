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
#-----------------------------*******************get data for HW3 end-----------------------

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





#4.a
#-----------------------------Q4 Chen-Roll-Ross 5 factor model, macro factor model----------------------------------
BA.model <- lm(all$BA ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(BA.model)

GD.model <- lm(all$GD ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(GD.model)

HON.model <- lm(all$HON ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(HON.model)

LMT.model <- lm(all$LMT ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(LMT.model)

NOC.model <- lm(all$NOC ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(NOC.model)

QCOM.model <- lm(all$QCOM ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(QCOM.model)

RTN.model <- lm(all$RTN ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(RTN.model)

UTX.model <- lm(all$UTX ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(UTX.model)

SPX.model <- lm(all$SPX ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(SPX.model)

RUT.model <- lm(all$RUT ~ all$INDPROD + all$EXINFL_CHANGE + all$INFLSURP + all$CS + all$YCslope, all)
summary(RUT.model)


