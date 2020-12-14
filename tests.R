## plot with predictions vs. empirical VMAX
library(ggplot2)

## assume draws have already been taken
## if not, run 'minimal_models.R' script
## todo: reformulate all of this so it's a function which can be given input
draws = as.data.frame(variance_model)

# there were K draws (from test_data)
K = nrow(test_data)
v12q = matrix(data = NA, nrow = K, ncol = 3)

temp <- sapply(test_data[,"TIME"], function(x) paste0(x,":00"))

# 1. extract quantile info from draws
probs = c(0.10, 0.50, 0.90)
for (k in 1:K) {
    
    v12q[k,] = unname(quantile(draws[,paste0("vpred[",k,"]")], probs = probs))
    
}

v12q <- transform_back(v12q, y_mu, y_sd) # is this correct?
vmax_true <- transform_back(test_data$VMAX, vmax_mu, vmax_sd) # for comparison
time_true <- unname(as.POSIXct(temp)) # weird, I have to remove some labels

# 2. make a ggplot-compatible df
# needs to have TIME, lower q, mean pred, upper q, and the ground truth
# 12h predictions mean we offset by 2 steps

# these will be the columns
TIME <- time_true[3:length(time_true)]
VMAX <- vmax_true[3:length(vmax_true)]
Q10 <- vmax_true[1:(length(vmax_true)-2)] + v12q[1:(length(vmax_true)-2),1]
Q50 <- vmax_true[1:(length(vmax_true)-2)] + v12q[1:(length(vmax_true)-2),2]
Q90 <- vmax_true[1:(length(vmax_true)-2)] + v12q[1:(length(vmax_true)-2),3]

# data frame
plotdf <- data.frame(TIME, VMAX, Q10, Q50, Q90)

# 3. output the ggplot graphic
evalplot <- ggplot(data=plotdf, aes(y=VMAX, x=TIME)) +
    geom_point() + geom_line() +
    geom_ribbon(aes(ymin=Q10, ymax=Q90), linetype=2, alpha=0.1)
ggsave("testplot.png", path = img_path, device = png())