#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 02_facebook
# Purpose of Script: Import Daily Facebook SOR CSVs
# Input: Individual Platform CSVs in '03_sor_platforms/date' folder.
# Output: 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initialization ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# In/Out Path
path_in <- paste0(inp, "03_sor_platforms/")
  
# Platform Input
in_facebook <- c("01_facebook/")

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Data Quality ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dq <- data.table(date = date_out)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
facebook_files <- list.files(paste0(path_in, in_facebook, date_out))

# define data table
dt_facebook <- data.table()

for(file_face in facebook_files){
  
  # import file
  dt <- fread(file = paste0(path_in, in_facebook, date_out, "/", file_face))
  
  # bind to full data table
  dt_facebook <- rbind(dt_facebook,
                       dt)
}

# remove dt_facebook
dt <- copy(dt_facebook)
rm(dt_facebook)
gc()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean Data & Data Quality ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Remove V1
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dt <- dt[, V1 := NULL]

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Row Count
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dt_rows <- nrow(dt)

# dq
dq_rows <- as.data.table(tibble::tribble(
  ~number_of_rows,
  as.character(dt_rows)))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Reported Date/Time
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dt <- dt[, date := as.Date(created_at)][
  , time := format(created_at, "%H:%M:%S")][, created_at := NULL]

dq_dates <- as.data.table(tibble::tribble(
  ~unique_dates,
   unique(dt$date)))

dq_times <- as.data.table(tibble::tribble(
  ~earliest_time, ~latest_time, ~no_unique_timestamps,
  min(dt$time),
  max(dt$time),
  length(unique(dt$time))))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Content Date/Time
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dq_content_date <- as.data.table(tibble::tribble(
  ~min_content_date, ~max_content_date,
  min(dt$content_date), max(dt$content_date)))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Application Date/Time
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dq_application_date <- as.data.table(tibble::tribble(
  ~min_application_date, ~max_application_date,
  min(dt$application_date), max(dt$application_date)))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Territory
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# clean
dt$terr <- sapply(dt$territorial_scope, function(x) {
  x <- sub("^\\[", "", x)
  x <- sub("\\]$", "", x)
  gsub('"', "", x)
})

dt <- dt[, terr := ifelse(terr == eu_inc_eea, "all",
                   ifelse(terr == eu_ex_eea, "eu",
                          tolower(terr)))]

# dq
dq_terr <- as.data.table(tibble::tribble(
  ~terr_all, ~terr_eu, ~terr_other,
  nrow(dt[terr == 'all']), nrow(dt[terr == 'eu']),
  nrow(dt[!(terr %in% c('all','eu'))])))
  
# drop
dt <- dt[, territorial_scope := NULL]

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# UUID
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# check unique UUIDs
dq_uuids <- as.data.table(tibble::tribble(
  ~no_unique_uuids,
  length(unique(dt$uuid))))

if(dq_rows$number_of_rows != dq_uuids$no_unique_uuids){
  print("Number of Unique UUIDs does not match number of rows")
}

# drop uuids
dt <- dt[, uuid := NULL]

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Platform UUID
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dq_platform_uuid <- as.data.table(tibble::tribble(
  ~no_unique_platform_uuids,
  length(unique(dt$platform_uid))))

if(dq_rows$number_of_rows != dq_platform_uuid$no_unique_platform_uuids){
  print("Number of Platform Unique UUIDs does not match number of rows")
}

# drop platform uuids
dt <- dt[, platform_uid := NULL]

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Platform Name
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dt <- dt[, p_name := ifelse(platform_name == "Facebook","F", "Error")]

# dq
dq_plat_name = as.data.table(tibble::tribble(
  ~unique_plat_names, ~no_unique_plat_names,
  unique(dt$platform_name), length(unique(dt$platform_name))))

# drop platform name
dt <- dt[, platform_name := NULL]

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Automated Detection
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dt <- dt[, automated_det := ifelse(automated_detection == "Yes", 1, 0)]

# dq
dq_detection <- as.data.table(tibble::tribble(
  ~no_automated_det, ~no_not_automated_det,
  nrow(dt[automated_det == 1]), nrow(dt[automated_det == 0])))

# check
if(sum(dq_detection$no_automated_det + dq_detection$no_not_automated_det) != dq_rows$number){
  print("Check sum of Automated Detection")
}

# drop
dt <- dt[, automated_detection := NULL]

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Automated Decision
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# dq
dq_decision <- as.data.table(tibble::tribble(
  ~no_dec_fully, ~ no_dec_partial, ~no_dec_not,
  nrow(dt[automated_decision == "AUTOMATED_DECISION_FULLY"]),
  nrow(dt[automated_decision == "AUTOMATED_DECISION_PARTIALLY"]),
  nrow(dt[automated_decision == "AUTOMATED_DECISION_NOT_AUTOMATED"])))

dt <- dt[, automated_des := ifelse(automated_decision == "AUTOMATED_DECISION_FULLY", "F",
                            ifelse(automated_decision == "AUTOMATED_DECISION_PARTIALLY", "P",
                            "N"))]

# drop
dt <- dt[, automated_decision := NULL]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Process & Check Potentially Empty Columns
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Account Type
#~~~~~~~~~~~~~~~~~~~~~~~~~~
dq_account_type <- as.data.table(tibble::tribble(
  ~no_account_type_empty, 
  nrow(dt[is.na(account_type)])))

# check
if(dq_rows$number_of_rows != dq_account_type$no_account_type_empty){
  print("Account Type is populated - check")
}

# drop
dt <- dt[, account_type := NULL]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Drop Unnecessary Columns
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Reorganize Data 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
setcolorder(dt, c("p_name", "terr","date","time","content_date", "application_date",
                  "automated_det", "automated_des"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Collect Data Quality Results
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# list data quality variables
all_vars <- ls(envir= .GlobalEnv)
dq_vars <- all_vars[grepl("^dq", all_vars)]

# cbind all dq outputs
dq_all <- data.table()

for (dqi in dq_vars){
  dq_table <- get(dqi)
  dq_all <- cbind(dq_all,
                  dq_table)
}
