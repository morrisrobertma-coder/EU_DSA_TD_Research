#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01a_stage
# Purpose of Script: Stage Samples for Platforms with Larger Data
# Input: Individual Platform CSVs in '03_sor_platforms' folder.
# Output: Individual Platform Staged Sample.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SAMPLE STAGING: ", extr_plat," ", extr_date, " - START AT ", Sys.time()))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
rel_files <- list.files(paste0(map_platform[platform == extr_plat, output], extr_date))

rel_files_full <- file.path(paste0(map_platform[platform == extr_plat, output], extr_date),
                            rel_files)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate Sample ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import Data
dt_samp <- rbindlist(lapply(rel_files_full, function(f) {
  dt <- fread(f)
  dt[, file := basename(f)]}))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean Up
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gc()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SAMPLE STAGING: ", extr_plat," ", extr_date, " - END ", Sys.time()))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
