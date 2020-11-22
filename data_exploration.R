source('init.r')
load_data(type="all")

ships <- ships[,-c(8,99)] #removing DELV

# Removing variables with more than 25% NAs
n <- nrow(ships) 
ships <- ships[,sapply(ships, function(x) sum(length(which(is.na(x))))) < n*0.25] #from 140 to 120

# Correlation plots
library(corrplot)
correlation <- cor(ships[,c(4:50, 119)], use = "complete.obs")
png(file="images/correlation_plot_1.png")
corrplot(correlation, method="circle", tl.col = "black", tl.cex = 0.75)
dev.off()

correlation <- cor(ships[,c(4, 51:119)], use = "complete.obs")
png(file="images/correlation_plot_2.png")
corrplot(correlation, method="circle", tl.col = "black", tl.cex = 0.75)
dev.off()

