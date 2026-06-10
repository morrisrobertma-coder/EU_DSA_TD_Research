#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01_rq2.R
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
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Synthetic Media Flag
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    dt <- dt[, syn_flag := ifelse(cont_type == 'sm', 1, 0)]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Total SOR Entries
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_0 <- dt[,.(total_sor_entries = .N), by = "syn_flag"]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Automated Detection
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # 1 = 'Synthetic Media'
    # 2 = 'Non-Synthetic Media'
    agg_1 <- dt[,.(amount = .N), by=c("aut_det","syn_flag")]
    agg_1 <- dcast(agg_1, syn_flag~aut_det, value.var="amount")
    setnames(agg_1, old = setdiff(names(agg_1), "syn_flag"),
             new = paste0(setdiff(names(agg_1), "syn_flag"),"_aut_detection"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Automated Decision
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_2 <- dt[,.(amount = .N), by=c("aut_dec","syn_flag")]
    agg_2 <- dcast(agg_2, syn_flag~aut_dec, value.var="amount")
    setnames(agg_2, old = setdiff(names(agg_2), "syn_flag"),
             new = paste0(setdiff(names(agg_2), "syn_flag"),"_aut_decision"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Source
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_3 <- dt[,.(amount = .N), by=c("source","syn_flag")]
    agg_3 <- dcast(agg_3, syn_flag~source, value.var="amount")
    setnames(agg_3, old = setdiff(names(agg_3), "syn_flag"),
             new = paste0(setdiff(names(agg_3), "syn_flag"),"_source"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Ground
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_4 <- dt[,.(amount = .N), by=c("des_ground","syn_flag")]
    agg_4 <- dcast(agg_4, syn_flag~des_ground, value.var="amount")
    setnames(agg_4, old = setdiff(names(agg_4), "syn_flag"),
             new = paste0(setdiff(names(agg_4), "syn_flag"),"_des_ground"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Visibility
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_5 <- dt[,.(amount = .N), by=c("des_vis","syn_flag")]
    agg_5 <- dcast(agg_5, syn_flag~des_vis, value.var="amount")
    setnames(agg_5, old = setdiff(names(agg_5), "syn_flag"),
             new = paste0(setdiff(names(agg_5), "syn_flag"),"_des_vis"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Provision
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_6 <- dt[,.(amount = .N), by=c("des_prov","syn_flag")]
    agg_6 <- dcast(agg_6, syn_flag~des_prov, value.var="amount")
    setnames(agg_6, old = setdiff(names(agg_6), "syn_flag"),
             new = paste0(setdiff(names(agg_6), "syn_flag"),"_des_prov"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Monetary
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_7 <- dt[,.(amount = .N), by=c("des_mon","syn_flag")]
    agg_7 <- dcast(agg_7, syn_flag~des_mon, value.var="amount")
    setnames(agg_7, old = setdiff(names(agg_7), "syn_flag"),
             new = paste0(setdiff(names(agg_7), "syn_flag"),"_des_mon"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Decision Account
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_8 <- dt[,.(amount = .N), by=c("des_acc","syn_flag")]
    agg_8 <- dcast(agg_8, syn_flag~des_acc, value.var="amount")
    setnames(agg_8, old = setdiff(names(agg_8), "syn_flag"),
             new = paste0(setdiff(names(agg_8), "syn_flag"),"_des_acc"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bind Individual Daily Data ----
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    tables <- list(agg_0, agg_1, agg_2, agg_3, agg_4, agg_5, agg_6, agg_7, agg_8)
    
    out_dt <- Reduce(function(x,y) merge(x, y, by = "syn_flag", all = TRUE),
                     tables)
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bind
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    out_data <- rbind(out_data,
                      out_dt, fill = T)
  
    print(paste0("RQ2: ", extr_plat, " - ", " DATE: ", extr_date, " FILE ", subfile," - FINISHED AT ", Sys.time()))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Clean Environment ----
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    rm(dt)
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Daily Aggregation ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# fill NAs
out_data[is.na(out_data)] <- 0

out_data_agg <- out_data[, lapply(.SD, sum), by = syn_flag, .SDcols = !'syn_flag']

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Format Output ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
out_data_agg <- out_data_agg[,':='(platform = paste0(extr_plat),
                                   date = paste0(extr_date))]

setnames(
  out_data_agg,
  old = cols_remap$old[cols_remap$old %in% names(out_data_agg)],
  new = cols_remap$new[cols_remap$old %in% names(out_data_agg)]
)

# order data
out_data_agg <- out_data_agg[order(date, platform)]

output_col_order <- c('date','platform','syn_flag')

setcolorder(out_data_agg, neworder = output_col_order)

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
write_parquet(out_data_agg, paste0(out_rq2, extr_date, "/", extr_plat,"_rq2.parquet"))

print(paste0("RQ2: ", extr_plat, " - ", extr_date, " - EXPORT COMPLETE AT: ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(out_dt)
rm(out_data)
rm(out_data_agg)
gc()
