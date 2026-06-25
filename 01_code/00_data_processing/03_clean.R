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
rel_files <- pop_files

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
dt_qual <- as.data.table(read_parquet(paste0(out_qual_path, extr_date, "/",
                                             extr_plat,"_qual_analysis.parquet")))

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
# Define Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(!(extr_plat %in% c(
  "facebook",
  "tiktok",
  "instagram",
  "snapchat"
))){
dt <- data.table()

# Define Files & Paths
pop_files_full <- file.path(paste0(map_platform[platform == extr_plat, output], extr_date),
                            pop_files)

dt <- rbindlist(lapply(pop_files_full, function(f) fread(f, drop = drop_cols)))

} else if(extr_plat %in% c(
  "facebook",
  "tiktok",
  "instagram",
  "snapchat"
)){
  dt <- copy(dt_samp)
  colnames_to_extract <- setdiff(colnames(dt), drop_cols)
  colnames_to_extract <- setdiff(colnames_to_extract, "file")
  dt <- dt[, ..colnames_to_extract]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~
## Clean Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
if(nrow(dt) > 0){
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Platform Name ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[map_platforms, p_name := i.abkurzung , on = .(platform_name)][
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
  dt[, territorial_scope := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Created At ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, date := as.Date(created_at)][, created_at := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Content Date ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, content_d := format(as.Date(content_date), "%Y-%m-%d")][
    , content_date := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Application Date ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, app_d := format(as.Date(application_date), "%Y-%m-%d")][
    , application_date := NULL]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Automated Detection ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[map_auto, aut_det := i.abkurzung , on = .(automated_detection = des)][
    , automated_detection := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Automated Decision ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[map_auto_des, aut_dec := i.abkurzung, on = .(automated_decision = des)][
    , automated_decision := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Content Type ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ### Clean
  dt[, cont_type := content_type]
  dt[, cont_type := sub("^\\[", "", cont_type)]
  dt[, cont_type := sub("\\]$", "", cont_type)]
  dt[, cont_type := gsub('"', "", cont_type, fixed = TRUE)]
  
  if (extr_plat %in% c("youtube","tiktok")) {
    
    map_vec <- setNames(
      map_cont$abkurzung,
      map_cont$des
    )
    
    dt[, cont_type :=
         sapply(
           strsplit(cont_type, ",", fixed = TRUE),
           function(x) {
             paste(map_vec[x], collapse = "_and_")
           }
         )]
    
  } else {
  
  dt[map_cont, 
     cont_type := i.abkurzung,
     on = .(cont_type = des)]
    
  }
  
  dt[, content_type := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Content Language ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, cont_lang := content_language]
  dt[, cont_lang := sub("^\\[", "", cont_lang)]
  dt[, cont_lang := sub("\\]$", "", cont_lang)]
  dt[, cont_lang := gsub('"', "", cont_lang, fixed = TRUE)]
  
  dt[, cont_lang := tolower(cont_lang)][
    , content_language := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Source Type ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[map_source, source := i.abkurzung, on = .(source_type = des)][
    , source_type := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Category ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[map_cat, cat := i.abkurzung, on = .(category = des)][
    , category := NULL]
  
  dt[, cat := ifelse(is.na(cat), 'historic_or_empty', cat)]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Category Specification ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, category_specification := category_specification]
  dt[, category_specification := sub("^\\[", "", category_specification)]
  dt[, category_specification := sub("\\]$", "", category_specification)]
  dt[, category_specification := gsub('"', "", category_specification, fixed = TRUE)]
  
  dt[map_cat_spec, cat_spec := i.abkurzung, on = .(category_specification = des)][
    , category_specification := NULL]
  
  dt[, cat_spec := ifelse(is.na(cat_spec), 'historic_or_empty', cat_spec)]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Category Specification Other ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, cat_spec_other := tolower(category_specification_other)]
  
  dt_qual_cut <- dt_qual[
    q == "category_specification_other",
    .(statement, q_id)
  ]
  
  dt[
    dt_qual_cut,
    cat_spec_other := i.q_id,
    on = .(cat_spec_other = statement)
  ]
  
  dt [, category_specification_other := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Ground ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[map_des_ground, des_ground := i.abkurzung, on = .(decision_ground = des)][
    , decision_ground := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Facts ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, des_fact := tolower(decision_facts)]
  
  dt_qual_cut <- dt_qual[
    q == "decision_facts",
    .(statement, q_id)
  ]
  
  setkey(dt_qual_cut, statement)
  
  dt[
    dt_qual_cut,
    des_fact := i.q_id,
    on = .(des_fact = statement)
  ]
  
  dt [, decision_facts := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Illegal Content Legal Ground ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, illegal_c_ground := tolower(illegal_content_legal_ground)]
  
  dt_qual_cut <- dt_qual[
    q == "illegal_content_legal_ground",
    .(statement, q_id)
  ]
  
  dt[
    dt_qual_cut,
    illegal_c_ground := i.q_id,
    on = .(illegal_c_ground = statement)
  ]
  
  dt [, illegal_content_legal_ground := NULL]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Illegal Content Explanation ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, illegal_c_ex := tolower(illegal_content_explanation)]
  
  dt_qual_cut <- dt_qual[
    q == "illegal_content_explanation",
    .(statement, q_id)
  ]
  
  dt[
    dt_qual_cut,
    illegal_c_ex := i.q_id,
    on = .(illegal_c_ex = statement)
  ]
  
  dt [, illegal_content_explanation := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Incompatible Content Ground ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, incomp_c_ground := tolower(incompatible_content_ground)]
  
  dt_qual_cut <- dt_qual[
    q == "incompatible_content_ground",
    .(statement, q_id)
  ]
  
  dt[
    dt_qual_cut,
    incomp_c_ground := i.q_id,
    on = .(incomp_c_ground = statement)
  ]
  
  dt [, incompatible_content_ground := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Incompatible Content Explanation ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, incomp_c_ex := tolower(incompatible_content_explanation)]
  
  dt_qual_cut <- dt_qual[
    q == "incompatible_content_explanation",
    .(statement, q_id)
  ]
  
  dt[
    dt_qual_cut,
    incomp_c_ex := i.q_id,
    on = .(incomp_c_ex = statement)
  ]
  
  dt [, incompatible_content_explanation := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Incompatible Content Illegal ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, incomp_c_illegal:= tolower(incompatible_content_illegal)]
  
  dt_qual_cut <- dt_qual[
    q == "incompatible_content_illegal",
    .(statement, q_id)
  ]
  
  dt[
    dt_qual_cut,
    incomp_c_illegal := i.q_id,
    on = .(incomp_c_illegal = statement)
  ]
  
  dt [, incompatible_content_illegal := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Visibility ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ### Clean
  dt[, des_vis := decision_visibility]
  dt[, des_vis := sub("^\\[", "", des_vis)]
  dt[, des_vis := sub("\\]$", "", des_vis)]
  dt[, des_vis := gsub('"', "", des_vis, fixed = TRUE)]
  
  # empty cell format
  dt[, des_vis := ifelse(des_vis == '', NA, des_vis)]
  
  if (extr_plat == "tiktok"){
    
    map_vec <- setNames(
      map_des_vis$abkurzung,
      map_des_vis$des)
    
    dt[, des_vis :=
         sapply(
           strsplit(des_vis, ",", fixed = TRUE),
           function(x) paste(map_vec[x], collapse = "_and_"))]
  
  } else {
    dt[map_des_vis, des_vis := i.abkurzung, on = .(des_vis = des)]
  }
  
  dt[, decision_visibility := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Visibility Other ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, des_vis_other := tolower(decision_visibility_other)]
  
  dt_qual_cut <- dt_qual[
    q == "decision_visibility_other",
    .(statement, q_id)
  ]
  
  dt[
    dt_qual_cut,
    des_vis_other := i.q_id,
    on = .(des_vis_other = statement)
  ]
  
  dt[, decision_visibility_other := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## End Date Visibility Restriction ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, des_vis_end_date := format(as.Date(end_date_visibility_restriction), "%Y-%m-%d")][
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
  dt[, des_mon := ifelse(des_mon == '', NA, des_mon)]
  
  dt[map_des_mon, des_mon := i.abkurzung, on = .(des_mon = des)][
    , decision_monetary := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Monetary Other ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, des_mon_other := tolower(decision_monetary_other)][
    , decision_monetary_other := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## End Date Monetary Restriction ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, des_mon_end_date := format(as.Date(end_date_monetary_restriction), "%Y-%m-%d")][
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
  dt[, des_prov := ifelse(des_prov == '', NA, des_prov)]
  
  dt[map_des_prov, des_prov := i.abkurzung, on = .(des_prov = des)][
    , decision_provision := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## End Date Service Restriction ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, des_prov_end_date := format(as.Date(end_date_service_restriction), "%Y-%m-%d")][
    , end_date_service_restriction := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## Decision Account ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, decision_account := ifelse(decision_account == '', NA, decision_account)]
  
  dt[map_des_acc, des_acc := i.abkurzung, on = .(decision_account = des)][
    , decision_account := NULL]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  ## End Date Account Restriction ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  dt[, des_acc_end_date := format(as.Date(end_date_account_restriction), "%Y-%m-%d")][
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
  write_parquet(dt, paste0(out_clean_path, extr_date, "-", extr_plat, "/", extr_plat, ".parquet"))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Clean ----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  rm(dt)
  gc()
  
}
print(paste0("SOR CLEANING: ", extr_plat, " ", extr_date, " - END AT: ", Sys.time()))

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
write_parquet(out_dq_clean, paste0(out_dq_path, extr_date, "/", extr_plat,"_clean.parquet"))

print(paste0("CLEANING DATA QUALITY: ", extr_plat, " ", extr_date, " - EXPORT COMPLETE AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Remove local files
rm(dt_qual, dt_qual_cut, out_dq_clean)

# Remove Staged Sample
if (exists("dt_samp")) rm(dt_samp)
gc()
