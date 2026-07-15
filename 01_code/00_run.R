#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_run.R
# Purpose of Script: Define Parameters and Run Whole Pipeline.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initialization ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(list = ls())

# Packages
library(data.table)
library(arrow)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Parameters ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Input/Output Paths ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Code Input
inp_code <- c("~/06_university/00_university_of_sussex/05_summer_semester/05_dissertation/01_code/")

# Data Input
inp <- c("C:/00_temp_data_processing/")

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# File Remove? ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Parameter = TRUE if global zipped files should be deleted after processing
remove_global_files <- TRUE

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Automatic or Manual Run? ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# One Platform Approach - Define Platform 
plat_man <- 'tiktok'

# One Platform/One Month Approach
plat_man_month <- 'snapchat'
plat_man_month_date <- '01'
plat_man_month_year <- '2025'

# One File Approach - Define File/Date Combination
global_file_man <- "sor-tiktok-2025-04-22-full.zip"

# Define Automation - Aut = 'Y' = Run All Global Files
#                     Aut Plat = 'Y' = Run One Selected Platform
#                     Aut Plat Month = 'Y' = Run Platform/Month Combination
#                     Aut Man = 'Y' = Run One Selected File
aut <- "N"
aut_plat <- "Y"
aut_plat_month <- "N"
aut_man <- "N"

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Steps? ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
run_data_processing <- "Y"
run_sample_stage <- "Y"
run_dq <- "Y"
run_qual <- "Y"
run_cleaning <- "Y"
run_upstream <- "Y"
run_rq1 <- "Y"
run_rq2 <- "Y"
run_rq3 <- "Y"

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Results? ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
run_results_only <- "N"

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Collect Results? ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# After run should ALL available results be amalgamated? 
collect <- "Y"

# Run ONLY COLLECTION? - No calculation pipeline
collection_only <- "Y"

# Collection Parameters
collect_dq <- "Y"
collect_qual <- "Y"
collect_rq1 <- "Y"
collect_rq2 <- "Y"
collect_rq3 <- "Y"

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Final Sample Prep? ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
final_sample_prep <- "Y"

# Define Date to Retrieve Results
date_to_extract <- "2026-07-15"

# Define Version to Export
out_version <- "20260715final"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Data Pipeline ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
source(paste0(inp_code, "01_run_pipeline.R"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(list = ls())
gc()
