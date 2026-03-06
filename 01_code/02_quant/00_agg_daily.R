#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_agg_daily.R
# Purpose of Script: Analysis of Daily Data
# Input: Cleaned Daily Data.
# Output: Analysis Output.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run for each available platform 
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Total Output
out_data <- data.table()

for(plat in map_platform[, platform]){
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Data Analysis ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  print(paste0("DAILY AGGREGATION: ", plat, " ", " DATE: ", date_out, " - START AT ", Sys.time()))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Import data 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  dt <- as.data.table(read_parquet(file = paste0(out_clean_path,"/",date_out,"/",plat,".parquet")))
  
  if(nrow(dt) > 0){
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Cut down to relevant columns
    #~~~~~~~~~~~~~~~~~~~~~~~~~~  
    # Extract all 'terr' columns
    terr_cols <- names(dt)[startsWith(names(dt), "terr_")]
    cols_to_keep <- c(quant_cols, terr_cols)
    
    # cut down
    dt <- dt[, ..cols_to_keep]
    
    # clean
    gc()
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Total SOR Entries
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_1 <- data.table("total_sor_entries" =  nrow(dt))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Territory
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Frequency table per territory stated
    agg_2 <- dt[, lapply(.SD, sum, na.rm=TRUE), .SDcols = patterns("^terr_")]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Content Date and Application Date
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # find earliest content date
    dt_content_min <- data.table("content_date_earliest" = min(dt$content_d))
  
    # find latest content date
    dt_content_max <- data.table("content_date_latest" = max(dt$content_d))
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Automated Detection
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_3 <- dt[,.(amount = .N), by="aut_det"]
    agg_3 <- dcast(agg_3, 0 ~aut_det, value.var="amount")[,-1]
    colnames(agg_3) <- paste0(colnames(agg_3),"_aut_detection")
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Automated Decision
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_4 <- dt[,.(amount = .N), by="aut_dec"]
    agg_4 <- dcast(agg_4, 0 ~aut_dec, value.var="amount")[,-1]
    colnames(agg_4) <- paste0(colnames(agg_4),"_aut_decision")
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Content Type
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_5 <- dt[,.(amount = .N), by="cont_type"]
    agg_5 <- dcast(agg_5, 0 ~cont_type, value.var="amount")[,-1]
    colnames(agg_5) <- paste0(colnames(agg_5),"_content_type")
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Content Language
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_6 <- dt[,.(amount = .N), by="cont_lang"]
    agg_6 <- dcast(agg_6, 0 ~cont_lang, value.var="amount")[,-1]
    colnames(agg_6) <- paste0(colnames(agg_6),"_content_language")
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Source
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_7 <- dt[,.(amount = .N), by="source"]
    agg_7 <- dcast(agg_7, 0 ~source, value.var="amount")[,-1]
    colnames(agg_7) <- paste0(colnames(agg_7),"_source")
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Content Category - High Level
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_8 <- dt[,.(amount = .N), by="cat"]
    agg_8 <- dcast(agg_8, 0 ~cat, value.var="amount")[,-1]
    colnames(agg_8) <- paste0(colnames(agg_8),"_cat_high_level")
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Content Category - More Granular Level
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_9 <- dt[,.(amount = .N), by="cat_spec"]
    agg_9 <- dcast(agg_9, 0 ~cat_spec, value.var="amount")[,-1]
    colnames(agg_9) <- paste0(colnames(agg_9),"_cat_detailed")
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Ground
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_10 <- dt[,.(amount = .N), by="des_ground"]
    agg_10 <- dcast(agg_10, 0 ~des_ground, value.var="amount")[,-1]
    colnames(agg_10) <- paste0(colnames(agg_10),"_des_ground")
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Visibility
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_11 <- dt[,.(amount = .N), by="des_vis"]
    agg_11 <- dcast(agg_11, 0 ~des_vis, value.var="amount")[,-1]
    colnames(agg_11) <- paste0(colnames(agg_11),"_des_vis")
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Provision
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_12 <- dt[,.(amount = .N), by="des_prov"]
    agg_12 <- dcast(agg_12, 0 ~des_prov, value.var="amount")[,-1]
    colnames(agg_12) <- paste0(colnames(agg_12),"_des_prov")
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Monetary
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_13 <- dt[,.(amount = .N), by="des_mon"]
    agg_13 <- dcast(agg_13, 0 ~des_mon, value.var="amount")[,-1]
    colnames(agg_13) <- paste0(colnames(agg_13),"_des_mon")
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Account
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_14 <- dt[,.(amount = .N), by="des_acc"]
    agg_14 <- dcast(agg_14, 0 ~des_acc, value.var="amount")[,-1]
    colnames(agg_14) <- paste0(colnames(agg_14),"_des_acc")
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bind Individual Daily Data ----
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    out_ind <- data.table("platform" = paste0(plat))[, date := paste0(date_out)]
    setcolorder(out_ind, neworder = c("date","platform"))
    out_ind <- cbind(out_ind, agg_1, dt_content_min, dt_content_max,
                     agg_3, agg_4, agg_5, agg_6, 
                     agg_7, agg_8, agg_9, agg_10, agg_11, agg_12, agg_13, agg_14,
                     agg_2)
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bind to Total Output ----
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    out_data <- rbind(out_data,
                      out_ind,
                      fill = T)
 
    print(paste0("DAILY AGGREGATION: ", plat, " ", " DATE: ", date_out, " - FINISHED AT ", Sys.time())) 
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Clean Environment ----
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    rm(dt, agg_1, agg_2, agg_3, agg_4, agg_5, agg_6, agg_7, agg_8, agg_9, dt_content_max, dt_content_min)
    rm(agg_10, agg_11, agg_12, agg_13, agg_14)
    rm(out_ind)
    gc()
  
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Rename Columns ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rename columns 
setnames(
  out_data,
  old = cols_remap$old[cols_remap$old %in% names(out_data)],
  new = cols_remap$new[cols_remap$old %in% names(out_data)]
)

# order data
out_data <- out_data[order(date, platform)]

# fill NAs
out_data[is.na(out_data)] <- 0

# reorganize columns
existing_cols <- colnames(out_data)
expected_cols <- cols_remap[,new]

overlapping_cols <- intersect(expected_cols, existing_cols)

output_col_order <- c('date','platform','total_sor_entries',
                      'content_date_earliest','content_date_latest',
                      overlapping_cols, terr_cols)

setcolorder(out_data, neworder = output_col_order)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Aggregate All Platforms ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# exclude some columns
excl_cols <- c('date','platform','content_date_earliest','content_date_latest')
cols_diff <- setdiff(names(out_data), excl_cols)

# find sums of remaining columns
agg_sums <- out_data[, as.list(colSums(.SD, na.rm=TRUE)), .SDcols = cols_diff]
min_date <- min(out_data$content_date_earliest)
max_date <- max(out_data$content_date_latest)

# format all output
out_all <- data.table(date = '2026-02-16',
                      platform = 'all',
                      content_date_earliest = min_date,
                      content_date_latest = max_date,
                      agg_sums)

# final output formation
out_data <- rbind(out_data,
                  out_all)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Upload Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("DAILY AGGREGATION: ", date_out, " - EXPORT AT ", Sys.time()))

# Check for folder
file_path <- paste0(out_agg_daily_path, date_out)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_agg_daily_path, date_out))
}

# Export as Parquet File
write_parquet(out_data, paste0(out_agg_daily_path, date_out, "/aggregation_daily.parquet"))

print(paste0("DATA CLEANING: ", date_out, " - EXPORT COMPLETE AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(agg_sums, out_all)
rm(out_data)
gc()
