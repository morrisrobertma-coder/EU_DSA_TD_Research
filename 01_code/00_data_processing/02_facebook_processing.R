#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 02_facebook_processing
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
  min(dt$content_date), max(dt$content_date)
))

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
  ~statement, ~number,
  "Automated Decision", nrow(dt[automated_det == 1]),
  "Not Automated Decision", nrow(dt[automated_det == 0])
))

# check
if(sum(dq_detection$number) != dq_rows$number){
  print("Check sum of Automated Detection")
}

# drop
dt <- dt[, automated_detection := NULL]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Reorganize Data 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
setcolorder(dt, c("date","time","p_name","content_date",
                  "automated_det"))

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
