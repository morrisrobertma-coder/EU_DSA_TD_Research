#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_run.R
# Purpose of Script: Define Parameters and Run Whole Pipeline.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initialization ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(list = ls())

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Parameters ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Input/Output Paths ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
### Code Input
inp_code <- c("~/06_university/00_university_of_sussex/05_summer_semester/05_dissertation/01_code/")

### Data Input
inp <- c("C:/00_temp_data_processing/")

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# File Remove ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
### Set Parameter = TRUE if global zipped files should be deleted after processing
remove_global_files <- FALSE

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Automatic or Manual Run ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# One File Approach - Define File/Date Combination
global_file_man <- "sor-x-2025-01-02-full.zip"

# One Platform Approach - Define Platform 
plat_man <- 'x'

# Define Automation - Aut = 'Y' = Run All Global Files
#                     Aut Man = 'Y' = Run One Selected File
#                     Aut Plat = 'Y' = Run One Selected Platform
aut <- "N"
aut_man <- "N"
aut_plat <- "N"

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Collect Results? ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# After run should ALL available results be amalgamated? 
collect <- "Y"

# Run ONLY COLLECTION - No calculation pipeline
collection_only <- "N"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Data Pipeline ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
source(paste0(inp_code, "01_run_pipeline.R"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gc()
rm(list = ls())
