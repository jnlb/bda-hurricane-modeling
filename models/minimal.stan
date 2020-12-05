// minimal model, hierarchical
data {
  int<lower=0> N;
  int<lower=0> J;
  vector[N] y;
  matrix[N,J] x; // variables, excluding SHRD
  vector[N] shr; // wind shear
  vector[J+1] mu; // required prior means 
  matrix[J+1, J+1] tau; // prior covariance matrix
}
parameters {
  vector[J+1] theta;
  real < lower =0 > sigma;
  vector[2] theta_shr;
  real < lower =0 > sigma_s;
}
model {
  sigma_s ~ inv_chi_square(0.1);
  theta_shr ~ multi_normal([0, 0]', [[1, 0], [0, 1]]);
  
  // #2 is the SST variable
  mu[2] ~ normal(theta_shr[1] + shr*theta_shr[2], sigma_s);
  theta ~ multi_normal(mu, tau);
  
  sigma ~ inv_chi_square(0.1);
  y  ~ normal( theta[1] + x*theta[2:J+1], sigma);
}

generated quantities {
  vector[N] log_lik;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | theta[1] + x[n]*theta[2:J+1], sigma);
}}
