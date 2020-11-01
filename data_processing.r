# functions to convert SHIPS data to CSV format
# to-do:
# 1. read lines from the dat file
# 2. for each chunk, take out the time0 column
# 3. move it to a data frame
# 4. after done, save the df as csv

process_ships <- function(lines) {
    # handler; checks where an observation time starts & ends
    # sends a chunk of data to the process_timestep function
    
    start <- 1
    for (i in 2:length(lines)) {
        ## check if HEAD is in the line
        head <- grepl("HEAD", lines[i], fixed = TRUE)
        
        if (head) { ## if line contains HEAD, process prior chunk
            process_timestep(lines[start:(i-1)])
            start <- i
        }
        
        
    }
    
}

process_timestep <- function(chunk) {
    # for every chunk input here, output one line for the CSV
    
    # first, get date and ID of the storm
    head <- unlist(strsplit(chunk[1], " +")) # used the regex '+'
    
    
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