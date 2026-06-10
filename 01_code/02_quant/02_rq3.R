#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 02_rq3.R
# Purpose of Script: Research Question 3 - Content Categorization and Legal 
# Status
# Input: Cleaned Daily Data.
# Output: Analysis Output.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run for each available platform 
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Total Output
out_data_qual <- data.table()
out_dt <- data.table()

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rel_files <- list.files(paste0(out_clean_path, extr_date, "-", extr_plat,"/"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Up Output File ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Check for folder
file_path <- paste0(out_rq3, extr_date)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_rq3, extr_date))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import Qualitative Analysis Results ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dt_qual_imp <- as.data.table(fread(file = paste0(out_qual_path, extr_date, "/",
                                             extr_plat,"_qual_analysis.csv")))

# filter by platform
# cut to statement and q_id
dt_qual_imp <- dt_qual_imp[platform == extr_plat][
  ,.(statement, q, q_id)]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Data Analysis ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Loop through all files
for(subfile in rel_files){
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Import Data 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  dt <- as.data.table(read_parquet(file = paste0(out_clean_path, extr_date,"-", extr_plat, "/", subfile)))
  
  print(paste0("RQ3: ", extr_plat, " - ", " DATE: ", extr_date, " FILE ", subfile," - START AT ", Sys.time()))
  
  if(nrow(dt) > 0){
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Split into Quant/Qual Analyses
    #~~~~~~~~~~~~~~~~~~~~~~~~~~  
    cols_to_keep_quant <- c(rq3_cols_quant)
    cols_to_keep_qual <- c(rq3_cols_qual)
    
    # cut down
    dt_quant <- dt[, ..cols_to_keep_quant]
    dt_qual <- dt[, ..cols_to_keep_qual]
    
    # remove original data
    rm(dt)
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Assign ID Column
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    dt_quant <- dt_quant[, sor_id := .I]
    dt_qual <- dt_qual[, sor_id := .I]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Synthetic Media Flag
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    dt_quant <- dt_quant[, syn_flag := ifelse(cont_type == 'sm', 1, 0)]
    dt_qual <- dt_qual[, syn_flag := ifelse(cont_type == 'sm', 1, 0)]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Illegal Flag
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    dt_quant <- dt_quant[, illegal_flag := ifelse(des_ground == 'illc', 1, 0)]
    
    ### Extract IDs and assign to Qual
    ill_ids <- dt_quant[illegal_flag == 1,sor_id]
    
    dt_qual <- dt_qual[sor_id %in% ill_ids, illegal_flag := 1]
    
    ### Format
    setcolorder(dt_quant, c("sor_id","syn_flag","illegal_flag"))
    setcolorder(dt_qual, c("sor_id","syn_flag","illegal_flag"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Total SORs
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_0 <- dt_quant[,.(total_sor_entries = .N), by = c("syn_flag", "illegal_flag")]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Quant - Aggregate - Category 
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_1 <- dt_quant[,.(amount = .N), by=c("cat","syn_flag","illegal_flag")]
    agg_1 <- dcast(agg_1, syn_flag + illegal_flag ~cat, value.var="amount")
    setnames(agg_1, old = setdiff(names(agg_1), c("syn_flag","illegal_flag")),
             new = paste0(setdiff(names(agg_1), c("syn_flag","illegal_flag")),"_cat_high_level"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Quant - Aggregate - Category Specification
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_2 <- dt_quant[,.(amount = .N), by=c("cat_spec","syn_flag","illegal_flag")]
    agg_2 <- dcast(agg_2, syn_flag + illegal_flag ~cat_spec, value.var="amount")
    setnames(agg_2, old = setdiff(names(agg_2), c("syn_flag","illegal_flag")),
             new = paste0(setdiff(names(agg_2), c("syn_flag","illegal_flag")),"_cat_detailed"))
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Qual - Aggregate - Category Specification Other
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_3 <- dt_qual[,.(amount = .N), by = c("cat_spec_other","syn_flag","illegal_flag")]
    
    ### merge original qual string back
    agg_3 <- merge(agg_3, 
                   dt_qual_imp[,.(statement, q_id)],
                   by.x = "cat_spec_other",
                   by.y = "q_id",
                   all.x = T)[, qual_cat := "cat_spec_other"][
                     , cat_spec_other := NULL]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Qual - Aggregate - Descision Facts
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_4 <- dt_qual[,.(amount = .N), by = c("des_fact","syn_flag","illegal_flag")]
    
    ### merge original qual string back
    agg_4 <- merge(agg_4, 
                   dt_qual_imp[,.(statement, q_id)],
                   by.x = "des_fact",
                   by.y = "q_id",
                   all.x = T)[, qual_cat := "des_fact"][
                     , des_fact := NULL]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Qual - Aggregate - Illegal Category Ground
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_5 <- dt_qual[,.(amount = .N), by = c("illegal_c_ground","syn_flag","illegal_flag")]
    
    ### merge original qual string back
    agg_5 <- merge(agg_5, 
                   dt_qual_imp[,.(statement, q_id)],
                   by.x = "illegal_c_ground",
                   by.y = "q_id",
                   all.x = T)[, qual_cat := "illegal_c_ground"][
                     , illegal_c_ground := NULL]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Qual - Aggregate - Illegal Category Explanation
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_6 <- dt_qual[,.(amount = .N), by = c("illegal_c_ex","syn_flag","illegal_flag")]
    
    ### merge original qual string back
    agg_6 <- merge(agg_6, 
                   dt_qual_imp[,.(statement, q_id)],
                   by.x = "illegal_c_ex",
                   by.y = "q_id",
                   all.x = T)[, qual_cat := "illegal_c_ex"][
                     , illegal_c_ex := NULL]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Qual - Aggregate - Incompatible Content Illegal
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_7 <- dt_qual[,.(amount = .N), by = c("incomp_c_illegal","syn_flag","illegal_flag")]
    
    ### merge original qual string back
    agg_7 <- merge(agg_7, 
                   dt_qual_imp[,.(statement, q_id)],
                   by.x = "incomp_c_illegal",
                   by.y = "q_id",
                   all.x = T)[, qual_cat := "incomp_c_illegal"][
                     , incomp_c_illegal := NULL]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Qual - Aggregate - Incompatible Content Legal Ground
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_8 <- dt_qual[,.(amount = .N), by = c("incomp_c_ground","syn_flag","illegal_flag")]
    
    ### merge original qual string back
    agg_8 <- merge(agg_8, 
                   dt_qual_imp[,.(statement, q_id)],
                   by.x = "incomp_c_ground",
                   by.y = "q_id",
                   all.x = T)[, qual_cat := "incomp_c_ground"][
                     , incomp_c_ground := NULL]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Qual - Aggregate - Incompatible Content Explanation
    #~~~~~~~~~~~~~~~~~~~~~~~~~~
    agg_9 <- dt_qual[,.(amount = .N), by = c("incomp_c_ex","syn_flag","illegal_flag")]
    
    ### merge original qual string back
    agg_9 <- merge(agg_9, 
                   dt_qual_imp[,.(statement, q_id)],
                   by.x = "incomp_c_ex",
                   by.y = "q_id",
                   all.x = T)[, qual_cat := "incomp_c_ex"][
                     , incomp_c_ex := NULL]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Quant Bind Individual Daily Data ----
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    tables <- list(agg_0, agg_1, agg_2)
    
    out_dt_quant <- Reduce(function(x,y) merge(x, y, by = c("syn_flag","illegal_flag"), all = TRUE),
                           tables)
    
    out_dt <- rbind(out_dt,
                    out_dt_quant, fill = T)
  
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Qual Bind Individual Daily Data ----
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    tables_qual <- list(agg_3, agg_4, agg_5, agg_6, agg_7, agg_8)
    
    for (t in tables_qual){
      out_data_qual <- rbind(out_data_qual,
                             t, fill = T)
    }
    
    print(paste0("RQ3: ", extr_plat, " - ", " DATE: ", extr_date, " FILE ", subfile," - FINISHED AT ", Sys.time()))
    
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Daily Aggregation - Quant ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# fill NAs
out_dt[is.na(out_dt)] <- 0

out_data_agg <- out_dt[, lapply(.SD, sum), by = c('syn_flag','illegal_flag'), .SDcols = !c('syn_flag','illegal_flag')]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Daily Aggregation - Qual ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
out_data_qual_agg <- out_data_qual[, lapply(.SD, sum), by = c('syn_flag','illegal_flag',
                                                              'statement','qual_cat'),
                                   .SDcols = !c('syn_flag','illegal_flag',
                                                'statement','qual_cat')]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Format Output - Quant ----
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

output_col_order <- c('date','platform','syn_flag','illegal_flag')

setcolorder(out_data_agg, neworder = output_col_order)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Upload Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("RQ3: ", extr_plat, " - ", extr_date, " - EXPORT AT: ", Sys.time()))

# Check for folder
file_path <- paste0(out_rq3, extr_date)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_rq3, extr_date))
}

# Export as Parquet File
write_parquet(out_data_agg, paste0(out_rq3, extr_date, "/", extr_plat,"_rq3.parquet"))

print(paste0("RQ3: ", extr_plat, " - ", extr_date, " - EXPORT COMPLETE AT: ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(out_dt)
rm(out_data)
rm(out_data_agg)
gc()
