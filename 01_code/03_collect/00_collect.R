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

# Loop Over All Pipeline Steps
for (s in 1:nrow(steps)){
  
  # Define Outputs
  out_dt <- data.table()
  out_dq_clean <- data.table()
  
  # Extract Step
  step <- steps[s, step]
  step_path <- steps[s, path]
  
  print(paste0("RESULT COLLECTION - STEP : ", step, " - START AT ", Sys.time()))
  
  # Find All Folders
  agg_files <- list.files(step_path)
  
  for (i in agg_files){
    
    print(paste0("RESULT COLLECTION - STEP : ", step, " - DATE : ", i, " - START AT ", Sys.time()))
    # Identify Files in Sub-Folder
    avail_files <- list.files(paste0(step_path, i))
    
    # Split DQ Raw & Clean Files
    avail_files_raw <- avail_files[!grepl("_clean", avail_files)]
    avail_files_clean <- avail_files[grepl("_clean", avail_files)]
    
    # Process Files
    if(length(avail_files_raw) > 0){
      
      for (j in avail_files_raw){
        
        # Check File Type
        parq_or_csv <- grepl(".parquet", j)
        
        if(parq_or_csv){
          dt <- as.data.table(read_parquet(file = paste0(step_path, i, "/", j)))
          
        } else {
          # Import File
          dt <- fread(paste0(step_path, i, "/", j))
        }
        
        # Bind to Output
        out_dt <- rbind(out_dt,
                        dt, fill = TRUE)
        }
      
    } else {
      print("No available files for collection")
    }
    
    # Process DQ Clean Files
    if(length(avail_files_clean) > 0){

        for (t in avail_files_clean){
          # Import File
          dt_dq_clean <- fread(paste0(step_path, i, "/", t))
          
          # Bind to Output
          out_dq_clean <- rbind(out_dq_clean,
                                dt_dq_clean)
          }
      
      } else {
      print("No available dq clean files for collection")
      }
    print(paste0("RESULT COLLECTION - STEP : ", step, " - DATE : ", i, " - END AT ", Sys.time()))
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Format & Upload Data ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  print(paste0("RESULT COLLECTION - STEP : ", step, " - EXPORT ", Sys.time()))
  
  export_dt <- copy(out_dt)[, runtime := paste0(Sys.time())]
  setcolorder(export_dt, c("runtime", "platform", "date"))
  write_parquet(export_dt, paste0(file_path,"/", step, ".parquet"))
  
  if(nrow(out_dq_clean) > 0){
  export_dq_clean <- copy(out_dq_clean)[, runtime := paste0(Sys.time())]
  setcolorder(export_dq_clean, c("runtime", "platform", "date"))
  write_parquet(export_dq_clean, paste0(file_path,"/", "dq_clean.parquet"))
  }
  print(paste0("RESULT COLLECTION - STEP : ", step, " - EXPORT COMPLETE ", Sys.time()))
  print(paste0("RESULT COLLECTION - STEP : ", step, " - END AT ", Sys.time()))

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(dt)
rm(dt_dq_clean)
rm(out_dt)
rm(out_dq_clean)

print(paste0("RESULT COLLECTION: - END AT ", Sys.time()))
