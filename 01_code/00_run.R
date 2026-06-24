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
remove_global_files <- FALSE

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
global_file_man <- "sor-youtube-2026-01-01-full.zip"

# Define Automation - Aut = 'Y' = Run All Global Files
#                     Aut Plat = 'Y' = Run One Selected Platform
#                     Aut Plat Month = 'Y' = Run Platform/Month Combination
#                     Aut Man = 'Y' = Run One Selected File
aut <- "N"
aut_plat <- "N"
aut_plat_month <- "N"
aut_man <- "Y"

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Collect Results? ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# After run should ALL available results be amalgamated? 
collect <- "N"

# Run ONLY COLLECTION? - No calculation pipeline
collection_only <- "N"

# Collection Parameters
collect_dq <- "Y"
collect_qual <- "Y"
collect_rq1 <- "Y"
collect_rq2 <- "Y"
collect_rq3 <- "Y"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Data Pipeline ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
source(paste0(inp_code, "01_run_pipeline.R"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(list = ls())
gc()
