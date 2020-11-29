source('init.r')
load_data(type="all", target="delta")

#ships <- ships[,-c(8,99)] #removing DELV

# Removing variables with more than 25% NAs
n <- nrow(ships) 
ships <- ships[,sapply(ships, function(x) sum(length(which(is.na(x))))) < n*0.25] #from 140 to 120
#ships <- ships[,-c(113:118)] #Removing "IR00", "IRM1", "IRM3", "PC00", "PCM1","PCM3"

# Correlation plots
library(corrplot)
correlation <- cor(ships[,c(4:39,75)], use = "complete.obs")
png(file="images/corrplot_delta_1.png")
corrplot(correlation, method="circle", tl.col = "black", tl.cex = 0.75)
dev.off()

correlation <- cor(ships[,c(4, 40:75)], use = "complete.obs")
png(file="images/corrplot_delta_2.png")
corrplot(correlation, method="circle", tl.col = "black", tl.cex = 0.75)
dev.off()

