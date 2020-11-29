source('init.r')
library(rstan)
load_data(type="basic", target="delta", 
          standardize=TRUE)
SEED <- 123

# Imputing missing values:
which(rowSums(is.na(ships))==1)
library(mice)
imp <- mice(ships, m = 1);
ships <- complete(imp)


# Modelling
coltypes <- sapply(ships, class)

y = ships[,ncol(ships)]
x = ships[,coltypes!='character']
sst = x[,"CSST"]
shr = x[,"SHRD"]
x_sst = x[,c("RHLO", "T200", "SHRD")]
x_shr = x[,c("LAT.", "VMAX")]
N = nrow(ships)
Jsst = ncol(x_sst)
Jshr = ncol(x_shr)
mu_sst = rep(0, times=Jsst+1)
Sig_sst <- matrix(0, Jsst+1, Jsst+1)
diag(Sig_sst) <- 10 # weak prior variances
mu_shr = rep(0, times=Jshr+1)
Sig_shr <- matrix(0, Jshr+1, Jshr+1)
diag(Sig_shr) <- 10 # weak prior variances

stan_data <- list(y = y,
                  sst = sst,
                  shr = shr,
                  x_i = x_sst,
                  x_w = x_shr,
                  N = N,
                  Ji = Jsst,
                  Jw = Jshr,
                  mu_i = mu_sst,
                  mu_w = mu_shr,
                  tau_i = Sig_sst,
                  tau_w = Sig_shr)

m <- rstan::stan_model(file = file.path(mod_path, "nonlinear.stan"))
model <- rstan::sampling(m, data = stan_data, iter=2000, seed = SEED)


# Convergence diagnostics
monitor(model)
stan_trace(model)

# R_hat values approximate to 1, so convergence was reached.