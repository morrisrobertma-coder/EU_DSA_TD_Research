#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_run_pipeline
# Purpose of Script: Run whole R pipeline for data.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initialization ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(list = ls())

# Packages
library(data.table)
library(arrow)

# Input/Output Paths
### Data Input
inp <- c("~/06_university/00_university_of_sussex/05_summer_semester/05_dissertation/00_data/")
global <- c("00_sor_global_zipped/")

### Code Input
inp_code <- c("~/06_university/00_university_of_sussex/05_summer_semester/05_dissertation/01_code/")

# Definitions 
source(paste0(inp_code, "xx_config.R"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Parameters ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Parameter = TRUE if global zipped files should be
# deleted after processing
remove_global_files <- FALSE

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
# Run Data Pipeline ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run for all dates
for(i in seq_along(dates)){
  date_out <- as.Date(dates[i])
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Run Global Data Processing
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"00_data_processing/01_global.R"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Run Platform Level Data Quality
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"00_data_processing/02_dq.R"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Run Qualitative Analysis
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"01_qual/01_qual.R"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Run Data Cleaning
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"00_data_processing/03_clean.R"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Run Quantitative Analysis Pipeline ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Daily Analysis 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"02_quant/00_agg_daily.R"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Run Upstream Data Deletion
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"00_data_processing/04_upstream_clean.R"))
  
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gc()
rm(list = ls())
