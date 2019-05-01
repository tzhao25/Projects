##FIN567_HW5
library("stats4", lib.loc="/Library/Frameworks/R.framework/Versions/3.5/Resources/library")
library("bbmle", lib.loc="/Library/Frameworks/R.framework/Versions/3.5/Resources/library")
#Q1
spx = read.csv(file="/Users/tianhaozhao/Desktop/F567C.s2019.HW5.data.csv",header=TRUE,skip=1)
u = seq(0.01,0.05,by=0.002)
spx.return = diff(log(spx$Close),lag = 1)
spx.loss = -spx.return
e = rep(NA,length(u))
for (t in u){
  no.exceed = spx.loss[spx.loss>t]
  eu = 1/length(no.exceed)*sum(no.exceed-t)
  e[which(u==t)] = eu
}
plot(u,e,main = 'Mean excess',ylab='e(u)')
#Q2
t_2 = 0.022
q2.loss = spx.loss[spx.loss>t_2]
cat(length(q2.loss),"losses are greater than 0.022")
#Q3
excess_losses = q2.loss
p_u = length(excess_losses)/length(spx.loss)
max = function(xi, beta){
  -sum(log(1/beta*(1+xi*(excess_losses-0.022)/beta)^(-1/xi-1)))
}
fit <- mle2(max, start = list(xi = 0.1,beta = 0.1))

#Q4
xi = 0.33617296
beta = 0.00767833
fff = function(x){
  (1+xi*(x-0.022)/beta)^(-1/xi-1)
}
plot(fff, xlim = c(0.022, 0.1), xlab = "Excess loss", ylab = "Probability", main = "Conditional density function
of the losses")
#Q5

q5 = function(x){
  l = length(spx.loss)
  a = (1+xi*(x-0.022)/beta)^(-1/xi-1)*length(spx.loss[spx.loss>=x])/l
  cat("Probability of Loss greater than",x,"is",a,'\n')
  a
}
for (i in c(0.022, 0.05, 0.1)) {
  q5(i)
}

threshold = seq(0.022,0.1,length = 10000)
p = c()
for (i in c(1:10000)){
  l = length(spx.loss)
  a = (1+xi*(threshold[i]-0.022)/beta)^(-1/xi-1)*length(spx.loss[spx.loss>=threshold[i]])/l
  p = cbind(p,a)
}

plot(threshold[1:10000],p[1:10000],type = 'l',main = 'Prob of various loss',xlab = 'threshold',ylab = 'prob')



  