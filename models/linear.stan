
data {
  int<lower=0> N;
  int<lower=0> J;
  vector[N] y;
  matrix[N,J] x;
  vector[J+1] mu; // required prior means 
  matrix[J+1, J+1] tau; // prior covariance matrix
}

parameters {
  vector[J+1] theta;
  real < lower =0 > sigma;
}

model {
  theta ~ multi_normal(mu, tau);
  sigma ~ inv_chi_square(0.1);
  y  ~ normal( theta[1] + x*theta[2:J+1], sigma);
}

generated quantities {
  vector[N] log_lik;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | theta[1] + x[n]*theta[2:J+1], sigma);
}}
