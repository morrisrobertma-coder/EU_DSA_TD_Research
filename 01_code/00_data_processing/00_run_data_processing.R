#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_run_data_preparation
# Purpose of Script: Run data preparation for all downloaded global files
#                    from DSA website.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initialization ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(list = ls())

# Packages
library(data.table)

# Input/Output Paths
inp <- c("~/06_university/00_university_of_sussex/05_summer_semester/05_dissertation/00_data/")
inp_code <- c("~/06_university/00_university_of_sussex/05_summer_semester/05_dissertation/01_code/")
global <- c("00_sor_global_zipped/")

# Definitions 
source(paste0(inp_code, "xx_config.R"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Available Global Files
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Extract File names
global_files <- list.files(paste0(inp,global))

# Define dates in vector
dates <- vector("character", length(global_files))

for (i in seq_along(global_files)){
  dates[i] <- sub(".*-(\\d{4}-\\d{2}-\\d{2})-.*", "\\1", global_files[i])
}

dates <- as.Date(dates, format = "%Y-%m-%d")

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Data Processing
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run for all dates

for(i in seq_along(dates)){
  date_out <- as.Date(dates[i])
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 01_global_processing.R
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # run global processing
  source(paste0(inp_code,"00_data_processing/01_global.R"))
  
  # clean up
  gc()
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 02_facebook_processing.R
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  
  
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gc()
rm(list = ls())
