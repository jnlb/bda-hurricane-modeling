## plot with predictions vs. empirical VMAX
library(ggplot2)

## assume draws have already been taken
## if not, run 'minimal_models.R' script
## todo: reformulate all of this so it's a function which can be given input
draws = as.data.frame(hierarch_model)

# there were K draws (from test_data)
K = nrow(test_data)
v12q = matrix(data = NA, nrow = K, ncol = 3)

# 1. extract quantile info from draws
probs = c(0.1, 0.50, 0.90)
for (k in 1:K) {
    
    v12q[k,] = unname(quantile(draws[,paste0("vpred[",k,"]")], probs = probs))
    
}

v12q <- transform_back(v12q, y_mu, y_sd)