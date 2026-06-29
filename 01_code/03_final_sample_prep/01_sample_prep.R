#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01_sample_prep.R
# Purpose of Script: Produce Final Samples from Pipeline Run
# Input: All Pipeline Outputs
# Output: Samples for RQs.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SAMPLE PREPARATION: - START AT ", Sys.time()))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DQ
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#### Import
### Data Quality - File Level
dt_dq <- as.data.table(read_parquet(paste0(out_collection, date_to_extract, "/dq.parquet")))
dt_dq <- dt_dq[, version := paste0(out_version)]

### Data Quality - Cleaning
dt_dq_clean <- as.data.table(read_parquet(paste0(out_collection, date_to_extract, "/dq_clean.parquet"))) 
dt_dq_clean[is.na(dt_dq_clean)] <- 0
dt_dq_clean <- dt_dq_clean[, version := paste0(out_version)]

#### Export
write_parquet(dt_dq, sink = paste0(out_final_sample, "/dq_final.parquet"))
write_parquet(dt_dq_clean, sink = paste0(out_final_sample, "/dq_cleaning_final.parquet"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Qual
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Import
dt_qual <- as.data.table(read_parquet(paste0(out_collection, date_to_extract, "/qual.parquet")))
dt_qual <- dt_qual[, version := paste0(out_version)]

#### Export
write_parquet(dt_qual, sink = paste0(out_final_sample, "/qual_final.parquet"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RQ1
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Import
dt_rq1 <- as.data.table(read_parquet(paste0(out_collection, date_to_extract, "/rq1.parquet")))

# Find Min & Max Date
min_date <- min(dt_rq1$date)
max_date <- max(dt_rq1$date)

# Find Unique Platforms
unique_platforms <- unique(dt_rq1$platform)

# Form Complete Out Table
### Motivation: For some platforms and day combinations 0 SORs are entered
out_rq1 <- CJ(platform = unique_platforms,
              date = seq(as.Date(min_date),
                         as.Date(max_date),
                         by = "day"))

# Merge RQ1 Data
out_rq1_all <- merge(out_rq1, 
                     dt_rq1,
                     by.x = c("platform","date"),
                     by.y = c("platform","date"),
                     all.x = T)

out_rq1_all[is.na(out_rq1_all)] <- 0
out_rq1_all <- out_rq1_all[order(platform, date)]

### Export
write_parquet(out_rq1_all, sink = paste0(out_final_sample, "/rq1_final.parquet"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RQ2
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Import
dt_rq2 <- as.data.table(read_parquet(paste0(out_collection, date_to_extract, "/rq2.parquet")))

# Find Min & Max Date
min_date <- min(dt_rq2$date)
max_date <- max(dt_rq2$date)

# Find Unique Platforms
unique_platforms <- unique(dt_rq2$platform)

# Form Complete Out Table
### Motivation: For some platforms and day combinations 0 SORs are entered
out_rq2 <- CJ(platform = unique_platforms,
              date = seq(as.Date(min_date),
                         as.Date(max_date),
                         by = "day"),
              syn_flag = c(0,1))

# Merge RQ2 Data
out_rq2_all <- merge(out_rq2, 
                     dt_rq2,
                     by.x = c("platform","date","syn_flag"),
                     by.y = c("platform","date","syn_flag"),
                     all.x = T)

out_rq2_all[is.na(out_rq2_all)] <- 0
out_rq2_all <- out_rq2_all[order(platform, date)]

### Export
write_parquet(out_rq2_all, sink = paste0(out_final_sample, "/rq2_final.parquet"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RQ3 - Quant
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Import
dt_rq3 <- as.data.table(read_parquet(paste0(out_collection, date_to_extract, "/rq3_quant.parquet")))

# Find Min & Max Date
min_date <- min(dt_rq3$date)
max_date <- max(dt_rq3$date)

# Find Unique Platforms
unique_platforms <- unique(dt_rq3$platform)

# Form Complete Out Table
### Motivation: For some platforms and day combinations 0 SORs are entered
out_rq3 <- CJ(platform = unique_platforms,
              date = seq(as.Date(min_date),
                         as.Date(max_date),
                         by = "day"),
              syn_flag = c(0,1),
              illegal_flag = c(0,1))

# Merge RQ2 Data
out_rq3_all <- merge(out_rq3, 
                     dt_rq3,
                     by.x = c("platform","date","syn_flag","illegal_flag"),
                     by.y = c("platform","date","syn_flag","illegal_flag"),
                     all.x = T)

out_rq3_all[is.na(out_rq3_all)] <- 0
out_rq3_all <- out_rq3_all[order(platform, date)]

### Export
write_parquet(out_rq3_all, sink = paste0(out_final_sample, "/rq3_quant_final.parquet"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RQ3 - Qual
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Import
dt_rq3_qual <- as.data.table(read_parquet(paste0(out_collection, date_to_extract, "/rq3_qual.parquet")))

### Export
write_parquet(dt_rq3_qual, sink = paste0(out_final_sample, "/rq3_qual_final.parquet"))

print(paste0("SAMPLE PREPARATION: - END AT ", Sys.time()))