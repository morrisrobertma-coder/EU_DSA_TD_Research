#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 04_upstream_clean
# Purpose of Script: Remove upstream files to save space.
# Input: Raw SOR Data.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SOR UPSTREAM CLEANING: ", date_out))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Identify Relevant Files ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Individual SOR Platform Files
for(path in map_platform[, output]){
  unlink(paste0(path, date_out), recursive = TRUE)
}

# Global UnUnzipped Folders
unlink(paste0(zip_out, date_out), recursive = TRUE)

# Global Unzipped Folders
unlink(paste0(zip_mid_out, date_out), recursive = TRUE)

# Global Zipped Folders
if (remove_global_files == TRUE){
  unlink(paste0(zip_in, "sor-global-", date_out,"-full.zip"))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean-Up ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("SOR UPSTREAM CLEANING: ", date_out, " - COMPLETE "))
gc()
