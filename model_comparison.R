source('init.r')
library(rstan)
library(loo)

## Basic data + Linear model

load_data(type="basic", target="delta", 
          standardize=TRUE)
SEED <- 123

# Imputing missing values:
which(rowSums(is.na(ships))==1)
library(mice)
imp <- mice(ships, m = 1);
ships <- complete(imp)


coltypes <- sapply(ships, class)

y = ships[,ncol(ships)]
x = ships[,coltypes!='character']
N = nrow(ships)
J = ncol(x)
mu = rep(0, times=J+1)
Sig <- matrix(0, J+1, J+1)
diag(Sig) <- 10 # weak prior variances

stan_data <- list(y = y,
                  x = x,
                  N = N,
                  J = J,
                  mu = mu,
                  tau = Sig)

linear_m <- rstan::stan_model(file = file.path(mod_path, "linear.stan"))
linear_model <- rstan::sampling(linear_m, data = stan_data, 
                                iter=4000, seed = SEED)
saveRDS(linear_model, file = file.path(mod_path, "linear_model.rds"))


linear_model_d <- as.data.frame(linear_model)
# Convergence diagnostics
monitor(linear_model)
stan_trace(linear_model)


## Basic data + Nonlinear model
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

basic_nonlinear_m <- rstan::stan_model(file = file.path(mod_path, "nonlinear.stan"))
basic_nonlinear_model <- rstan::sampling(basic_nonlinear_m, data = stan_data, iter=2000, seed = SEED)
saveRDS(basic_nonlinear_model, file = file.path(mod_path, "basic_nonlinear_model.rds"))

monitor(basic_nonlinear_model)
stan_trace(basic_nonlinear_model)

## Nonlinear data + Nonlinear model
load_data(type="nonlinear", target="delta", 
          standardize=TRUE)
SEED <- 123

# Imputing missing values:
which(rowSums(is.na(ships))==1)
library(mice)
imp <- mice(ships, m = 1);
ships <- complete(imp)


coltypes <- sapply(ships, class)

y = ships[,ncol(ships)]
x = ships[,coltypes!='character']
sst = x[,"CSST"]
shr = x[,"SHRD"]
x_sst = x[,c("RHMD", "T150", "VVAV", "SHRD", "LAT.")]
x_shr = x[,c("INCV", "U200", "REFC", "G250", "VMAX")]
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

nonlinear_m <- rstan::stan_model(file = file.path(mod_path, "nonlinear.stan")) 
nonlinear_model <- rstan::sampling(nonlinear_m, data = stan_data, iter=4000, seed = SEED)
saveRDS(nonlinear_model, file = file.path(mod_path, "nonlinear_model.rds"))

monitor(nonlinear_model)
stan_trace(nonlinear_model)


#Models Comparison

log_lik_linear <- extract_log_lik(linear_model, merge_chains = FALSE)
r_eff_l <- relative_eff(exp(log_lik_linear), cores = 4)
loo_l <- loo(log_lik_linear, r_eff = r_eff_l, cores = 4)
saveRDS(loo_l, file = file.path(mod_path, "loo_l.rds"))

log_lik_basic_nonlinear <- extract_log_lik(basic_nonlinear_model, merge_chains = FALSE)
r_eff_bn <- relative_eff(exp(log_lik_basic_nonlinear), cores = 4)
loo_bn <- loo(log_lik_basic_nonlinear, r_eff = r_eff_bn, cores = 4)
saveRDS(loo_bn, file = file.path(mod_path, "loo_bn.rds"))

log_lik_nonlinear <- extract_log_lik(nonlinear_model, merge_chains = FALSE)
r_eff_n <- relative_eff(exp(log_lik_nonlinear), cores = 4)
loo_n <- loo(log_lik_nonlinear, r_eff = r_eff_n, cores = 4)
saveRDS(loo_n, file = file.path(mod_path, "loo_n.rds"))

png(file="images/pareto_linear.png")
plot(loo_l$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Basic + Linear Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()

png(file="images/pareto_basic_nonlinear.png")
plot(loo_bn$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Basic + Nonlinear Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()

png(file="images/pareto_nonlinear_nonlinear.png")
plot(loo_n$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Nonlinear + Nonlinear Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()


loo_compare(loo_l, loo_bn, loo_n)
