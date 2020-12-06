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
ships[,ncol(ships)] <- NULL ## ah, severe bug. somebody kill me now

# setup the x data
coltypes <- sapply(ships, class)
x = ships[,coltypes!='character']
N = nrow(ships)
J = ncol(x)
mu = rep(0, times=J+1)
Sig <- matrix(0, J+1, J+1)
diag(Sig) <- 10 # weak prior variances

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
shr_test <- x_test$SHRD
x_test$SHRD <- NULL
x_test[,ncol(x_test)] <- NULL


stan_data <- list(y = y,
                  x = x,
                  shr = shr,
                  N = N,
                  J = J,
                  K = K,
                  x_test = x_test,
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

