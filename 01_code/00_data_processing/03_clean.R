#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 03_clean
# Purpose of Script: Clean SOR Data and store for further analysis
# Input: Raw SOR Data.
# Output: Clean SOR Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run per Platform/Date
#~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SOR CLEANING: ", extr_plat, " ", extr_date, " - START AT: ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rel_files <- list.files(paste0(map_platform[platform == extr_plat, output], extr_date))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Up Output File ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Check for folder
file_path <- paste0(out_clean_path, extr_date, "-", extr_plat)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_clean_path, extr_date, "-", extr_plat))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import Qualitative Analysis Results ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dt_qual <- as.data.table(fread(file = paste0(out_qual_path, extr_date, "/",
                                             extr_plat,"_qual_analysis.csv")))

# filter by platform
# cut to statement and q_id
dt_qual <- dt_qual[platform == extr_plat][
  ,.(statement, q, q_id)]

#~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# Assign Extraction Columns to Drop ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~ 
drop_cols <- c("uuid", "account_type", "decision_ground_reference_url",
               "category_addition",
               "content_type_other","source_identity",
               "platform_uid")

#~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# Data Quality ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~ 
out_dq_clean <- data.table()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# loop through each file
for(subfile in rel_files){
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Output Progress ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  print(paste0("SOR CLEANING: ", extr_plat, " ", extr_date, ". File = ", subfile, " - START AT: ", Sys.time()))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Import Data ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- fread(file = paste0(paste0(map_platform[platform == extr_plat, output], extr_date, "/", subfile)),
              drop = drop_cols)
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Clean ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  if(nrow(dt) > 0){
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Platform Name ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt <- dt[map_platforms, p_name := i.abkurzung , on = .(platform_name)][
    , platform_name := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Territorial Scope ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  # clean
  dt[, terr := territorial_scope]
  dt[, terr := sub("^\\[", "", terr)]
  dt[, terr := sub("\\]$", "", terr)]
  dt[, terr := gsub('"', "", terr, fixed = TRUE)]
  dt[, terr_eu_inc_eea := as.integer(terr == eu_inc_eea)]
  dt[, terr_eu_ex_eea := as.integer(terr == eu_ex_eea)]
  
  # identify all countries
  all_countries <- unique(unlist(strsplit(dt$terr, ",")))
  all_countries <- setdiff(all_countries, c("", NA))
  
  # find valid rows for country expansion
  valid_rows <- dt$terr != eu_inc_eea & dt$terr != eu_ex_eea
  
  for (ctry in all_countries) {
    col_name <- paste0("terr_", tolower(ctry))
    dt[, (col_name) := 0L]
    
    dt[valid_rows, (col_name) := as.integer(grepl(paste0("(^|,)",
                                                         ctry,
                                                         "(,|$)"),terr))]
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
  dt[, cont_type := content_type]
  dt[, cont_type := sub("^\\[", "", cont_type)]
  dt[, cont_type := sub("\\]$", "", cont_type)]
  dt[, cont_type := gsub('"', "", cont_type, fixed = TRUE)]
  
  dt <- dt[map_cont, cont_type := i.abkurzung, on = .(cont_type = des)][
    , content_type := NULL]
  
  # adjust for multiple content types
  # lose some granularity in this adjustment but not often used
  dt <- dt[, cont_type := ifelse(!(cont_type %in% map_cont[, abkurzung]),
                                 "m", cont_type)]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Content Language ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, cont_lang := content_language]
  dt[, cont_lang := sub("^\\[", "", cont_lang)]
  dt[, cont_lang := sub("\\]$", "", cont_lang)]
  dt[, cont_lang := gsub('"', "", cont_lang, fixed = TRUE)]
  
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
  
  dt <- dt[, cat := ifelse(is.na(cat), 'historic', cat)]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Category Specification ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, category_specification := category_specification]
  dt[, category_specification := sub("^\\[", "", category_specification)]
  dt[, category_specification := sub("\\]$", "", category_specification)]
  dt[, category_specification := gsub('"', "", category_specification, fixed = TRUE)]
  
  dt <- dt[map_cat_spec, cat_spec := i.abkurzung, on = .(category_specification = des)][
    , category_specification := NULL]
  
  dt <- dt[, cat_spec := ifelse(is.na(cat_spec), 'historic', cat_spec)]
  
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
    dt <- merge(dt, dt_qual_cut, by.x = 'des_fact',
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
  dt <- dt[, incomp_c_illegal:= tolower(incompatible_content_illegal)]
  
  # find NA frequency
  if (nrow(dt[!(is.na(incomp_c_illegal))]) != 0){
    
    # cut-down qualitative table
    dt_qual_cut <- dt_qual[q == 'incompatible_content_illegal'][
      ,.(statement, q_id)]
    
    # merge qualitative statement id
    dt <- merge(dt, dt_qual_cut, by.x = 'incomp_c_illegal',
                by.y = 'statement',
                all.x = T)
    
    dt <- dt[, incomp_c_illegal := q_id][, q_id := NULL]
    
  } 
  
  dt <- dt [, incompatible_content_illegal := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Visibility ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ### Clean
  dt[, des_vis := decision_visibility]
  dt[, des_vis := sub("^\\[", "", des_vis)]
  dt[, des_vis := sub("\\]$", "", des_vis)]
  dt[, des_vis := gsub('"', "", des_vis, fixed = TRUE)]
  
  # empty cell format
  dt <- dt[, des_vis := ifelse(des_vis == '', NA, des_vis)]
  
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
  dt[, des_mon := decision_monetary]
  dt[, des_mon := sub("^\\[", "", des_mon)]
  dt[, des_mon := sub("\\]$", "", des_mon)]
  dt[, des_mon := gsub('"', "", des_mon, fixed = TRUE)]
  
  # empty cell format
  dt <- dt[, des_mon := ifelse(des_mon == '', NA, des_mon)]
  
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
  dt[, des_prov := decision_provision]
  dt[, des_prov := sub("^\\[", "", des_prov)]
  dt[, des_prov := sub("\\]$", "", des_prov)]
  dt[, des_prov := gsub('"', "", des_prov, fixed = TRUE)]
  
  # empty cell format
  dt <- dt[, des_prov := ifelse(des_prov == '', NA, des_prov)]
  
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
  dt <- dt[, decision_account := ifelse(decision_account == '', NA, decision_account)]
  
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
  # Data Quality ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  dt_dq_clean <- dt[, lapply(.SD, function(x) sum(is.na(x)))]
  out_dq_clean <- rbind(out_dq_clean,
                        dt_dq_clean, fill=TRUE)
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Export ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  write_parquet(dt, paste0(out_clean_path, extr_date, "-", extr_plat, "/", subfile ,".parquet"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Clean ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  rm(dt)
  
  }
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Output Progress ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  print(paste0("SOR CLEANING: ", extr_plat, " ", extr_date, ". File = ", subfile, " - FINISHED AT: ", Sys.time()))

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Data Quality Export ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
out_dq_clean[is.na(out_dq_clean)] <- 0
out_dq_clean <- out_dq_clean[, lapply(.SD, sum)]
out_dq_clean <- out_dq_clean[,':='(platform = paste0(extr_plat),
                                   date = paste0(extr_date))]

setcolorder((out_dq_clean),c("platform","date"))

### Export
print(paste0("CLEANING DATA QUALITY: ", extr_plat, " ", extr_date, " - EXPORT AT ", Sys.time()))

# Check for folder
file_path <- paste0(out_dq_path, extr_date)

if(!dir.exists(file_path)) {
  dir.create(paste0(out_dq_path, extr_date))
}

# Export
fwrite(out_dq_clean, file = paste0(out_dq_path, extr_date, "/", extr_plat,"_clean.csv"),
       row.names = FALSE)

print(paste0("CLEANING DATA QUALITY: ", extr_plat, " ", extr_date, " - EXPORT COMPLETE AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rm(dt_qual, dt_qual_cut, out_dq_clean)
