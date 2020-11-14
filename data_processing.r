# functions to convert SHIPS data to CSV format
# HOW TO USE:
# SHIPS data is released by the americans as .DAT files
# use an R function to read the lines of the DAT file, for example
# f <- file("file_name.dat", open="r")
# lines = readLines(f)
# and then call process_ships on the lines variable:
# process_ships(lines)
# HOW IT WORKS:
# 1. for every time step (6h) read the data for that time step
# 2. for each time step, take out the time0 column
# 3. move it to a data frame
# 4. after done, save the df as csv

process_ships <- function(lines) {
    # handler; checks where an observation time starts & ends
    # sends a chunk of data to the process_timestep function
    
    pb = txtProgressBar(min = 2, max = length(lines), initial = 2) 
    
    start <- 1
    for (i in 2:length(lines)) {
        ## check if HEAD is in the line
        head <- grepl("HEAD", lines[i], fixed = TRUE)
        
        if (head) { ## if line contains HEAD, process prior chunk
            temp <- process_timestep(lines[start:(i-1)])
            
            if (start < 2) {
                df <- data.frame(temp)
            }
            else {
                df1 <- data.frame(temp)
                df <- rbind(df, df1)
            }
            
            start <- i
        }
        setTxtProgressBar(pb,i)
    }
    write.csv(x=df, file="data/atl-ships-data.csv")
    return(df)
}

process_timestep <- function(chunk) {
    # for every chunk input here, output one line for the CSV
    
    # first, get date and ID of the storm
    head <- unlist(strsplit(chunk[1], " +")) # used the regex '+'
    varlist <- get_id_time(head)
    
    for (j in 3:(length(chunk))) {
        varname = substr(chunk[j], 117, 120) ## var ID on this position...
        varvalue = gsub(" ", "", substr(chunk[j], 12, 15)) ## value (t0) here...
        varlist[[varname]] <- as.numeric(varvalue)
    }
    
    return(varlist)
}

get_id_time <- function(headline) {
    # returns storm ID and time in a list
    # the input is something like
    # [1] ""         "ALBE"     "820602"   "12"       "20"       "21.7"     "87.1"    
    # [8] "1005"     "AL011982" "HEAD"  
    
    id <- headline[length(headline)-1]
    year <- substr(id, 5, 8)
    hour <- headline[4]
    datepart <- headline[3]
    month <- substr(datepart, 3, 4)
    day <- substr(datepart, 5, 6)
    datetime <- paste0(year, "-", month, "-", day, " ", hour)
    
    return(list("ID" = id, "TIME" = datetime))
}
