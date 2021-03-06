# Utilify functions to generate case table and same metrics as in WAR and HQ Admin report


# date of data export
export_date <- c("2014-11-02") # this should be the date of the most recent data pull
get_inactive_line <- function(d1, d2) {  # d1 format: YY-MM-DD
  as.Date(d1) - d2
}


# get data by case types
get_case_data <- function(dt, case_type) {
  case_dt <- dt[which(dt$case_type == case_type), ]
  return(case_dt)
}


# total cases that are 'currently open' since deployment
get_open_close <- function(dt) {
  closed <- which(dt$closed == "TRUE")  # total closed cases since deployment
  closed_case <- length(unique(dt[closed,]$case_id))
  open_case <- length(unique(dt$case_id)) - closed_case
  return(open_case)
}


# visits to open/closed case
get_visits_closed_case <- function(dt) {
  closed_case <- unique(dt[which(dt$closed == "TRUE"),]$case_id) # this returns a vector of cases that have been closed 
  return(closed_case)
}


# open case data
get_open_case <- function(dt) {
  case_open <- dt[which(dt$closed == "FALSE"),]
  return(case_open)
}


# this function selects the first row within a grouping
get_first_visit <- function(dt) {
  library(plyr)
  dt <- dt[order(dt$case_id, dt$time_start),]
  dt1 <- ddply(dt, .(case_id), function(x) x[1,])
  dt1 <- rename(dt1, c("visit_date" = "first_visit"))
  return(dt1)	
}


# this function selects the last row within a grouping 
get_last_visit <- function(dt) {
  library(plyr)
  dt <- dt[order(dt$case_id, dt$time_start),]
  dt2 <- ddply(dt, .(case_id), function(x) x[nrow(x),])
  dt2 <- rename(dt2, c("visit_date" = "last_visit"))
  return(dt2)
} 


# total visits for each case
get_total_visits <- function(dt) {
  library(plyr)
  dt <- dt[order(dt$case_id, dt$time_start),]
  dt3 <- ddply(dt, .(case_id), function(x) nrow(x))
  colnames(dt3)[2] <- c("total_visits")
  return(dt3)
}


# get cases created after the beginning of the range 
get_num_cases_created <-function(dt, d1, d2) {
  cases_created <- which(as.Date(dt$time_start) > get_inactive_line(d1, d2) & is.na(dt$prev_visit_start))
  return(length(cases_created))
}

# get cases closed before the beginning of the date range
get_num_cases_closed_before_range <- function(dt, d1, d2) {
  cases_closed_before_range <- which(as.Date(dt$time_start) < get_inactive_line(d1, d2) & dt$closed == "TRUE")
  return(length(cases_closed_before_range))  
}


# avg. days between each visit 
get_avg_days_elapsed <- function(dt) {
  library(plyr)
  dt <- dt[order(dt$case_id, dt$time_start),]
  dt4 <- ddply(dt, .(case_id), function(x) mean(as.numeric(diff(as.Date(x$time_start))))) # unit is days
  colnames(dt4)[2] <- c("avg_days_elapsed_btw_visits")
  return(dt4)
}

# match vector x, y and find element in vector x that do not match y
"%w/o%" <- function(x, y) x[!x %in% y]

# get active users for each type of cases
get_last_interaction <- function(dt) {
  library(plyr)
  dt <- dt[order(dt$user_id, dt$time_start),]
  dt5 <- ddply(dt, .(user_id), function(x) x[nrow(x),])
  colnames(dt5)[9] <- c("last_interaction")
  return(dt5)  
}


# return active mobile users
get_active_users <- function(dt) {
  user_interaction <- get_last_interaction(dt)
  inactive_line <- get_inactive_line(export_date, 30)
  user_interaction$active <- ifelse(as.Date(user_interaction$last_interaction) >= as.Date(inactive_interaction_line), "yes", "no")
  print(table(user_interaction$active))  
}


# get total days a case has been on CC: from deployment to the day of data export
get_life_length <- function(dt, export_date) {
  dt$life_length <- as.numeric(as.Date(export_date) - as.Date(dt$first_visit))
  return(dt)
}


# convert numeric days on CC to age categories for cases
get_age_range <- function(dt, x1, x2, x3){
  dt$age_range <- ifelse(dt$life_length < x1, "1", 
                         ifelse(dt$life_length >= x1 & dt$life_length < x2, "2",
                                ifelse(dt$life_length >= x2 & dt$life_length < x3, "3", "4")))
  return(dt)
}


# get inactive/active subset of case table
get_subset_120 <- function(dt, boolean) {
  dt_subset <- dt[which(dt$touched_120 == boolean),]
  return(dt_subset)
}


# unique cases created by demo_user
demo_case <- function(data) {
  demo_data <- data[which(data$user_id == "demo_user"),]
  demo_ncase <- length(unique(demo_data$case_id))  
  return(demo_ncase)
}

