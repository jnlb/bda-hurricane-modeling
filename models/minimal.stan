// minimal model, hierarchical
// COMPLETE SHIT; DO NOT USE
data {
  int<lower=0> N; // nr of rows
  int<lower=0> J; // nr of x columns (same for test)
  int<lower=0> K; // observations for selected storm for predictions
  matrix[K,J] x_test; // test data for selected test storm
  vector[N] y;
  matrix[N,J] x; // variables, excluding SHRD
  vector[N] shr; // wind shear
  vector[K] shr_test; // wind shear in test data
  vector[J+1] mu; // required prior means 
  matrix[J+1, J+1] tau; // prior covariance matrix
}
parameters {
  vector[J+1] theta;
  real < lower =0 > sigma;
  vector[2] theta_shr;
  real < lower =0 > sigma_s;
  real mu2;
}
model {
  vector[J+1] new_mu; // temp
  
  sigma_s ~ inv_chi_square(0.1);
  theta_shr ~ multi_normal([0, 0]', [[1, 0], [0, 1]]);
  
  // #2 is the SST variable
  mu2 ~ normal(theta_shr[1] + shr*theta_shr[2], sigma_s);
  new_mu = mu;
  new_mu[2] = mu2;
  theta ~ multi_normal(new_mu, tau);
  
  sigma ~ inv_chi_square(0.1);
  y  ~ normal( theta[1] + x*theta[2:J+1], sigma);
}

generated quantities {
  vector[K] vpred;
  vector[N] log_lik;
  real mu_test;
  vector[J+1] theta_test;
  
  // log-likelihoods
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | theta[1] + x[n]*theta[2:J+1], sigma);
  }
  
  // predictions
  theta_test = theta;
  
  for (k in 1:K) { // predicted V may be either 'delta' or 'vmax' type
    mu_test = normal_rng(theta_shr[1] + shr_test[k]*theta_shr[2], sigma_s);
    theta_test[2] = normal_rng(mu_test, sigma);
    vpred[k] = normal_rng(theta_test[1] + x_test[k]*theta_test[2:J+1], sigma);
  }
}
