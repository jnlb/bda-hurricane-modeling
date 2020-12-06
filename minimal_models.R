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
# with data : MINIMAL-A

y = ships[,ncol(ships)]
ships[,ncol(ships)] <- NULL 

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


## next model: skewed regression type
J = ncol(x)
mu = rep(0, times=J+1)
Sig <- matrix(0, J+1, J+1)
diag(Sig) <- 10 # weak prior variances

# test data for Stan
K <- nrow(test_data)
coltypes_t <- sapply(test_data, class)
x_test <- test_data[,coltypes_t != 'character']
x_test[,ncol(x_test)] <- NULL

stan_data <- list(y = y,
                  x = x,
                  N = N,
                  J = J,
                  K = K,
                  x_test = x_test,
                  mu = mu,
                  tau = Sig)

skew_m <- rstan::stan_model(file = file.path(mod_path, "minimal2.stan"))
# needed to increase max. tree depth
skew_model <- rstan::sampling(skew_m, data = stan_data, 
                                control = list(max_treedepth = 15),
                                iter=4000, seed = SEED)

Sys.sleep(5)

monitor(skew_model)


## next model: variance regression type
variance_m <- rstan::stan_model(file = file.path(mod_path, "minimal3.stan"))
variance_model <- rstan::sampling(variance_m, data = stan_data, 
                              control = list(max_treedepth = 15),
                              iter=4000, seed = SEED)

Sys.sleep(5)
monitor(variance_model)


#Models Comparison

loo_l <- loo(linear_model,  cores = 4)
loo_s <- loo(skew_model,  cores = 4)
loo_v <- loo(variance_model,  cores = 4)


library(loo)
loo_compare(loo_l, loo_s, loo_v)



#Using "C" data
load_data(type="basic", target="delta", 
          standardize=TRUE)
SEED <- 123

# Imputing missing values:
which(rowSums(is.na(ships))==1)
library(mice)
imp <- mice(ships, m = 1);
ships <- complete(imp)


y = ships[,ncol(ships)]
ships[,ncol(ships)] <- NULL 

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

linear_model_b <- rstan::sampling(linear_m, data = stan_data, 
                                iter=4000, seed = SEED)

Sys.sleep(5)
monitor(linear_model_b)


## next model: skewed regression type
J = ncol(x)
mu = rep(0, times=J+1)
Sig <- matrix(0, J+1, J+1)
diag(Sig) <- 10 # weak prior variances

# test data for Stan
K <- nrow(test_data)
coltypes_t <- sapply(test_data, class)
x_test <- test_data[,coltypes_t != 'character']
x_test[,ncol(x_test)] <- NULL

stan_data <- list(y = y,
                  x = x,
                  N = N,
                  J = J,
                  K = K,
                  x_test = x_test,
                  mu = mu,
                  tau = Sig)

skew_model_b <- rstan::sampling(skew_m, data = stan_data, 
                              control = list(max_treedepth = 15),
                              iter=4000, seed = SEED)


## variance regression type
variance_model_b <- rstan::sampling(variance_m, data = stan_data, 
                                  control = list(max_treedepth = 15),
                                  iter=4000, seed = SEED)


#Models Comparison

loo_l_b <- loo(linear_model_b,  cores = 4)
loo_s_b <- loo(skew_model_b,  cores = 4)
loo_v_b <- loo(variance_model_b,  cores = 4)

png(file="images/pareto_linear_C.png")
plot(loo_l_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Linear Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()

png(file="images/pareto_skew_C.png")
plot(loo_s_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Skewed Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()

png(file="images/pareto_variance_C.png")
plot(loo_v_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Variance Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()

library(loo)
loo_compare(loo_l_b, loo_s_b, loo_v_b)
loo_compare(loo_l, loo_l_b)




#MINIMAL-B

load_data(type="minimal-B", target="delta", 
          standardize=TRUE)
SEED <- 123

# Imputing missing values:
which(rowSums(is.na(ships))==1)
library(mice)
imp <- mice(ships, m = 1);
ships <- complete(imp)


y = ships[,ncol(ships)]
ships[,ncol(ships)] <- NULL 

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

linear_model_min_b <- rstan::sampling(linear_m, data = stan_data, 
                                  iter=4000, seed = SEED)

## next model: skewed regression type
J = ncol(x)
mu = rep(0, times=J+1)
Sig <- matrix(0, J+1, J+1)
diag(Sig) <- 10 # weak prior variances

# test data for Stan
K <- nrow(test_data)
coltypes_t <- sapply(test_data, class)
x_test <- test_data[,coltypes_t != 'character']
x_test[,ncol(x_test)] <- NULL

stan_data <- list(y = y,
                  x = x,
                  N = N,
                  J = J,
                  K = K,
                  x_test = x_test,
                  mu = mu,
                  tau = Sig)

skew_model_min_b <- rstan::sampling(skew_m, data = stan_data, 
                                control = list(max_treedepth = 15),
                                iter=4000, seed = SEED)


## next model: variance regression type
variance_model_min_b <- rstan::sampling(variance_m, data = stan_data, 
                                    control = list(max_treedepth = 15),
                                    iter=4000, seed = SEED)



#Models Comparison

loo_l_min_b <- loo(linear_model_min_b,  cores = 4)
loo_s_min_b <- loo(skew_model_min_b,  cores = 4)
loo_v_min_b <- loo(variance_model_min_b,  cores = 4)

png(file="images/pareto_linear_B.png")
plot(loo_l_min_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Linear Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()

png(file="images/pareto_skew_B.png")
plot(loo_s_min_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Skewed Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()

png(file="images/pareto_variance_B.png")
plot(loo_v_min_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="PSIS_LOO Diagnostics (Variance Model)", pch=3)
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()


library(loo)
loo_compare(loo_l, loo_s, loo_v)
loo_compare(loo_l_b, loo_s_b, loo_v_b)
loo_compare(loo_l_min_b, loo_s_min_b, loo_v_min_b)

loo_compare(loo_l, loo_l_min_b, loo_l_b)
loo_compare(loo_s, loo_s_min_b, loo_s_b)
loo_compare(loo_v, loo_v_min_b, loo_v_b)




#Plots

png(file="images/pareto_linear.png", width = 600, height = 300)
par(mfrow=c(1,3), cex=0.9)
plot(loo_l$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="Dataset 'A'", pch=3, ylim=c(-0.3,0.7))
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)

plot(loo_l_min_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="Dataset 'B'", pch=3, ylim=c(-0.3,0.7))
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)

plot(loo_l_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="Dataset 'C'", pch=3, ylim=c(-0.3,0.7))
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()


png(file="images/pareto_skew.png", width = 600, height = 300)
par(mfrow=c(1,3), cex=0.9)
plot(loo_s$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="Dataset 'A'", pch=3, ylim=c(-0.3,0.6))
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)

plot(loo_s_min_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="Dataset 'B'", pch=3, ylim=c(-0.3,0.6))
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)

plot(loo_s_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="Dataset 'C'", pch=3, ylim=c(-0.3,0.6))
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()



png(file="images/pareto_variance.png", width = 600, height = 300)
par(mfrow=c(1,3), cex=0.9)
plot(loo_v$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="Dataset 'A'", pch=3, ylim=c(-0.4,0.4))
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)

plot(loo_v_min_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="Dataset 'B'", pch=3, ylim=c(-0.4,0.4))
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)

plot(loo_v_b$pointwise[,5], ylab="Pareto K", xlab="Data Point",
     main="Dataset 'C'", pch=3, ylim=c(-0.4,0.4))
abline(h=0.7, lty=2)
abline(h=0.5, lty=2)
dev.off()
