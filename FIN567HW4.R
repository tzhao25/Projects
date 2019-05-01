#FIN567 HW4 Q3
no_of_trails = 10000
N = 120
estimate=data.frame(matrix(ncol=2,nrow=no_of_trails))
colnames(estimate)=c('beta','t-statistic')


S = rep(NA,N)

for (k in 1:no_of_trails) {
  return_1 = rnorm(120,0.01,0.08)
  return_2 = rnorm(120,0.01,0.08)
  P[1] = 100
  S[1] = 100
  for (i in 2:N) {
    P[i] = P[i-1]*exp(return_1[i-1])
    S[i] = S[i-1]*exp(return_2[i-1])
  }
  prices = data.frame(cbind(log(P),log(S)))
  colnames(prices)=c('P', 'S')
  model = lm(S ~ P,data = prices)
  model_summary = summary(model)
  beta = model_summary$coefficients['P','Estimate']
  std_error = model_summary$coefficients['P', 'Std. Error']
  t = beta/std_error
  estimate[k,1] = beta
  estimate[k,2] = t
}
hist(estimate[,1],main='beta',xlab = 'beta',ylab = 'density')
hist(estimate[,2],main='t-statistic',xlab = 't-statistic',ylab = 'density')

  