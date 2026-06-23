#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 02_dq
# Purpose of Script: Perform Data Quality Checks on original SOR data
# Input: Raw SOR Data.
# Output: Data Quality Report per platform per time-slice with basic DQ checks.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run per Platform/Date
#~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("DATA QUALITY: ", extr_plat, " ", extr_date, " START AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rel_files <- list.files(paste0(map_platform[platform == extr_plat, output], extr_date))

if(length(rel_files) > 0){
# Define DQ Table
out_dq <- data.table()

# DQ Function
table_dq <- function(check, t, v){
  tmp <- as.data.table(v)
  
  colnames(tmp) <- c("file", t)
  
  assign(paste0("dq_", check),tmp,
         envir = .GlobalEnv)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(!(extr_plat %in% c(
  "facebook",
  "tiktok",
  "instagram",
  "snapchat"
))){
dt_dq <- data.table()

# Define Files & Paths
pop_files_full <- file.path(paste0(map_platform[platform == extr_plat, output], extr_date),
                            rel_files)

# Import Data
dt_dq <- rbindlist(lapply(pop_files_full, function(f) {
                   dt <- fread(f)
                   dt[, file := basename(f)]}))

} else if(extr_plat %in% c(
  "facebook",
  "tiktok",
  "instagram",
  "snapchat"
)){
  dt_dq <- copy(dt_samp)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Perform Data Quality Checks
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (nrow(dt_dq) > 0){

  # column names
  dt_dq_cols <- colnames(dt_dq)
  
  # date
  dq_0_date <- data.table(date = paste0(extr_date))
  
  # platform
  dq_1_plat <- data.table(platform = paste0(extr_plat))

  # number of rows
  table_dq("3_rows","number_of_rows", dt_dq[,.N, by = file])
  
  # platform name
  table_dq("4_uni_plt","number_unique_platform_names", dt_dq[,.(n_platforms = uniqueN(platform_name)), by = file])
  table_dq("5_uni","unique_platform_values", dt_dq[, .(platforms = paste(unique(platform_name), collapse = ", ")), by = file])

  # territorial scope
  ### clean
  dt_dq[, terr := territorial_scope]
  dt_dq[, territorial_scope := sub("^\\[", "", territorial_scope)]
  dt_dq[, territorial_scope := sub("\\]$", "", territorial_scope)]
  dt_dq[, territorial_scope := gsub('"', "", territorial_scope, fixed = TRUE)]
   
  table_dq("6_eu_eea","num_eu_and_eea_entries", dt_dq[,.(num_eu_and_eesa_entries = sum(territorial_scope == eu_inc_eea)), by = file])
  table_dq("7_eu","num_eu", dt_dq[,.(num_eu = sum(territorial_scope == eu_ex_eea)), by = file])
  table_dq("8_terr_other","not_eu_or_eu_and_eea", dt_dq[,.(not_eu_or_eu_and_eea = sum(!(territorial_scope %in% c(eu_inc_eea, eu_ex_eea)))), by = file])
  
  # sor date - min, max
  table_dq("9_min_date","minimum_sor_date", dt_dq[,.(min_date = min(created_at, na.rm = TRUE)), by = file])
  table_dq("10_max_date","maximum_sor_date", dt_dq[,.(max_date = max(created_at, na.rm = TRUE)), by = file])
  table_dq("11_na_date","number_sor_date_na", dt_dq[,.(number_sor_date_na = sum(is.na(created_at))), by = file])
   
  # content date - min, max
  table_dq("12_min_c_date","minimum_content_date", dt_dq[,.(min_date = min(content_date)), by = file])
  table_dq("13_max_c_date","maximum_content_date", dt_dq[,.(max_date = max(content_date)), by = file])
  table_dq("14_na_date","number_content_date_na", dt_dq[,.(number_content_date_na = sum(is.na(content_date))), by = file])
  
  # application date (date restriction applied)
  table_dq("15_min_app_date","minimum_application_date", dt_dq[,.(min_date = min(application_date)), by = file])
  table_dq("16_min_app_date","maximum_application_date", dt_dq[,.(max_date = max(application_date)), by = file])
  table_dq("17_na_date","number_application_date_na", dt_dq[,.(number_application_date_na = sum(is.na(application_date))), by = file])
  
  # uuid
  table_dq("18_unique_uuid","number_unique_uuids", dt_dq[, .(n_uuid = uniqueN(uuid)), by = file])
  
  # platform uuid
  table_dq("19_unique_plat_uuid","number_unique_platform_uuids", dt_dq[, .(n_platform_uid = uniqueN(platform_uid)), by = file])
  
  # collect all dq tables
  all_vars <- ls(envir= .GlobalEnv)
  dq_vars <- all_vars[grepl("^dq", all_vars)]
  dq_vars <- setdiff(dq_vars, c("dq_0_date","dq_1_plat"))
  
  # cbind all dq outputs
  dq_all <- data.table()
  
  dq_all <- Reduce(function(x,y) merge(x, y, by = "file", all = TRUE),
                   mget(dq_vars))
  
  dq_all <- cbind(dq_all, 
                  dq_0_date,
                  dq_1_plat)
  
  # bind to dq output
  out_dq <- dq_all
  
  # remove all dq tables
  rm(list = dq_vars)
  
  # remove data
  rm(dq_all)
  rm(dt_dq)
  rm(dq_vars)
  
}

gc()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# IMPORTANT SET NO CONTINUATION FLAG
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
# For some time-slices and platforms no SORs were entered.
# This flag blocks the continuation of the pipeline for these days.
if(nrow(out_dq) == 0){
  stop_pipeline_dead <- "TRUE"
} else {
  stop_pipeline_dead <- "FALSE"
}

if(nrow(out_dq) > 0){

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
  # Define Files for Further Processing
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pop_files <- out_dq[, file]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Export Data Quality File
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  print(paste0("DATA QUALITY: ", extr_plat, " ", extr_date, " - EXPORT AT ", Sys.time()))

  # Check for folder
  file_path <- paste0(out_dq_path, extr_date)

  if(!dir.exists(file_path)) {
    dir.create(paste0(out_dq_path, extr_date))
  }

  # Export
  fwrite(out_dq, file = paste0(out_dq_path, extr_date, "/", extr_plat,".csv"),
            row.names = FALSE)

  print(paste0("DATA QUALITY: ", extr_plat, " ", extr_date, " - EXPORT COMPLETE AT ", Sys.time()))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Clean
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  rm(out_dq)
}
}
