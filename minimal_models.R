source('init.r')
library(rstan)
load_data(type="minimal-A", target="delta", 
          standardize=TRUE)
SEED <- 123

# Imputing missing values:
which(rowSums(is.na(ships))==1)
library(mice)
imp <- mice(ships, m = 1);
ships <- complete(imp)

# Sample from the Stan models
# First a linear model

y = ships[,ncol(ships)]
ships[,ncol(ships)] <- NULL ## ah, severe bug. somebody kill me now

coltypes <- sapply(ships, class)
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

Sys.sleep(5)

# Convergence diagnostics
monitor(linear_model)


## next model: hierarchical type
shr <- x$SHRD
x$SHRD <- NULL
J = ncol(x)
mu = rep(0, times=J+1)
Sig <- matrix(0, J+1, J+1)
diag(Sig) <- 10 # weak prior variances

# test data for Stan
K <- nrow(test_data)
coltypes_t <- sapply(test_data, class)
x_test <- test_data[,coltypes_t != 'character']
x_test[,ncol(x_test)] <- NULL
shr_test <- x_test$SHRD
x$SHRD <- NULL

stan_data <- list(y = y,
                  x = x,
                  shr = shr,
                  N = N,
                  J = J,
                  K = K,
                  x_test = x_test[,names(x_test) != names(x_test)[J]],
                  shr_test = shr_test,
                  mu = mu,
                  tau = Sig)

hierarch_m <- rstan::stan_model(file = file.path(mod_path, "minimal.stan"))
# needed to increase max. tree depth
hierarch_model <- rstan::sampling(hierarch_m, data = stan_data, 
                                control = list(max_treedepth = 15),
                                iter=4000, seed = SEED)

Sys.sleep(5)

# Convergence diagnostics
monitor(hierarch_model)


#Models Comparison

loo_l <- loo(linear_model,  cores = 4)
loo_h <- loo(hierarch_model,  cores = 4)

png(file="images/pareto_linear.png")
plot(loo_l$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Basic + Linear Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()

png(file="images/pareto_hierarchical.png")
plot(loo_h$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Basic + Nonlinear Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()

library(loo)
loo_compare(loo_l, loo_h)
