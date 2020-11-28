# this file will contain some general functions to make handling the data easy
# 1. it should be possible to load the data just by writing data("ships") or
# something similar; it should be as easy as in the main course
# 2. we should be able to easily choose which variables to include in the data
# 3. should be able to easily get the future (12h, 24h, etc.) VMAX for each row
# more? 
# if anything seems like it will be useful multiple times then it can be added
# to this file
# nrows = 12550 ## supposed to improve speed of read.csv function...

library(parallel)
options("mc.cores"=detectCores()) # to speed up MCMC simulation

data_path <- "data" # consider just reading these from somewhere?
img_path <- "images" # should organize project so that images are stored here
mod_path <- "models" # directory for storing stan model files
filename <- "atl-ships-data.csv"
file_path <- file.path(data_path, filename)

load_data <- function(type="basic", target="value", forecast=12) {
    # simple start function; like calling data("bioassay") in BDA3
    # in future; consider rewriting to make this more generally applicable
    # you can choose forecast to be any positive multiple of 6
    # type: which type of model to use; "basic" selects just a few variables
    # target: 
    # - "value" means you will predict the raw VMAX in 12 hours
    # - "delta" means you will predict the CHANGE of VMAX in 12 hours
    
    df <- read.csv(file_path, na.strings="9999", nrows=12550, stringsAsFactors = FALSE)
    
    if (type == "basic") { # variables to select when called with "basic"
        vars <- c("CSST", "RHLO", "SHRD", "T200")
        df <- df[c("ID", "TIME", "LAT.", "LON.", vars, "VMAX")]
    }
    else {
        df <- df[]
    }
    
    df <- make_target(df, type=target, forecast=forecast)
    y_mu <<- mean(df[,ncol(df)])
    y_sd <<- sd(df[,ncol(df)])
    df <- normalize(df)
    
    ships <<- df
}

make_target <- function(df, type="value", forecast=12) {
    # infer the future VMAX, i.e. the target variable that we are modeling
    # idea is that you can either make a 'delta' variable or the 'normal' value
    # i.e. delta: dVmax = VMAX(12h) - VMAX(now)
    # while normal value is just to forecast the raw windspeed in X hours
    # forecast=12; the default is a 12-hour forecast, i.e. 2 rows in the data
    # currently only works for forecast = positive multiple of 6
    
    gap <- forecast %/% 6
    
    if (type=="value") {
        varname <- paste0("VMAX",forecast)
        repval <- 20
        df[varname] <- c(df$VMAX[(1+gap):nrow(df)], rep(repval, gap)) # tempr hack
    }
    else { ## in case you create a 'delta' variable
        varname <- paste0("DELTA",forecast)
        repval <- 0
        df[varname] <- c(df$VMAX[(1+gap):nrow(df)] - df$VMAX[1:(nrow(df)-gap)], 
                         rep(repval, gap))
    }
    

    df$temp <- c(df$ID[(1+gap):nrow(df)], rep(df$ID[nrow(df)], gap))
    df$temp <- ifelse(df$ID != df$temp, 1, 0)
    df[varname] <- df$temp*repval + (1-df$temp)*df[varname]
    df$temp <- NULL
    
    return(df)
}

normalize <- function(df) {
    # apply the scale function on every numeric column in the DF
    # scale standardizes column-wise data
    
    coltypes <- sapply(df, class) # check data type of the columns
    df[,coltypes!='character'] <- scale(df[,coltypes!='character']) # standard
    
    return(df)
}

transform_back <- function(y, mu = y_mu, sd = y_sd) {
    # when we normalize the SHIPS data we also want to be able to return
    # to the natural scale; 
    # this function returns Stan samples of VMAX to the natural scale
    
    y_tf <- (y + y_mu)*y_sd
    return(y_tf)
}

replace_mismatch <- function(row, varname, repvalue=20) {
    # DEPRECATED; USING FASTER VECTORIZATION NOW
    # helper function
    
    if (row$ID != row$temp) {
        row[varname] <- repvalue
    }
    
}
