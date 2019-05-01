library(xts)
library(quantmod)
library(fOptions)
library(rockchalk)


# load in data
start = '2004-01-01'
end = '2018-12-31'
adj.close = 6
DJI = getSymbols('^DJI', source="yahoo", auto.assign=FALSE, return.class="xts", 
                 from=start, to=end)[,adj.close]
GSPC = getSymbols('^GSPC', source="yahoo",auto.assign=FALSE,return.class="xts",
                  from=start, to=end)[,adj.close]
IXIC = getSymbols('^IXIC', source="yahoo",auto.assign=FALSE, return.class="xts",
                  from=start, to=end)[,adj.close]
RUT = getSymbols('^RUT', source="yahoo",auto.assign=FALSE,return.class="xts",
                 from=start, to=end)[,adj.close]
rm(adj.close)
# calculate the simple daily return of each index
DJI_rtn = diff(DJI) / DJI[1:length(DJI)-1]
GSPC_rtn = diff(GSPC) / GSPC[1:length(GSPC)-1]
IXIC_rtn = diff(IXIC) / IXIC[1:length(IXIC)-1]
RUT_rtn = diff(RUT) / RUT[1:length(RUT)-1]

calander = index(DJI)
idx1 = which(calander == '2008-01-02')
idx2 = which(calander == '2009-12-31')


# T1: historical simulation for ES and VaR
port_daily_VAR_hist = xts(x=matrix(nrow=idx2-idx1+1, ncol=1), order.by=calander[idx1:idx2])
port_daily_ES = xts(x=matrix(nrow=idx2-idx+1, ncol=1), order.by=calander[idx1:idx2])
for (i in 1:length(port_daily_VAR_hist)){
  idx = which(calander == index(port_daily_VAR_hist)[i])
  
  series1 = DJI_rtn[(idx-1000):(idx-1)]
  series2 = GSPC_rtn[(idx-1000):(idx-1)]
  series3 = IXIC_rtn[(idx-1000):(idx-1)]
  series4 = RUT_rtn[(idx-1000):(idx-1)]
  
  port_rtn = series1+series2+series3+series4
  port_rtn = sort(as.vector(port_rtn))
  
  port_daily_VAR_hist[i] = port_rtn[1000*0.05]
  port_daily_ES[i] = mean(port_rtn[1:(1000*0.05)], na.rm=T)
}
rm(series1, series2, port_rtn)
port_daily_VAR_hist = -port_daily_VAR_hist
port_daily_ES = -port_daily_ES
T1_result = cbind(port_daily_VAR_hist, port_daily_ES)
plot(T1_result)


# T2: estimate fair price of option and implied volatility
rf = 0.0124236
TE = 18 / 252
SP_S0 = 2564.98
SP_K = 2565
SP_q = 0.0164791
DJ_S0 = 23273.96 / 100
DJ_K = 233
DJ_q = 0.0236134
# calculate mid price for four put and call
SP_call_bid = 18.7
SP_call_offer = 19.7
SP_put_bid = 20
SP_put_offer = 21.1
SP_call_mid = (SP_call_bid + SP_call_offer) / 2
SP_put_mid = (SP_put_bid + SP_put_offer) / 2
DJ_call_bid = 1.8
DJ_call_offer = 1.96
DJ_put_bid = 2.14
DJ_put_offer = 2.37
DJ_call_mid = (DJ_call_bid + DJ_call_offer) / 2
DJ_put_mid = (DJ_put_bid + DJ_put_offer) / 2
# use mid price to calculate implied volatility for four option
SP_call_vol = GBSVolatility(SP_call_mid, TypeFlag='c', SP_S0, SP_K, TE, rf, rf-SP_q)
SP_put_vol= GBSVolatility(SP_put_mid, TypeFlag='p', SP_S0, SP_K, TE, rf, rf-SP_q)
DJ_call_vol = GBSVolatility(DJ_call_mid, TypeFlag='c', DJ_S0, DJ_K, TE, rf, rf-DJ_q)
DJ_put_vol = GBSVolatility(DJ_put_mid, TypeFlag='p', DJ_S0, DJ_K, TE, rf, rf-DJ_q)


# T3 & T4
# function used to calculate BS price for call and put
BS_call <- function(S0, K, rf, sigma, Maturity, q){
  d1 = (log(S0/K)+(rf-q+sigma^2/2)*Maturity) / (sigma*sqrt(Maturity))
  d2 = d1 - sigma*sqrt(Maturity)
  call_price = S0*exp(-q*Maturity)*pnorm(d1) - K*exp(-rf*Maturity)*pnorm(d2)
  return(call_price)
}
BS_put <- function(S0, K, rf, sigma, Maturity, q){
  d1 = (log(S0/K)+(rf-q+sigma^2/2)*Maturity) / (sigma*sqrt(Maturity))
  d2 = d1 - sigma*sqrt(Maturity)
  put_price = K*exp(-rf*Maturity)*pnorm(-d2) - S0*exp(-q*Maturity)*pnorm(-d1)
  return(put_price)
}
# calculate portfolio initial value
mul = 100
port_SP_call = -50*mul*SP_call_mid
port_SP_put = -50*mul*SP_put_mid
port_DJ_call = 600*mul*DJ_call_mid
port_DJ_put = 600*mul*DJ_put_mid
port_value_initial = port_SP_call + port_SP_put + port_DJ_call + port_DJ_put
# data used to generate multivariate normal random variables
u = c(0.0001, 0.0001, 0.0078, 0.0066)
vol = c(0.0105, 0.0110, 0.1250, 0.1150)
cov_matrix = matrix(nrow=4, ncol=4)
cov_matrix[1,1] = vol[1]^2
cov_matrix[2,2] = vol[2]^2
cov_matrix[3,3] = vol[3]^2
cov_matrix[4,4] = vol[4]^2
cov_matrix[1,2] = cov_matrix[2,1] = 0.97*vol[1]*vol[2]
cov_matrix[1,3] = cov_matrix[3,1] = -0.8*vol[1]*vol[3]
cov_matrix[1,4] = cov_matrix[4,1] = -0.75*vol[1]*vol[4]
cov_matrix[2,3] = cov_matrix[3,2] = -0.75*vol[2]*vol[3]
cov_matrix[2,4] = cov_matrix[4,2] = -0.8*vol[2]*vol[4]
cov_matrix[3,4] = cov_matrix[4,3] = 0.9*vol[3]*vol[4]
# simulate N possilbe portfolio value paths
N = 100000
set.seed(42)
mv_norm = mvrnorm(N, u, cov_matrix)
mv_norm = exp(mv_norm)
days = 18
# calculate new stock index
SP_value = mv_norm[,1] * SP_S0
DJ_value = mv_norm[,2] * DJ_S0
# use new stock index to calculate option price
path = rep(NA, N)
for (i in 1:N){
  SP_call_temp = BS_call(SP_value[i], SP_K, rf, SP_call_vol*mv_norm[i,3], days/252, SP_q)
  SP_put_temp = BS_put(SP_value[i], SP_K, rf, SP_put_vol*mv_norm[i,3], days/252, SP_q)
  DJ_call_temp = BS_call(DJ_value[i], DJ_K, rf, DJ_call_vol*mv_norm[i,4], days/252, DJ_q)
  DJ_put_temp = BS_put(DJ_value[i], DJ_K, rf, DJ_put_vol*mv_norm[i,4], days/252, DJ_q)
  path[i] = (-50*(SP_call_temp+SP_put_temp) + 600 * (DJ_call_temp+DJ_put_temp))*mul
}
# calculate loss
loss = path - port_value_initial
sort_loss = sort(loss)
VaR = sort_loss[N*0.05]
ES = mean(sort_loss[1:N*0.05])







