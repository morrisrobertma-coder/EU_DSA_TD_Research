#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01_qual
# Purpose of Script: Perform Qualitative Analysis on Free Fields in Each File
# Input: Raw SOR Data.
# Output: Qualitative Frequency Tables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Full Output
out_all <- data.table()

# Run for each available platform 
for(plat in map_platform[, platform]){
print(paste0("QUALITATIVE ANALYSIS: ", plat, " - ", date_out, " - START AT ", Sys.time()))
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Identify Relevant Files
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  rel_files <- list.files(paste0(map_platform[platform == plat, output], date_out))

  # Define Qual Table
  out_qual <- data.table(q = '',
                         statement = '')

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Perform Qualitative Analysis
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # loop through files
  for(ind_file in rel_files){
  
    # import data
    dt <- as.data.table(read.csv(paste0(map_platform[platform == plat, output], date_out, "/", ind_file)))
  
    # remove index
    dt <- dt[, X := NULL]
  
    # cut down to columns of interest
    cols_of_interest <- c('incompatible_content_ground','incompatible_content_explanation',
                          'decision_facts','category_specification_other',
                          'illegal_content_legal_ground',
                          'illegal_content_explanation')
  
    # fix this later to just use 'dt' - copy is memory expensive
    dt_cut <- copy(dt)[,..cols_of_interest]
    
    # lower all columns (some duplicates occur as random letters capitalized)
    dt_cut <- dt_cut[, (cols_of_interest) := lapply(.SD, tolower), .SDcols = cols_of_interest]
      
    # clean
    gc()
  
    # incompatible content ground
    qual_1 <- dt_cut[,.(freq = .N), by = "incompatible_content_ground"][
      , q := "incompatible_content_ground"]
    colnames(qual_1) <- c('statement','freq','q')
  
    # incompatible content explanation
    qual_2 <- dt_cut[,.(freq = .N), by = "incompatible_content_explanation"][
      , q := "incompatible_content_explanation"]
    colnames(qual_2) <- c('statement','freq','q')
  
    # decision facts
    qual_3 <- dt_cut[,.(freq = .N), by = "decision_facts"][
      , q := "decision_facts"]
    colnames(qual_3) <- c('statement','freq','q') 
    
    # category specification other
    qual_4 <- dt_cut[,.(freq = .N), by = "category_specification_other"][
      , q := "category_specification_other"]
    colnames(qual_4) <- c('statement','freq','q')
    
    # illegal content legal ground
    qual_5 <- dt_cut[,.(freq = .N), by = "illegal_content_legal_ground"][
      , q := "illegal_content_legal_ground"]
    colnames(qual_5) <- c('statement','freq','q')
    
    # illegal content explanation
    qual_6 <- dt_cut[,.(freq = .N), by = "illegal_content_explanation"][
      , q := "illegal_content_explanation"]
    colnames(qual_6) <- c('statement','freq','q')
  
    # bind all outputs
    out <- rbind(qual_1, qual_2, qual_3, qual_4, qual_5, qual_6)
  
    # change colnames
    setnames(out, 'freq', paste0(ind_file)) 
    setcolorder(out, neworder = c('q'))
  
    # merge output to master output
    out_qual <- merge(out_qual,
                      out,
                      by = c('q','statement'),
                      all = T)
  
  
}

  # remove empty question
  out_qual <- out_qual[!(q == '')]

  # fill NAs
  out_qual[is.na(out_qual)] <- 0

  # sum all files
  out_qual <- out_qual[, total := rowSums(.SD), .SDcols = 3:ncol(out_qual)]

  # keep only aggregated columns
  out_qual <- out_qual[,.(q, statement, total)]

  # add platform
  out_qual <- out_qual[, platform := paste0(plat)][
                          , date := paste0(date_out)]
  
  # add index
  out_qual <- out_qual[, q_id := .I]

  # reorder
  setcolorder(out_qual, neworder = c('platform','date','q_id'))
  
  # bind all platform data
  out_all <- rbind(out_all,
                   out_qual)
  
  print(paste0("QUALITATIVE ANALYSIS: ", plat, " - ", date_out, " - FINISHED AT ", Sys.time()))

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Export Qualitative Analysis File
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("QUALITATIVE ANALYSIS: ", date_out, " - EXPORT AT ", Sys.time()))

# Check for folder
file_path <- paste0(out_qual_path, date_out)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_qual_path, date_out))
}

# Export
write.csv(out_all, file = paste0(out_qual_path, date_out, "/qual_analysis.csv"),
          row.names = FALSE)

print(paste0("QUALITATIVE ANALYSIS: ", date_out, " - EXPORT COMPLETE AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(dt_cut)
rm(dt)
rm(out)
rm(out_all)
rm(out_qual)
rm(qual_1, qual_2, qual_3, qual_4, qual_5, qual_6)
gc()
