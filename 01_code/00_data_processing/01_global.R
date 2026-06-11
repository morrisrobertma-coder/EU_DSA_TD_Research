#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01_global
# Purpose of Script: Extract, import global SOR data, cutting down to relevant
#                    companies.
# Input: Daily Global Files in '00_sor_global_zipped' folder.
# Output: Individual Platform CSVs in '03_sor_platforms' folder.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0(" DATA PROCESSING: ", extr_plat," ", extr_date, " - START AT ", Sys.time()))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Data Processing ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Unzip Global File ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# define global file
global_file_process <- paste0(i)

# unzip file
unzip(paste0(zip_in, global_file_process), exdir = paste0(zip_mid_out, extr_date, "-", extr_plat))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Zips in Zips ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
zip_inside_zip <- list.files(paste0(zip_mid_out, extr_date, "-", extr_plat))

for(file in zip_inside_zip){
  print(paste0("UNZIPPING: ", extr_plat," ", extr_date, " : SUBFILE ", file," START AT -", Sys.time()))
  
  # unzip file 
  unzip(paste0(zip_mid_out, extr_date, "-", extr_plat, "/", file), exdir = paste0(zip_out, extr_date, "-", extr_plat))
  
  # remove zipped file
  file.remove(paste0(zip_mid_out, extr_date,"-", extr_plat ,"/", file))
  
  # list unzipped files
  files_csv <- list.files(paste0(zip_out, extr_date, "-", extr_plat))
  
  print(paste0("UNZIPPING: ", extr_plat," ", extr_date, " : SUBFILE ", file," END AT -", Sys.time()))
}
  
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copy to Individual SOR Folder ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~
sor_files <- list.files(path=paste0(zip_out, extr_date, "-", extr_plat), full.names = TRUE)
    
invisible(file.rename(from = sor_files,
                      to = file.path(paste0(map_platform[platform == extr_plat, output],
                                            extr_date),
            basename(sor_files))))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean Up
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gc()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("DATA PROCESSING: ", extr_plat," ", extr_date, " - END ", Sys.time()))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
