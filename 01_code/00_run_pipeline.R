#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_run_pipeline
# Purpose of Script: Run Whole R Pipeline for Data Processing.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initialization ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(list = ls())

# Packages
library(data.table)
library(arrow)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Input/Output Paths
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Data Input
inp <- c("C:/00_temp_data_processing/")
#inp <- c("~/06_university/00_university_of_sussex/05_summer_semester/05_dissertation/00_data/")

### Code Input
inp_code <- c("~/06_university/00_university_of_sussex/05_summer_semester/05_dissertation/01_code/")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Support Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
source(paste0(inp_code, "xx_config.R"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create Folders ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for(out_files in c(zip_in, zip_mid_out, zip_out,
                   out_per_platform, out_facebook,
                   out_youtube, out_whatsapp, out_instagram,
                   out_tiktok, out_snap, out_x,
                   out_dq_path, out_qual_path,
                   out_clean_path)){
  
  if(!dir.exists(out_files)){
  dir.create(paste0(out_files))
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Parameters ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# File Remove
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Parameter = TRUE if global zipped files should be
# deleted after processing
remove_global_files <- FALSE

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# All Available Global Files
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Extract File names
global_files <- list.files(paste0(inp,global))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Automatic or Manual Run ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# One File Approach
## Define File & Date if Manual Run Needed
global_file_man <- "sor-instagram-2025-01-02-full.zip"

# One Platform Approach
plat_man <- 'x'
global_file_plat_man <- global_files[grepl(paste0(plat_man), global_files)]

# Define Automation
## Aut = 'Y' = Run All Global Files
## Aut Man = 'Y' = Run One Selected File
## Aut Plat = 'Y' = Run One Selected Platform
aut <- "N"
aut_man <- "N"
aut_plat <- "Y"

if (aut == "N"){
  if (aut_man == "Y"){
    global_files <- global_file_man
  } else if (aut_plat == "Y"){
  global_files <- global_file_plat_man
  } else {
    print("Invalid Automation Selection")
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Data Pipeline ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for(i in global_files){
  
  # Extract Platform and Date
  split <- strsplit(i, "-")[[1]]
  extr_plat <- paste0(split[2])
  extr_date <- paste(split[3:5], collapse = "-")
    
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
  # Run Upstream Data Deletion
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"00_data_processing/04_upstream_clean.R"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Run Quantitative Analysis Pipeline ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # RQ1 - Data Aggregation 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"02_quant/00_rq1.R"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # RQ2 - Source, Detection, Moderation 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"02_quant/01_rq2.R"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # RQ3 - Categorization & Legal Status 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  #source(paste0(inp_code,"02_quant/02_rq3.R"))
  
}    
    
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Aggregate All Output ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#source(paste0(inp,"03_collect/00_collect.R"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gc()
rm(list = ls())
