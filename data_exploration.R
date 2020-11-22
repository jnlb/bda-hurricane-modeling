source('init.r')
load_data(type="all")

ships <- ships[,-8] #removing DELV

# Removing variables with more than 25% NAs
n <- nrow(ships) 
ships <- ships[,sapply(ships, function(x) sum(length(which(is.na(x))))) < n*0.25] #from 140 to 120

# Correlation plot
library(corrplot)
correlation <- cor(ships[,4:50], use = "complete.obs")
png(file="images/correlation_plot.png")
corrplot(correlation, method="circle", tl.col = "black", tl.cex = 0.75)
dev.off()


