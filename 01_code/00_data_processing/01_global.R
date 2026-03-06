#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01_global
# Purpose of Script: Extract, import global SOR data, cutting down to relevant
#                    companies.
# Input: Daily Global Files in '00_sor_global_zipped' folder.
# Output: Individual Platform CSVs in '03_sor_platforms' folder.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("GLOBAL DATA PROCESSING: ", date_out, " - START AT ", Sys.time()))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initialization
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create Folders
for(out_files in c(zip_mid_out, zip_out,
                   out_facebook, out_youtube, out_whatsapp,
                   out_instagram, out_tiktok, out_snap,
                   out_x)){
dir.create(paste0(out_files,"/",date_out))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Data Processing
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Unzip Global File
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# define global file
global_file_process <- paste0("sor-global-",date_out,"-full.zip")

# unzip file
unzip(paste0(zip_in, global_file_process), exdir = paste0(zip_mid_out, date_out))

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Zips in Zips
#~~~~~~~~~~~~~~~~~~~~~~~~~~
zip_inside_zip <- list.files(paste0(zip_mid_out, date_out))

for(file in zip_inside_zip){
  print(paste0("GLOBAL DATA PROCESSING: ", date_out, " : SUBFILE ", file," - START AT ", Sys.time()))
  
  # unzip file 
  unzip(paste0(zip_mid_out, date_out,"/", file), exdir = paste0(zip_out, date_out))
  
  # remove zipped file
  file.remove(paste0(zip_mid_out, date_out,"/", file))
  
  # list unzipped files
  files_csv <- list.files(paste0(zip_out, date_out))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Import CSVs
  #~~~~~~~~~~~~~~~~~~~~~~~~~~
  for(file_csv in files_csv){
    print(paste0("GLOBAL DATA PROCESSING: ", date_out, " : SUBFILE CSV ", file_csv ," - START AT ", Sys.time()))
    
    # import data
    dt <- fread(paste0(zip_out, date_out,"/", file_csv))
    
    # filter for companies, save output in company folder
    for(platform in 1:nrow(map_platform)){
      
      # platform to extract
      extract_plat <- map_platform[platform, platform_name]
      
      # output folder
      out_plat <- map_platform[platform, output]
      
      # extract data
      dt_cut <- dt[platform_name == paste0(extract_plat)]
      
      # write csv
      if(nrow(dt_cut)> 0){
        write.csv(dt_cut, file=paste0(out_plat, paste0(date_out,"/",file_csv)))
      }
      
      # remove data
      rm(dt_cut)
    }
    
    # remove data table
    rm(dt)
    
    # remove file
    file.remove(paste0(zip_out, date_out,"/", file_csv))
    
    print(paste0("GLOBAL DATA PROCESSING: ", date_out, " : SUBFILE CSV ", file_csv ," - END AT ", Sys.time()))
    
  }
  
  print(paste0("GLOBAL DATA PROCESSING: ", date_out, " : SUBFILE ", file," - END AT ", Sys.time()))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clean Up
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gc()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(paste0("GLOBAL DATA PROCESSING: ", date_out, " - END"))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
