// IDEA OF THIS MODEL:
// separate factors, one based on sea temperature and one based on environment
data {
  int<lower=0> N; // number of observations
  int<lower=0> Ji; // number of intensifying covariates
  int<lower=0> Jw; // number of weakening covariates
  vector[N] y; // VMAX / DELTA
  vector[N] sst;
  matrix[N,Ji] x_i;
  matrix[N,Jw] x_w;
  vector[Ji+1] mu_i; // required prior means 
  matrix[Ji+1, Ji+1] tau_i; // prior covariance matrix
  vector[Jw+1] mu_w; // required prior means 
  matrix[Jw+1, Jw+1] tau_w; // prior covariance matrix
}

parameters {
  vector[Ji+1] theta_i;
  vector[Jw+1] theta_w;
  vector[3] alpha;
  real x_sst;
  real x_shr;
  real<lower=0> sigma;
  real<lower=0> sigma_sst;
  real<lower=0> sigma_shr;
}

model {
  theta_i ~ multi_normal(mu_i, tau_i);
  sigma ~ inv_chi_square(0.1);
  x_sst ~ normal(theta_i[1] + x_i*theta_i[2:Ji+1], sigma_sst);
  x_shr ~ normal(theta_w[1] + x_i*theta_w[2:Ji+1], sigma_shr);
  y  ~ normal( alpha[1] + alpha[2]*x_sst + alpha[3]*x_shr, sigma);
}
