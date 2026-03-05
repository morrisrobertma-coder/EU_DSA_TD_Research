#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 03_clean
# Purpose of Script: Clean SOR Data and store for further analysis
# Input: Raw SOR Data.
# Output: Clean SOR Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SOR CLEANING: ", plat, " ", date_out))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rel_files <- list.files(paste0(map_platform[platform == plat, output], date_out))

# Define Output
out_data <- data.table()

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import Qualitative Analysis Results ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dt_qual <- as.data.table(fread(file = paste0(out_qual_path, date_out, "/qual_analysis.csv")))

# filter by platform
# cut to statement and q_id
dt_qual <- dt_qual[platform == plat][
  ,.(statement, q, q_id)]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# loop through each file
for(subfile in rel_files){
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Output Progress ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  print(paste0("SOR CLEANING: ", plat, " ", date_out, ". File = ", subfile))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Import Data ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- fread(file = paste0(paste0(map_platform[platform == plat, output], date_out, "/", subfile)))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Clean ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  # Remove V1
  dt <- dt[, V1 := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Drop Unnecessary Columns ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  drop_cols <- c("uuid", "account_type", "decision_ground_reference_url",
                 "category_addition",
                 "content_type_other",
                 "content_id_ean","source_identity",
                 "platform_uid")
  
  dt <- dt[, (drop_cols) := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Platform Name ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[map_platforms, p_name := i.abkurzung , on = .(platform_name)][
    , platform_name := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Territorial Scope ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  # clean
  dt$terr <- sapply(dt$territorial_scope, function(x) {
    x <- sub("^\\[", "", x)
    x <- sub("\\]$", "", x)
    gsub('"', "", x)
  })
  
  dt[, terr_eu_inc_eea := as.integer(terr == eu_inc_eea)]
  dt[, terr_eu_ex_eea := as.integer(terr == eu_ex_eea)]
  
  # identify all countries
  all_countries <- unique(unlist(strsplit(dt$terr, ",")))
  all_countries <- setdiff(all_countries, c("", NA))
  
  for (ctry in all_countries) {
    
    col_name <- paste0("terr_", tolower(ctry))
    
    dt[, (col_name) :=
              as.integer(
              terr != eu_inc_eea &
              terr != eu_ex_eea &
              grepl(paste0("(^|,)", ctry, "(,|$)"), terr))]
  }
  
  dt <- dt[, territorial_scope := NULL]
  dt <- dt[, terr := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Created At ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, date := as.Date(created_at)][
    , time := format(created_at, "%H:%M:%S")][, created_at := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Content Date ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, content_d := format(as.Date(content_date), "%Y-%m-%d")][
    , content_date := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Application Date ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, app_d := format(as.Date(application_date), "%Y-%m-%d")][
    , application_date := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Automated Detection ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[map_auto, aut_det := i.abkurzung , on = .(automated_detection = des)][
    , automated_detection := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Automated Decision ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[map_auto_des, aut_dec := i.abkurzung, on = .(automated_decision = des)][
    , automated_decision := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Content Type ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ### Clean
  dt$cont_type <- sapply(dt$content_type, function(x) {
    x <- sub("^\\[", "", x)
    x <- sub("\\]$", "", x)
    gsub('"', "", x)
  })
  
  dt <- dt[map_cont, cont_type := i.abkurzung, on = .(cont_type = des)][
    , content_type := NULL]
  
  # adjust for multiple content types
  # lose some granularity in this adjustment but not often used
  dt <- dt[, cont_type := ifelse(!(cont_type %in% map_cont[, abkurzung]),
                                 "m", cont_type)]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Content Language ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt$cont_lang <- sapply(dt$content_language, function(x) {
    x <- sub("^\\[", "", x)
    x <- sub("\\]$", "", x)
    gsub('"', "", x)
  })
  
  dt <- dt[, cont_lang := tolower(cont_lang)][
    , content_language := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Source Type ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[map_source, source := i.abkurzung, on = .(source_type = des)][
    , source_type := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Category ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[map_cat, cat := i.abkurzung, on = .(category = des)][
    , category := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Category Specification ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[map_cat_spec, cat_spec := i.abkurzung, on = .(category_specification = des)][
    , category_specification := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Category Specification Other ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, cat_spec_other := tolower(category_specification_other)]
  
  # find NA frequency
  if (nrow(dt[!(is.na(cat_spec_other))]) != 0){
    
    # cut-down qualitative table
    dt_qual_cut <- dt_qual[q == 'category_specification_other'][
      ,.(statement, q_id)]
    
    # merge qualitative statement id
    dt <- merge(dt, dt_qual_cut, by.x = 'cat_spec_other',
                by.y = 'statement',
                all.x = T)
    
    dt <- dt[, cat_spec_other := q_id][, q_id := NULL]
    
  } 
  
  dt <- dt [, category_specification_other := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Ground ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[map_des_ground, des_ground := i.abkurzung, on = .(decision_ground = des)][
    , decision_ground := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Facts ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, des_fact := tolower(decision_facts)]
  
  # find NA frequency
  if (nrow(dt[!(is.na(des_fact))]) != 0){
    
    # cut-down qualitative table
    dt_qual_cut <- dt_qual[q == 'decision_facts'][
      ,.(statement, q_id)]
    
    # merge qualitative statement id
    dt <- merge(dt, dt_qual_cut, by.x = 'decision_facts',
                by.y = 'statement',
                all.x = T)
    
    dt <- dt[, des_fact := q_id][, q_id := NULL]
    
  } 
  
  dt <- dt [, decision_facts := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Illegal Content Legal Ground ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, illegal_c_ground := tolower(illegal_content_legal_ground)]
  
  # find NA frequency
  if (nrow(dt[!(is.na(illegal_c_ground))]) != 0){
    
    # cut-down qualitative table
    dt_qual_cut <- dt_qual[q == 'illegal_content_legal_ground'][
      ,.(statement, q_id)]
    
    # merge qualitative statement id
    dt <- merge(dt, dt_qual_cut, by.x = 'illegal_c_ground',
                by.y = 'statement',
                all.x = T)
    
    dt <- dt[, illegal_c_ground := q_id][, q_id := NULL]
    
  } 
  
  dt <- dt [, illegal_content_legal_ground := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Illegal Content Explanation ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, illegal_c_ex := tolower(illegal_content_explanation)]
  
  # find NA frequency
  if (nrow(dt[!(is.na(illegal_c_ex))]) != 0){
    
    # cut-down qualitative table
    dt_qual_cut <- dt_qual[q == 'illegal_content_explanation'][
      ,.(statement, q_id)]
    
    # merge qualitative statement id
    dt <- merge(dt, dt_qual_cut, by.x = 'illegal_c_ex',
                by.y = 'statement',
                all.x = T)
    
    dt <- dt[, illegal_c_ex := q_id][, q_id := NULL]
    
  } 
  
  dt <- dt [, illegal_content_explanation := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Incompatible Content Ground ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, incomp_c_ground := tolower(incompatible_content_ground)]
  
  # find NA frequency
  if (nrow(dt[!(is.na(incomp_c_ground))]) != 0){
    
    # cut-down qualitative table
    dt_qual_cut <- dt_qual[q == 'incompatible_content_ground'][
      ,.(statement, q_id)]
    
    # merge qualitative statement id
    dt <- merge(dt, dt_qual_cut, by.x = 'incomp_c_ground',
                by.y = 'statement',
                all.x = T)
    
    dt <- dt[, incomp_c_ground := q_id][, q_id := NULL]
    
  } 
  
  dt <- dt [, incompatible_content_ground := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Incompatible Content Explanation ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, incomp_c_ex := tolower(incompatible_content_explanation)]
  
  # find NA frequency
  if (nrow(dt[!(is.na(incomp_c_ex))]) != 0){
    
    # cut-down qualitative table
    dt_qual_cut <- dt_qual[q == 'incompatible_content_explanation'][
      ,.(statement, q_id)]
    
    # merge qualitative statement id
    dt <- merge(dt, dt_qual_cut, by.x = 'incomp_c_ex',
                by.y = 'statement',
                all.x = T)
    
    dt <- dt[, incomp_c_ex := q_id][, q_id := NULL]
    
  } 
  
  dt <- dt [, incompatible_content_explanation := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Incompatible Content Illegal ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, incomp_c_illegal:= tolower(incompatible_content_illegal)][
    , incompatible_content_illegal := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Visibility ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ### Clean
  dt$des_vis <- sapply(dt$decision_visibility, function(x) {
    x <- sub("^\\[", "", x)
    x <- sub("\\]$", "", x)
    gsub('"', "", x)
  })
  
  dt <- dt[map_des_vis, des_vis := i.abkurzung, on = .(des_vis = des)][
    , decision_visibility := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Visibility Other ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, des_vis_other := tolower(decision_visibility_other)][
    , decision_visibility_other := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## End Date Visibility Restriction ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, des_vis_end_date := format(as.Date(end_date_visibility_restriction), "%Y-%m-%d")][
    , end_date_visibility_restriction := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Monetary ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ### Clean
  dt$des_mon <- sapply(dt$decision_monetary, function(x) {
    x <- sub("^\\[", "", x)
    x <- sub("\\]$", "", x)
    gsub('"', "", x)
  })
  
  dt <- dt[map_des_mon, des_mon := i.abkurzung, on = .(des_mon = des)][
    , decision_monetary := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Monetary Other ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, des_mon_other := tolower(decision_monetary_other)][
    , decision_monetary_other := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## End Date Monetary Restriction ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, des_mon_end_date := format(as.Date(end_date_monetary_restriction), "%Y-%m-%d")][
    , end_date_monetary_restriction := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Provision ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ### Clean
  dt$des_prov <- sapply(dt$decision_provision, function(x) {
    x <- sub("^\\[", "", x)
    x <- sub("\\]$", "", x)
    gsub('"', "", x)
  })
  
  dt <- dt[map_des_prov, des_prov := i.abkurzung, on = .(des_prov = des)][
    , decision_provision := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## End Date Service Restriction ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, des_prov_end_date := format(as.Date(end_date_service_restriction), "%Y-%m-%d")][
    , end_date_service_restriction := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Account ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[map_des_acc, des_acc := i.abkurzung, on = .(decision_account = des)][
    , decision_account := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## End Date Account Restriction ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[, des_acc_end_date := format(as.Date(end_date_account_restriction), "%Y-%m-%d")][
    , end_date_account_restriction := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Order Data ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # set column order as defined in 'xx_config.R'
  setcolorder(dt, neworder = cols_order)
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Bind Cleaned Data ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  out_data <- rbind(out_data,
                    dt,
                    fill = TRUE)
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Clean Environment ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  gc()
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Output Progress ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  print(paste0("SOR CLEANING: ", plat, " ", date_out, ". File = ", subfile, " FINISHED"))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Remove Unwanted Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(dt, dt_qual, dt_qual_cut)
gc()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Upload Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SOR CLEANING: ", plat, " ", date_out, " - EXPORT"))

# Check for folder
file_path <- paste0(out_clean_path, date_out)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_clean_path, date_out))
}

# Export as Parquet File
write_parquet(out_data, paste0(out_clean_path, date_out, "/", plat,".parquet"))

print(paste0("SOR CLEANING: ", plat, " ", date_out, " - EXPORT COMPLETE"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(out_data)
gc()
