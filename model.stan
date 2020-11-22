
data {
  int<lower=0> N;
  int<lower=0> J;
  vector[N] y;
  matrix[N,J] x;
  //vector[J+1] mu;
  //matrix[J+1, J+1] tau;
}

parameters {
  vector[J+1] theta;
  real < lower =0 > sigma;
}

model {
  //theta ~ multi_normal(mu, tau);
  y  ~ normal( theta[1] + x*theta[2:J+1], sigma);
}
