#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01_run_pipeline
# Purpose of Script: Run Whole R Pipeline with parameters from 00_run.R.
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
                   out_clean_path, out_rq1,
                   out_rq2, out_rq3)){
  
  if(!dir.exists(out_files)){
  dir.create(paste0(out_files))
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# All Available Global Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Extract File names
global_files <- list.files(paste0(inp,global))
global_file_plat_man <- global_files[grepl(paste0(plat_man), global_files)]
global_file_plat_man_month <- global_files[grepl(paste0("^sor-", 
                                                        plat_man_month,
                                                        "-\\d{4}-",
                                                        plat_man_month_date,
                                                        "-\\d{2}-full\\.zip$"), 
                                                 global_files)]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Automatic or Manual Run ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Assign Files to Run
if (aut == "N"){
  if (aut_man == "Y"){
    global_files <- global_file_man
  } else if (aut_plat == "Y"){
    global_files <- global_file_plat_man
  } else if (aut_plat_month == "Y"){
    global_files <- global_file_plat_man_month
  } else {
    print("Invalid Automation Selection")
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run Data Pipeline ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (collection_only == "N" & run_results_only == "N"){
  for(i in global_files){
    
    # Extract Platform and Date
    split <- strsplit(i, "-")[[1]]
    extr_plat <- paste0(split[2])
    
    if(extr_plat == "whatsapp"){
    extr_date <- paste(split[4:6], collapse = "-")
    } else {
    extr_date <- paste(split[3:5], collapse = "-")
    }
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Run Global Data Processing
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    source(paste0(inp_code,"00_data_processing/01_global.R"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Sample Staging
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(extr_plat == "facebook" | extr_plat == "tiktok" | extr_plat == "instagram" | extr_plat == "snapchat"){
    source(paste0(inp_code,"00_data_processing/01a_stage.R"))
    }
      
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Run Platform Level Data Quality
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    source(paste0(inp_code,"00_data_processing/02_dq.R"))

    if(stop_pipeline_dead == "FALSE"){
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
    source(paste0(inp_code,"02_quant/02_rq3.R"))
  }
} 
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Aggregate All Available Outputs ----
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
if(collect == "Y"){
  source(paste0(inp_code,"03_collect/00_collect.R"))
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Results Only 
#~~~~~~~~~~~~~~~~~~~~~~~~~~
if(run_results_only == "Y"){
for(i in global_files){
  
  # Extract Platform and Date
  split <- strsplit(i, "-")[[1]]
  extr_plat <- paste0(split[2])
  
  if(extr_plat == "whatsapp"){
    extr_date <- paste(split[4:6], collapse = "-")
  } else {
    extr_date <- paste(split[3:5], collapse = "-")
  }
  
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
    source(paste0(inp_code,"02_quant/02_rq3.R"))
  
    stop_pipeline_dead <- "FALSE"
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Collection Only 
#~~~~~~~~~~~~~~~~~~~~~~~~~~
if (collection_only == "Y"){
    source(paste0(inp_code,"03_final_sample_prep/00_collect.R"))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Final Sample Preparation
#~~~~~~~~~~~~~~~~~~~~~~~~~~
if (final_sample_prep == "Y"){
  source(paste0(inp_code,"03_final_sample_prep/01_sample_prep.R"))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Dead Pipelines
#~~~~~~~~~~~~~~~~~~~~~~~~~~
if(stop_pipeline_dead == "TRUE"){
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Print Warning
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  print(paste0("NO SOR ENTRIES - PIPELINE DEAD: ", extr_plat," - ", extr_date))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Still Upstream Clean
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  source(paste0(inp_code,"00_data_processing/04_upstream_clean.R"))
}

print(paste0("PIPELINE COMPLETE - ", extr_plat, " - ", extr_date))
