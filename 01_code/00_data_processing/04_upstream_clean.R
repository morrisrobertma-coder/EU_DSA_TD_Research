#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 04_upstream_clean
# Purpose of Script: Remove upstream files to save space.
# Input: Raw SOR Data.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SOR UPSTREAM CLEANING: ", extr_plat, " - ", extr_date))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Individual SOR Platform Files
for(path in map_platform[, output]){
  unlink(paste0(path, extr_date), recursive = TRUE)
}

# Global UnUnzipped Folders
unlink(paste0(zip_out, extr_date, "-", extr_plat), recursive = TRUE)

# Global Unzipped Folders
unlink(paste0(zip_mid_out, extr_date, "-", extr_plat), recursive = TRUE)

# Global Zipped Folders
if (remove_global_files == TRUE){
  unlink(paste0(zip_in, "sor-",extr_plat,"-", extr_date,"-full.zip"))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SOR UPSTREAM CLEANING: ", extr_plat, " - ", extr_date, " - COMPLETE "))
gc()
