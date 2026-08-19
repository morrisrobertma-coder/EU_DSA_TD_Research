#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01_qual
# Purpose of Script: Perform Qualitative Analysis on Free Fields in Each File
# Input: Raw SOR Data.
# Output: Qualitative Frequency Tables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Full Output
out_all <- data.table()

# Run for Platform/Date 
print(paste0("QUALITATIVE ANALYSIS - Content Type Other: ", extr_plat, " - ", extr_date, " - START AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rel_files <- list.files(paste0(map_platform[platform == extr_plat, output], extr_date))

# Define Qual Table
out_qual <- data.table(q = '',
                       statement = '')

# Define Columns of Interest
cols_of_interest <- c('content_type_other')

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(length(rel_files) > 0){
  
  # Define Files & Paths
  pop_files_full <- file.path(paste0(map_platform[platform == extr_plat, output], extr_date),
                              rel_files)
  
  # Import Data
  dt <- rbindlist(lapply(pop_files_full, function(f) fread(f, select = cols_of_interest)))
  
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Perform Qualitative Analysis ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(nrow(dt) > 0){

  # lower all columns (some duplicates occur as random letters capitalized)
  dt <- dt[, (cols_of_interest) := lapply(.SD, tolower), .SDcols = cols_of_interest]
      
  # content type other
  qual_x <- dt[,.(freq = .N), by = "content_type_other"][
    , q := "content_type_other"]
  colnames(qual_x) <- c('statement','freq','q')
  
  # assign output
  out <- qual_x
  
  # change colnames
  setcolorder(out, neworder = c('q'))
  
  out_qual <- out
    
  # clean
  rm(out)
  gc()
  }
}

  # fill NAs
  out_qual[is.na(out_qual)] <- 0

  # sum all files
  out_qual <- out_qual[, total := rowSums(.SD), .SDcols = 3:ncol(out_qual)]

  # keep only aggregated columns
  out_qual <- out_qual[,.(q, statement, total)]

  # add platform
  out_qual <- out_qual[, platform := paste0(extr_plat)][
                          , date := paste0(extr_date)]
  
  # add index
  out_qual <- out_qual[, q_id := .I]

  # reorder
  setcolorder(out_qual, neworder = c('platform','date','q_id'))
  
  # bind all platform data
  out_all <- rbind(out_all,
                   out_qual)
  
if(nrow(out_all) > 0){
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Export Qualitative Analysis File ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("QUALITATIVE ANALYSIS - Content Type Other: ", extr_date, " - EXPORT AT ", Sys.time()))

# Check for folder
file_path <- paste0(out_qual_path_cto, extr_date)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_qual_path_cto, extr_date))
}

# Export
write_parquet(out_all, paste0(out_qual_path_cto, extr_date, "/", extr_plat, "_qual_cto_analysis.parquet"))

print(paste0("QUALITATIVE ANALYSIS - Content Type Other: ", extr_plat, " - ", extr_date, " - EXPORT COMPLETE AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(dt)
rm(out_all)
rm(out_qual)
gc()
}
