## Dale W.R. Rosenthal, 2018
## You are free to distribute and use this code so long as you attribute
## it to me or cite the text.
## The legal disclaimer in _A Quantitative Primer on Investments with R_
## applies to this code.  Use or distribution without these comment lines
## is forbidden.

library(xts)
library(Quandl)
library(zoo)

###############################################       Grab constant-maturity US Treasuries
ust.tickers <- c("FRED/DGS3MO","FRED/DGS6MO", "FRED/DGS1","FRED/DGS2", "FRED/DGS5", "FRED/DGS10","FRED/DGS20", "FRED/DGS30")
ust.full <- Quandl(ust.tickers, type="xts")/100
ust.colnames <- c("T3M", "T6M","T1Y","T2Y", "T5Y", "T10Y","T20Y","T30Y")
colnames(ust.full) <- ust.colnames
ust<-ust.full['20141001/20181001']

################################       yc.usd 是ust的一阶差分，不知道对不对，是否应该改成变化率？
yc.usd<-na.omit(diff(ust))

#pca.usd <- prcomp(~ T3M + T6M + T1Y + T2Y + T5Y + T10Y + T20Y + T30Y, data=ust,
                 # scale=FALSE, center=FALSE)

######       pca part
pca.usd <- prcomp(yc.usd, scale=FALSE, center=FALSE)
head(pca.usd$rotation)  # eigenvectors
pca.usd$sdev^2    # eigenvalues

######       将特整根特征向量存入excel
library(openxlsx)
write.xlsx(pca.usd$rotation, "eigen_vector2.xlsx")
write.xlsx(pca.usd$sdev^2, "eigen_value2.xlsx")

######       查看前五个特征向量所能解释的方差%
print(sum(pca.usd$sdev[1:5]^2)/sum(pca.usd$sdev^2))