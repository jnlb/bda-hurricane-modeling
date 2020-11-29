source('init.r')
library(rstan)
load_data(type="large", target="delta", 
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
N = nrow(ships)
J = ncol(x)
mu = rep(0, times=J+1)
Sig <- matrix(0, J+1, J+1)
diag(Sig) <- 100 # weak prior variances

stan_data <- list(y = y,
                  x = x,
                  N = N,
                  J = J,
                  mu = mu,
                  tau = Sig)

m <- rstan::stan_model(file = file.path(mod_path, "linear.stan")) #uniform priors, I need to change them to proper priors
model <- rstan::sampling(m, data = stan_data, iter=35000, seed = SEED)


# Convergence diagnostics
monitor(model)
stan_trace(model)

# R_hat values approximate to 1, so convergence was reached.