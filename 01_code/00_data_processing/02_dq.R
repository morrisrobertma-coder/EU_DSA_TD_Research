#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 02_dq
# Purpose of Script: Perform Data Quality Checks on original SOR data
# Input: Raw SOR Data.
# Output: Data Quality Report per platform per time-slice
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("DATA QUALITY: ", plat, " ", date_out))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rel_files <- list.files(paste0(map_platform[platform == plat, output], date_out))

# Define DQ Table
out_dq <- data.table()

# DQ Function
table_dq <- function(check, t, v){
  tmp <- as.data.table(tibble::tribble(
    ~test,
    v))
  
  colnames(tmp) <- paste0(t)
  
  assign(paste0("dq_", check),tmp,
         envir = .GlobalEnv)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Perform Data Quality Checks
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# loop through files
for(ind_file in rel_files){
  
  # import data
  dt_dq <- as.data.table(read.csv(paste0(map_platform[platform == plat, output], date_out, "/", ind_file)))
  
  # remove index
  dt_dq <- dt_dq[, X := NULL]
  
  # column names
  dt_dq_cols <- colnames(dt_dq)
  
  # dq file name
  table_dq("1_file","File", paste0(ind_file))
  
  # number of rows
  table_dq("2_rows","Number of Rows", nrow(dt_dq))
  
  # platform name
  table_dq("3_uni_plt","No unique plat names", length(unique(dt_dq$platform_name)))
  table_dq("4_uni","Unique plat values", unique(dt_dq$platform_name))
  
  # territorial scope
  ### clean
  dt_dq$territorial_scope <- sapply(dt_dq$territorial_scope, function(x) {
    x <- sub("^\\[", "", x)
    x <- sub("\\]$", "", x)
    gsub('"', "", x)})
   
  table_dq("5_eu_eea","No EU & EEA entries", nrow(dt_dq[territorial_scope== eu_inc_eea]))
  table_dq("6_eu","No EU", nrow(dt_dq[territorial_scope== eu_ex_eea]))
  table_dq("7_terr_other","Not EU or EU and EEA", nrow(dt_dq[!(territorial_scope %in% c(eu_inc_eea, eu_ex_eea))]))
  
  # sor date - min, max
  table_dq("8_min_date","Minimum SOR Date", min(dt_dq$created_at)) 
  table_dq("9_max_date","Maximum SOR Date", max(dt_dq$created_at))
   
  # content date - min, max
  table_dq("10_min_c_date","Minimum Content Date", min(dt_dq$content_date))
  table_dq("11_max_c_date","Maximum Content Date", max(dt_dq$content_date))
   
  # collect all dq tables
  all_vars <- ls(envir= .GlobalEnv)
  dq_vars <- all_vars[grepl("^dq", all_vars)]
   
  # cbind all dq outputs
  dq_all <- data.table()
   
  for (filedq in dq_vars){
   dq_t <- get(filedq)
   dq_all <- cbind(dq_all,
                     dq_t)
  }
  
  # remove dq table
  rm(dq_t)
  
  # bind to dq output
  out_dq <- rbind(out_dq,
                  dq_all,
                  fill=TRUE)
  
  # remove all dq tables
  rm(list = dq_vars)
  
  # remove data
  rm(dq_all)
  rm(dt_dq)
  rm(dq_vars)
  
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Export Data Quality File
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("DATA QUALITY: ", plat, " ", date_out, " - EXPORT"))

# Check for folder
file_path <- paste0(out_dq_path, date_out)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_dq_path, date_out))
}

# Export
write.csv(out_dq, file = paste0(out_dq_path, date_out, "/", plat,".csv"))

print(paste0("DATA QUALITY: ", plat, " ", date_out, " - EXPORT COMPLETE"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gc()
