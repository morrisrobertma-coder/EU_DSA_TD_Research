#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 02_dq
# Purpose of Script: Perform Data Quality Checks on original SOR data
# Input: Raw SOR Data.
# Output: Data Quality Report per platform per time-slice with basic DQ checks.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run per platform
#~~~~~~~~~~~~~~~~~~~~~~~~~~
for(plat in map_platform[, platform]){

print(paste0("DATA QUALITY: ", plat, " ", date_out, " START AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
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
  
  print(paste0("DATA QUALITY: ", plat, " ", date_out, " FILE - ", ind_file, " - START AT ", Sys.time()))
  
  # import data
  dt_dq <- as.data.table(read.csv(paste0(map_platform[platform == plat, output], date_out, "/", ind_file)))
  
  # remove index
  dt_dq <- dt_dq[, X := NULL]
  
  # column names
  dt_dq_cols <- colnames(dt_dq)
  
  # date
  table_dq("0_date","date",paste0(date_out))
  
  # platform
  table_dq("1_plat","platform",paste0(plat))
  
  # dq file name
  table_dq("2_file","file", paste0(ind_file))
  
  # number of rows
  table_dq("3_rows","number_of_rows", nrow(dt_dq))
  
  # platform name
  table_dq("4_uni_plt","number_unique_platform_names", length(unique(dt_dq$platform_name)))
  table_dq("5_uni","unique_platform_values", unique(dt_dq$platform_name))
  
  # territorial scope
  ### clean
  dt_dq$territorial_scope <- sapply(dt_dq$territorial_scope, function(x) {
    x <- sub("^\\[", "", x)
    x <- sub("\\]$", "", x)
    gsub('"', "", x)})
   
  table_dq("6_eu_eea","num_eu_and_eea_entries", nrow(dt_dq[territorial_scope== eu_inc_eea]))
  table_dq("7_eu","num_eu", nrow(dt_dq[territorial_scope== eu_ex_eea]))
  table_dq("8_terr_other","not_eu_or_eu_and_eea", nrow(dt_dq[!(territorial_scope %in% c(eu_inc_eea, eu_ex_eea))]))
  
  # sor date - min, max
  table_dq("9_min_date","minimum_sor_date", min(dt_dq$created_at)) 
  table_dq("10_max_date","maximum_sor_date", max(dt_dq$created_at))
  table_dq("11_na_date","number_sor_date_na", nrow(dt_dq[is.na(created_at)]))
   
  # content date - min, max
  table_dq("12_min_c_date","minimum_content_date", min(dt_dq$content_date))
  table_dq("13_max_c_date","maximum_content_date", max(dt_dq$content_date))
  table_dq("14_na_date","number_content_date_na", nrow(dt_dq[is.na(content_date)]))
  
  # application date (date restriction applied)
  table_dq("15_min_app_date","minimum_application_date", min(dt_dq$application_date))
  table_dq("16_min_app_date","maximum_application_date", max(dt_dq$application_date))
  table_dq("17_na_date","number_application_date_na", nrow(dt_dq[is.na(application_date)]))
  
  # uuid
  table_dq("18_unique_uuid","number_unique_uuids", length(unique(dt_dq$uuid)))
  
  # platform uuid
  table_dq("19_unique_plat_uuid","number_unique_platform_uuids", length(unique(dt_dq$platform_uid)))
  
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
  
  print(paste0("DATA QUALITY: ", plat, " ", date_out, " FILE - ", ind_file, " - END AT ", Sys.time()))
  
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Organize Output
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
out_col_order <- c('date','platform','file','number_of_rows',
                   'number_unique_platform_names','unique_platform_values',
                   'num_eu','num_eu_and_eea_entries','not_eu_or_eu_and_eea',
                   'minimum_sor_date',
                   'maximum_sor_date','number_sor_date_na',
                   'minimum_content_date','maximum_content_date',
                   'number_content_date_na',
                   'minimum_application_date','maximum_application_date',
                   'number_application_date_na',
                   'number_unique_uuids','number_unique_platform_uuids')

setcolorder(out_dq, out_col_order)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Flags
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# territory
out_dq <- out_dq[, check_terr := ifelse(num_eu + num_eu_and_eea_entries + not_eu_or_eu_and_eea 
                                        == number_of_rows, "N","Y")]

# unique uuids
out_dq <- out_dq[, check_uuids := ifelse(number_unique_uuids != number_of_rows, "Y","N")]

# unique platform uuids
out_dq <- out_dq[, check_plat_uuids := ifelse(number_unique_platform_uuids != number_of_rows, "Y","N")]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Export Data Quality File
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("DATA QUALITY: ", plat, " ", date_out, " - EXPORT AT ", Sys.time()))

# Check for folder
file_path <- paste0(out_dq_path, date_out)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_dq_path, date_out))
}

# Export
write.csv(out_dq, file = paste0(out_dq_path, date_out, "/", plat,".csv"),
          row.names = FALSE)

print(paste0("DATA QUALITY: ", plat, " ", date_out, " - EXPORT COMPLETE AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gc()

}
