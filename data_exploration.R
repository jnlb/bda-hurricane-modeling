source('init.r')
load_data(type="all", target="delta")
library(corrplot)
#ships <- ships[,-c(8,99)] #removing DELV

# Removing variables with more than 25% NAs
#n <- nrow(ships) 
#ships <- ships[,sapply(ships, function(x) sum(length(which(is.na(x))))) < n*0.25] #from 140 to 120

indexes <- which( colnames(ships) %in% c("DELTA12", "SHRD", "CSST","VMPI", 
                                         "RHLO", "T200") ) 
correlation <- cor(ships[,indexes], use = "complete.obs")
png(file="images/corrplot_delta_small.png", width = 500, height = 500)
corrplot(correlation, method="circle", tl.col = "black", 
         tl.cex = 1.5, cl.cex = 1.25, cl.pos = "b")
dev.off()

pdf(file="images/corrplot_delta_small_presentation.pdf", width = 5, height = 5)
corrplot(correlation, method="circle", tl.col = "black", 
         tl.cex = 1.75, cl.cex = 1.5, cl.align.text = "l")
dev.off()
