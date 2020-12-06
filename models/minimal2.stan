// minimal model, skew normal behavior around regression line
data {
  int<lower=0> N; // nr of rows
  int<lower=0> J; // nr of x columns (same for test)
  int<lower=0> K; // observations for selected storm for predictions
  matrix[K,J] x_test; // test data for selected test storm
  vector[N] y;
  matrix[N,J] x; // variables
  vector[J+1] mu; // required prior means 
  matrix[J+1, J+1] tau; // prior covariance matrix
}
parameters {
  vector[J+1] theta;
  real < lower =0 > sigma;
  real psi;
}
model {
  // regression params
  theta ~ multi_normal(mu, tau);
  // skew-scale
  psi ~ normal(0,1);
  
  sigma ~ inv_chi_square(0.1);
  y  ~ skew_normal(theta[1] + x*theta[2:J+1], sigma, psi);
}

generated quantities {
  vector[K] vpred;
  vector[N] log_lik;
  
  // log-likelihoods
  for (n in 1:N) {
    log_lik[n] = skew_normal_lpdf(y[n] | theta[1] + x[n]*theta[2:J+1], 
        sigma, psi);
  }
  
  // predictions
  for (k in 1:K) { // predicted V may be either 'delta' or 'vmax' type
    vpred[k] = skew_normal_rng(theta[1] + x_test[k]*theta[2:J+1], 
        sigma, psi);
  }
}
