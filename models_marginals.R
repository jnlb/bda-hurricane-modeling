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

# Sample from the Stan models

y = ships[,ncol(ships)]
ships[,ncol(ships)] <- NULL 

coltypes <- sapply(ships, class)
x = ships[,coltypes!='character']
N = nrow(ships)
J = ncol(x)
mu = rep(0, times=J+1)
Sig <- matrix(0, J+1, J+1)
diag(Sig) <- 1 # weak prior variances

stan_data <- list(y = y,
                  x = x,
                  N = N,
                  J = J,
                  mu = mu,
                  tau = Sig)

## next model: skewed regression type
J = ncol(x)
mu = rep(0, times=J+1)
Sig <- matrix(0, J+1, J+1)
diag(Sig) <- 1 # weak prior variances

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


Sys.sleep(5)


## next model: variance regression type
variance_m <- rstan::stan_model(file = file.path(mod_path, "minimal3.stan"))
variance_model <- rstan::sampling(variance_m, data = stan_data, 
                              control = list(max_treedepth = 10),
                              iter=4000, seed = SEED)


# marginal posteriors

# I have problems getting bayesplot to work...
library("bayesplot")
posterior <- as.array(variance_model)
pdf(file="images/variance_marginals.pdf") 
mcmc_areas(posterior, pars = c("theta[1]", "theta[2]", "theta[3]", 
                                   "theta[4]", "theta[5]", "theta[6]", 
                                   "theta[7]", "theta[8]", "theta[9]", 
                                   "sigma", "alpha"),  prob = 0.8,
           prob_outer = 0.99, # 99%
           point_est = "mean")
dev.off()
