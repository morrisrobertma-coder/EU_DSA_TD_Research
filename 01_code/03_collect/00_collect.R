#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_collect.R
# Purpose of Script: Collect all output into single files
# Input: Qualitative and Quantitative Analysis.
# Output: Amalgamated Output.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("RESULT COLLECTION: - START AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# All Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Export Path
file_output <- paste0(Sys.Date())
file_path <- paste0(out_collection, file_output)

# Create Export Folder
if(!dir.exists(file_path)) {
  dir.create(paste0(file_path))
}

# Define All Pipeline Steps
steps <- as.data.table(tibble::tribble(
  ~step, ~path,
  "dq", out_dq_path,
  "qual", out_qual_path,
  "rq1", out_rq1,
  "rq2", out_rq2,
  "rq3", out_rq3))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Data Quality ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(collect_dq == "Y"){
  
  print(paste0("RESULT COLLECTION - STEP : DATA QUALITY - START AT ", Sys.time()))
  
  # Find All CSV Files
  all_files <- list.files(path = out_dq_path,
                          pattern = "\\.csv$",
                          recursive = TRUE,
                          full.names = TRUE)
  
  # Split into DQ and Clean DQ
  dq_clean_files <- all_files[grepl("_clean\\.csv$", basename(all_files))]
  dq_raw_files <- all_files[!grepl("_clean\\.csv$", basename(all_files))]
  
  # Read and Append All Data
  dq_clean_data <- rbindlist(lapply(dq_clean_files, fread), fill = TRUE)
  dq_raw_data <- rbindlist(lapply(dq_raw_files, fread), fill = TRUE)
  
  # Export
  write_parquet(dq_clean_data, paste0(file_path,"/dq_clean.parquet"))
  write_parquet(dq_raw_data, paste0(file_path,"/dq.parquet"))
  
  # Clean
  rm(dq_clean_data)
  rm(dq_raw_data)
  
  print(paste0("RESULT COLLECTION - STEP : DATA QUALITY - END AT ", Sys.time()))
  
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Qualitative ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(collect_qual == "Y"){
  
  print(paste0("RESULT COLLECTION - STEP : QUALITATIVE ANALYSIS - START AT ", Sys.time()))
  
  # Find All CSV Files
  all_files_csv <- list.files(path = out_qual_path,
                          pattern = "\\.csv$",
                          recursive = TRUE,
                          full.names = TRUE)

  # Read and Append All Data - CSV
  qual_data_csv <- rbindlist(lapply(all_files_csv, fread), fill = TRUE)
  
  if(nrow(qual_data_csv)> 0){
    qual_data_csv[
      , date := as.Date(date)]
  }
  
  # Find All Parquet Files
  all_files_par <- list.files(path = out_qual_path,
                              pattern = "\\.parquet$",
                              recursive = TRUE,
                              full.names = TRUE)
  
  qual_data_par <- rbindlist(lapply(all_files_par, read_parquet), fill = TRUE)
  
  if(nrow(qual_data_par) > 0){
    qual_data_par[
      , date := as.Date(date)]
  }
  
  # Bind All
  qual_data <- rbind(qual_data_csv,
                     qual_data_par)
  
  # Export
  write_parquet(qual_data, paste0(file_path,"/qual.parquet"))
  
  # Clean
  rm(qual_data)

  print(paste0("RESULT COLLECTION - STEP : QUALITATIVE ANALYSIS - END AT ", Sys.time()))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RQ1 ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(collect_rq1 == "Y"){
  
  print(paste0("RESULT COLLECTION - STEP : RESEARCH QUESTION 1 - START AT ", Sys.time()))
  
  # Find All CSV Files
  all_files_csv <- list.files(path = out_rq1,
                              pattern = "\\.csv$",
                              recursive = TRUE,
                              full.names = TRUE)
  
  # Read and Append All Data - CSV
  rq1_data_csv <- rbindlist(lapply(all_files_csv, fread), fill = TRUE)
  
  if(nrow(rq1_data_csv) > 0){
    rq1_data_csv[
    , date := as.Date(date)]
  }
  
  # Find All Parquet Files
  all_files_par <- list.files(path = out_rq1,
                              pattern = "\\.parquet$",
                              recursive = TRUE,
                              full.names = TRUE)
  
  rq1_data_par <- rbindlist(lapply(all_files_par, read_parquet), fill = TRUE)
  
  if(nrow(rq1_data_par) > 0){
    rq1_data_par[
      , date := as.Date(date)]
  }
  
  # Bind All
  rq1_data <- rbind(rq1_data_csv,
                    rq1_data_par)
  
  # Export
  write_parquet(rq1_data, paste0(file_path,"/rq1.parquet"))
  
  # Clean
  rm(rq1_data)
  
  print(paste0("RESULT COLLECTION - STEP : RESEARCH QUESTION 1 - END AT ", Sys.time()))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RQ2 ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(collect_rq2 == "Y"){
  
  print(paste0("RESULT COLLECTION - STEP : RESEARCH QUESTION 2 - START AT ", Sys.time()))
  
  # Find All CSV Files
  all_files_csv <- list.files(path = out_rq2,
                              pattern = "\\.csv$",
                              recursive = TRUE,
                              full.names = TRUE)
  
  # Read and Append All Data - CSV
  rq2_data_csv <- rbindlist(lapply(all_files_csv, fread), fill = TRUE)
  
  if(nrow(rq2_data_csv) > 0){
    rq2_data_csv[
      , date := as.Date(date)]
  }
  
  # Find All Parquet Files
  all_files_par <- list.files(path = out_rq2,
                              pattern = "\\.parquet$",
                              recursive = TRUE,
                              full.names = TRUE)
  
  rq2_data_par <- rbindlist(lapply(all_files_par, read_parquet), fill = TRUE)
  
  if(nrow(rq2_data_par) > 0){
    rq2_data_par[
      , date := as.Date(date)]
  }
  
  # Bind All
  rq2_data <- rbind(rq2_data_csv,
                    rq2_data_par)
  
  # Export
  write_parquet(rq2_data, paste0(file_path,"/rq2.parquet"))
  
  # Clean
  rm(rq2_data)
  
  print(paste0("RESULT COLLECTION - STEP : RESEARCH QUESTION 2 - END AT ", Sys.time()))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RQ3 ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(collect_rq3 == "Y"){
  
  print(paste0("RESULT COLLECTION - STEP : RESEARCH QUESTION 3 QUALITATIVE - START AT ", Sys.time()))
  
  # Find All CSV Files
  all_files_csv <- list.files(path = out_rq3,
                              pattern = "\\qual.csv$",
                              recursive = TRUE,
                              full.names = TRUE)
  
  # Read and Append All Data - CSV
  rq3_data_csv <- rbindlist(lapply(all_files_csv, fread), fill = TRUE)
  
  if(nrow(rq3_data_csv) > 0){
    rq3_data_csv[
      , date := as.Date(date)]
  }
  
  # Find All Parquet Files
  all_files_par <- list.files(path = out_rq3,
                              pattern = "\\qual.parquet$",
                              recursive = TRUE,
                              full.names = TRUE)
  
  rq3_data_par <- rbindlist(lapply(all_files_par, read_parquet), fill = TRUE)
  
  if(nrow(rq3_data_par) > 0){
    rq3_data_par[
      , date := as.Date(date)]
  }
  
  # Bind All
  rq3_data <- rbind(rq3_data_csv,
                    rq3_data_par)
  
  # Export
  write_parquet(rq3_data, paste0(file_path,"/rq3_qual.parquet"))
  
  # Clean
  rm(rq3_data)
  
  print(paste0("RESULT COLLECTION - STEP : RESEARCH QUESTION 3 QUALITATIVE - END AT ", Sys.time()))
  
  print(paste0("RESULT COLLECTION - STEP : RESEARCH QUESTION 3 QUANTITATIVE - START AT ", Sys.time()))
  
  # Find All CSV Files
  all_files_csv <- list.files(path = out_rq3,
                              pattern = "\\quant.csv$",
                              recursive = TRUE,
                              full.names = TRUE)
  
  # Read and Append All Data - CSV
  rq3_data_csv <- rbindlist(lapply(all_files_csv, fread), fill = TRUE)
  
  if(nrow(rq3_data_csv) > 0){
    rq3_data_csv[
      , date := as.Date(date)]
  }
  
  # Find All Parquet Files
  all_files_par <- list.files(path = out_rq3,
                              pattern = "\\quant.parquet$",
                              recursive = TRUE,
                              full.names = TRUE)
  
  rq3_data_par <- rbindlist(lapply(all_files_par, read_parquet), fill = TRUE)
  
  if(nrow(rq3_data_par) > 0){
    rq3_data_par[
      , date := as.Date(date)]
  }
  
  # Bind All
  rq3_data <- rbind(rq3_data_csv,
                    rq3_data_par)
  
  # Export
  write_parquet(rq3_data, paste0(file_path,"/rq3_quant.parquet"))
  
  # Clean
  rm(rq3_data)
  
  print(paste0("RESULT COLLECTION - STEP : RESEARCH QUESTION 3 QUANTITATIVE - END AT ", Sys.time()))
}


print(paste0("RESULT COLLECTION: - END AT ", Sys.time()))
