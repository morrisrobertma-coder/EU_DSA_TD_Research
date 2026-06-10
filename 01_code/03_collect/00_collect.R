#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_collect.R
# Purpose of Script: Collect all output into single files
# Input: Qualitative and Quantitative Analysis.
# Output: Amalgamated Output.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("RESULT COLLECTION ALL PLATFORMS - START AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Data Quality ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# List all files
agg_files <- list.files(paste0(out_dq_path))

# individual agg output
out_agg_dq <- data.table()

for(i in agg_files){
  out <- data.table(date = i)
  
  for(k in map_platform[,platform]){
  out_ind <- cbind(out, data.table(file = paste0(k,".csv")))
  
  out_agg_dq <- rbind(out_agg_dq,
                      out_ind, fill = TRUE)
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import Data Quality Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# define output table
out_all_dq <- data.table()

for(j in 1:nrow(out_agg_dq)){
  
  # extract file name
  extract_date <- out_agg_dq[j, date]
  extract_file <- out_agg_dq[j, file]
  
  # import data
  dt <- tryCatch(as.data.table(read.csv(file = paste0(out_dq_path,
                                                      extract_date,"/",
                                                      extract_file))),
                 error= function(e){
                   message("skipping file: ", paste0(extract_date, extract_file))
                   return(NULL)
                 })
  # bind to output
  out_all_dq <- rbind(out_all_dq,
                      dt,
                      fill = T)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Upload DQ Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate filename
dq_data <- paste0(Sys.Date(),"_dq.parquet")

# Export as Parquet File
write_parquet(out_all_dq, paste0(out_collection, dq_data))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Qualitative Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
agg_files <- list.files(paste0(out_qual_path))

# individual agg output
out_agg <- data.table()

for(i in agg_files){
  out <- data.table(date = i)
  agg_file_ind <- list.files(paste0(out_qual_path, i))
  out_file <- data.table(file = paste0(agg_file_ind))
  out <- cbind(out,
               out_file)
  
  out_agg <- rbind(out_agg,
                   out)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import Qualitative Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# define output table
out_all_qual <- data.table()

for(j in 1:nrow(out_agg)){
  
  # extract file name
  extract_date <- out_agg[j, date]
  extract_file <- out_agg[j, file]
  
  # import data
  dt <- tryCatch(as.data.table(read.csv(file = paste0(out_qual_path,
                                             extract_date,"/",
                                             extract_file))),
                 error= function(e){
                   message("skipping file: ", paste0(extract_date))
                   return(NULL)
                 })
  # bind to output
  out_all_qual <- rbind(out_all_qual,
                        dt,
                        fill = T)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Upload Qualitative Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate filename
qual_data <- paste0(Sys.Date(),"_qual.parquet")

# Export as Parquet File
write_parquet(out_all_qual, paste0(out_collection, qual_data))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Quantitative Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
agg_files <- list.files(paste0(out_agg_daily_path))

# individual agg output
out_agg <- data.table()

for(i in agg_files){
  out <- data.table(date = i)
  agg_file_ind <- list.files(paste0(out_agg_daily_path, i))
  out_file <- data.table(file = paste0(agg_file_ind))
  out <- cbind(out,
               out_file)
  
  out_agg <- rbind(out_agg,
                   out)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import Quantitative Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# define output table
out_all <- data.table()

for(j in 1:nrow(out_agg)){
  
  # extract file name
  extract_date <- out_agg[j, date]
  extract_file <- out_agg[j, file]
  
  # import data
  dt <- as.data.table(read_parquet(file = paste0(out_agg_daily_path,
                                                 extract_date,"/",
                                                 extract_file)))
  # bind to output
  out_all <- rbind(out_all,
                   dt,
                   fill = T)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Upload Quantitative Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate filename
quant_data <- paste0(Sys.Date(),"_quant.parquet")

# Export as Parquet File
write_parquet(out_all, paste0(out_collection, quant_data))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("RESULT COLLECTION ALL PLATFORMS - END AT ", Sys.time()))
rm(dt)
rm(out_all)
rm(out_all_dq)
rm(out_all_qual)
gc()
