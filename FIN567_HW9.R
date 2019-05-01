#1(a)
DTD <- -qnorm(0.01, 0, 1)
print(DTD)
# 1(b)(c)
l <- rep(10, 100)
PD <- 0.01
rho <- 0.3
total.loss <- rep(0, 20000)
for (i in 1:20000){
  m <- rnorm(100, 0, 1)
  idio.factor <- rnorm(100, 0, 1)
  z <- rho^0.5*m + (1-rho)^0.5*idio.factor
  x <- rbeta(100, 2, 2, 0)
  LGD <- 1-x
  loss <- rep(0, 100)
  for (j in 1:100){
    if (z[j]<=DTD){
      loss[j] = l[j]*LGD[j]
    }
    else{
      loss[j] = 0  
    }
  }
  total.loss[i] <- sum(loss)
}

portfolio <- sum(l)
pct.port <- c(-1, 0.00001, seq(0.005,0.1,0.005), portfolio)
thsh <- portfolio*pct.port
count1 <- rep(0,(length(thsh)))
for (i in 2:length(thsh)){
  count1[i-1] <- length(total.loss[(total.loss <= thsh[i]) & (total.loss > thsh[i-1])])
}

freq1 <- count1/sum(count1)
barplot(freq1[1:21], names.arg=c("0.001%", "0.5%", 
                                 "1.0%", "1.5%", 
                                 "2.0%", "2.5%", 
                                 "3.0%", "3.5%", 
                                 "4.0%", "4.5%", 
                                 "5.0%", "5.5%", 
                                 "6.0%", "6.5%", 
                                 "7.0%", "7.5%", 
                                 "8.0%", "8.5%", 
                                 "9.0%", "9.5%", 
                                 "10.0%"), ylim = c(0,0.4), main = "Distribution of Losses(ρ=0)",
        xlab = "Portfolio Losses(% of portfolio)", ylab = "Probability")
mean(total.loss)

#Q2
#a)
dr = 0.03
H = 0.97
m = qnorm((1+H)/2)
u = 1
print(m)
#b)
a = 0.05
b = seq(0,10,0.0001)
for (m in b){
  H = pnorm(m+0.05)-exp(-0.1*m)*pnorm(-m+0.05)
  if (H >= 0.97){
    break
  }
}
m

#c)
rho = 0.3
T = 1
dt = 1/252
N = 10000
ma = c()
mb = c()
ma_d = c()
mb_d = c()
for (i in c(1:N)){
  dwa = rnorm(T/dt,0,1)*sqrt(dt)
  dwb = rho*dwa+sqrt(1-rho^2)*rnorm(T/dt,0,1)*sqrt(dt)
  dma = dwa
  dmb = a*dt+dwb
  ma[1] = m
  mb[1] = m
  for (j in c(2:(T/dt))){
    ma[j] = ma[j-1]+dma[j]
    mb[j] = mb[j-1]+dmb[j]
    #if (ma[j] < 0){
    #  ma_d[i] = -9999
    #}
    #if (mb[j] < 0){
    #  mb_d[i] = -9999
    #}
    if (ma[j] < 0 && mb[j] < 0){
      ma_d[i] = 1
      mb_d[i] = 1
    }
    print(i)
  }
 #Ha[i] = pnorm(ma[i]+a*u)-exp(-2*a*ma[i])*pnorm(-ma[i]+a*u)
 #Hb[i] = pnorm(mb[i]+a*u)-exp(-2*a*mb[i])*pnorm(-mb[i]+a*u)
}

mb_d = na.omit(mb_d)
Prob = length(mb_d)/N
print(Prob)

#d)
rho = 0.3
T = 1
dt = 1/252
N = 10000
ma = c()
mb = c()

ma_d = c()
mb_d = c()
for (i in c(1:N)){
  dwa = rnorm(T/dt,0,1)*sqrt(dt)
  dwb = rho*dwa+sqrt(1-rho^2)*rnorm(T/dt,0,1)*sqrt(dt)
  dma = dwa
  dmb = dwb
  ma[1] = m
  mb[1] = m
  for (j in c(2:(T/dt))){
    ma[j] = ma[j-1]+dma[j]
    mb[j] = mb[j-1]+dmb[j]
    #if (ma[j] < 0){
    #  ma_d[i] = -9999
    #}
    #if (mb[j] < 0){
    #  mb_d[i] = -9999
    #}
    if (ma[j] < 0 && mb[j] < 0){
      ma_d[i] = 1
      mb_d[i] = 1
    }
    print(i)
  }
  #Ha[i] = pnorm(ma[i]+a*u)-exp(-2*a*ma[i])*pnorm(-ma[i]+a*u)
  #Hb[i] = pnorm(mb[i]+a*u)-exp(-2*a*mb[i])*pnorm(-mb[i]+a*u)
}

mb_d = na.omit(mb_d)
Prob = length(mb_d)/N
print(Prob)




