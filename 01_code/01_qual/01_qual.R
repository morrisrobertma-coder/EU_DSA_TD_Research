#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01_qual
# Purpose of Script: Perform Qualitative Analysis on Free Fields in Each File
# Input: Raw SOR Data.
# Output: Qualitative Frequency Tables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Full Output
out_all <- data.table()

# Run for Platform/Date 
print(paste0("QUALITATIVE ANALYSIS: ", extr_plat, " - ", extr_date, " - START AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rel_files <- list.files(paste0(map_platform[platform == extr_plat, output], extr_date))

# Define Qual Table
out_qual <- data.table(q = '',
                       statement = '')

# Define Columns of Interest
cols_of_interest <- c('incompatible_content_ground','incompatible_content_explanation',
                      'incompatible_content_illegal',
                      'decision_facts','category_specification_other',
                      'illegal_content_legal_ground',
                      'illegal_content_explanation')

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(length(rel_files) > 0){
  
  if(!(extr_plat %in% c(
    "facebook",
    "tiktok",
    "instagram",
    "snapchat"
  ))){
  dt <- data.table()
  
  # Define Files & Paths
  pop_files_full <- file.path(paste0(map_platform[platform == extr_plat, output], extr_date),
                              rel_files)
  
  # Import Data
  dt <- rbindlist(lapply(pop_files_full, function(f) fread(f, select = cols_of_interest)))
  
  } else if(extr_plat %in% c(
    "facebook",
    "tiktok",
    "instagram",
    "snapchat"
  )){
    dt <- copy(dt_samp)
  }
  
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Perform Qualitative Analysis ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(nrow(dt) > 0){

  # lower all columns (some duplicates occur as random letters capitalized)
  dt <- dt[, (cols_of_interest) := lapply(.SD, tolower), .SDcols = cols_of_interest]
      
  # incompatible content ground
  qual_1 <- dt[,.(freq = .N), by = "incompatible_content_ground"][
    , q := "incompatible_content_ground"]
  colnames(qual_1) <- c('statement','freq','q')
  
  # incompatible content explanation
  qual_2 <- dt[,.(freq = .N), by = "incompatible_content_explanation"][
    , q := "incompatible_content_explanation"]
  colnames(qual_2) <- c('statement','freq','q')
    
  # incompatible content illegal
  qual_2_1 <- dt[,.(freq = .N), by = "incompatible_content_illegal"][
    , q := "incompatible_content_illegal"]
  colnames(qual_2_1) <- c('statement','freq','q')
  
  # decision facts
  qual_3 <- dt[,.(freq = .N), by = "decision_facts"][
    , q := "decision_facts"]
  colnames(qual_3) <- c('statement','freq','q') 
    
  # category specification other
  qual_4 <- dt[,.(freq = .N), by = "category_specification_other"][
    , q := "category_specification_other"]
  colnames(qual_4) <- c('statement','freq','q')
    
  # illegal content legal ground
  qual_5 <- dt[,.(freq = .N), by = "illegal_content_legal_ground"][
    , q := "illegal_content_legal_ground"]
  colnames(qual_5) <- c('statement','freq','q')
    
  # illegal content explanation
  qual_6 <- dt[,.(freq = .N), by = "illegal_content_explanation"][
    , q := "illegal_content_explanation"]
  colnames(qual_6) <- c('statement','freq','q')
  
  # bind all outputs
  out <- rbind(qual_1, qual_2, qual_2_1, qual_3, qual_4, qual_5, qual_6)
  
  # change colnames
  setcolorder(out, neworder = c('q'))
  
  out_qual <- out
    
  # clean
  rm(out)
  gc()
  }
}

if(nrow(out_qual) > 1){
  # remove empty question
  out_qual <- out_qual[!(q == '')]

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
  
  }

if(nrow(out_all) > 0){
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Export Qualitative Analysis File ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("QUALITATIVE ANALYSIS: ", extr_date, " - EXPORT AT ", Sys.time()))

# Check for folder
file_path <- paste0(out_qual_path, extr_date)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_qual_path, extr_date))
}

# Export
write_parquet(out_all, paste0(out_qual_path, extr_date, "/", extr_plat, "_qual_analysis.parquet"))

print(paste0("QUALITATIVE ANALYSIS: ", extr_plat, " - ", extr_date, " - EXPORT COMPLETE AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(dt)
rm(out_all)
rm(out_qual)
rm(qual_1, qual_2, qual_3, qual_4, qual_5, qual_6)
gc()
}
