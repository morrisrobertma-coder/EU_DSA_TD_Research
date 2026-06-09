#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_agg_daily.R
# Purpose of Script: Research Question 2 - Sourcing, Detection, Moderation
# Input: Cleaned Daily Data.
# Output: Analysis Output.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run for each available platform 
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Total Output
out_data <- data.table()

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rel_files <- list.files(paste0(out_clean_path, extr_date, "-", extr_plat,"/"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Up Output File ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Check for folder
file_path <- paste0(out_rq1, extr_date)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_rq1, extr_date))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Data Analysis ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Loop through all files
for(subfile in rel_files){
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Import Data 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  dt <- as.data.table(read_parquet(file = paste0(out_clean_path, extr_date,"-", extr_plat, "/", subfile)))
  
  print(paste0("RQ2: ", extr_plat, " - ", " DATE: ", extr_date, " FILE ", subfile," - START AT ", Sys.time()))
  
  if(nrow(dt) > 0){
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Cut down to relevant columns
    #~~~~~~~~~~~~~~~~~~~~~~~~~~  
    # Extract all 'terr' columns
    terr_cols <- names(dt)[startsWith(names(dt), "terr_")]
    cols_to_keep <- c(rq2_cols, terr_cols)
    
    # cut down
    dt <- dt[, ..cols_to_keep]
    
    # clean
    gc()
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Synthetic Media Flag
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    dt <- dt[, syn_flag := ifelse(cont_type == 'sm', 1, 0)]
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Platform
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    dt <- dt[, platform := paste0(extr_plat)]  
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bind
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    out_data <- rbind(out_data,
                      dt)
  
    print(paste0("RQ2: ", extr_plat, " - ", " DATE: ", extr_date, " FILE ", subfile," - FINISHED AT ", Sys.time()))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Clean Environment ----
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    rm(dt)
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Rename Columns ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# order data
out_data <- out_data[order(date, platform)]

# fill NAs
out_data[is.na(out_data)] <- 0

output_col_order <- c('date','platform','syn_flag')

setcolorder(out_data, neworder = output_col_order)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Upload Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("RQ2: ", extr_plat, " - ", extr_date, " - EXPORT AT: ", Sys.time()))

# Check for folder
file_path <- paste0(out_rq2, extr_date)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_rq2, extr_date))
}

# Export as Parquet File
write_parquet(out_data, paste0(out_rq2, extr_date, "/", extr_plat,"_rq2.parquet"))

print(paste0("RQ2: ", extr_plat, " - ", extr_date, " - EXPORT COMPLETE AT: ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(out_data)
gc()
