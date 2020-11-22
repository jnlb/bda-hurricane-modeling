source('init.r')
library(rstan)
load_data()
SEED <- 123

# Imputing missing values:
which(rowSums(is.na(ships))==1)
library(mice)
imp <- mice(ships, m = 1);
ships <- complete(imp)


# Modelling
stan_data <- list(y = ships$VMAX12,
                  x = ships[,3:9],
                  N = nrow(ships),
                  J = 7)

m <- rstan::stan_model(file = "model.stan") #uniform priors, I need to change them to proper priors
model <- rstan::sampling(m, data = stan_data, seed = SEED)


# Convergence diagnostics
monitor(model)
stan_trace(model)

# R_hat values approximate to 1, so convergence was reached.