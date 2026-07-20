# European Union Digital Services Act Transparency Database (DSA-TD) Research - Master's Dissertation Project

# University of Sussex, UK - Human and Social Data Science MSc - 2025/2026

Author: Robert Michael Andrew Morris.

------------------------------------------------------------------------

### Repository Information

This repository provides the code for the analysis performed in research paper "Synthetic Media Content Moderation and the EU Digital Services Act: An Empirical Analysis of the Transparency Database (DSA-TD)".

### Research Project Folder Structure

The mapping tables below provides a navigation tool to operate the software used to conduct research, generating samples and results. Data processing occurs using a pipeline coded in R, whereas final research analysis
is coded in Python in the form of interactive Jupyter Notebooks.

```         
├── 00_data/
│   ├── 00_sor_global_zipped             <- Initial input folder for downloaded DSA-TD CSV file.
│   ├── 01_sor_global_unzipped           <- First unzipping layer for downloaded DSA-TD CSV file. 
│   ├── 02_sor_global_unzipped           <- Second unzipping layer for downloaded DSA-TD CSV file.
│   ├── 03_sor_platforms/
│   │     ├── 01_facebook                <- Folder containing raw CSV files for Facebook.
│   │     ├── 02_youtube                 <- Folder containing raw CSV files for YouTube.
│   │     ├── 03_whatsapp                <- Folder containing raw CSV files for WhatsApp.
│   │     ├── 04_instagram               <- Folder containing raw CSV files for Instagram.
│   │     ├── 05_tiktok                  <- Folder containing raw CSV files for TikTok.
│   │     ├── 06_snap                    <- Folder containing raw CSV files for Snapchat.
│   │     └── 07_x                       <- Folder containing raw CSV files for X.
│   │ 
│   ├── 04_dq/
│   │     ├── 2025-01-01                 <- Daily data quality results for all platforms - start of sample. 
│   │     ├── ....                       ...
│   │     └── 2026-05-31                 <- Daily data quality results for all platforms - end of sample. 
│   ├── 05_qual/
│   │     ├── 2025-01-01                 <- Daily qualitative results for all platforms - start of sample. 
│   │     ├── ....                       ...
│   │     └── 2026-05-31                 <- Daily qualitative results for all platforms - end of sample.
│   ├── 06_clean/
│   │     ├── 2025-01-01-'platform'      <- Daily cleaned SOR data per platform - start of sample.
│   │     ├── ....                       ...
│   │     └── 2026-05-31-'platform'      <- Daily cleaned SOR data per platform - end of sample.
│   ├── 07_rq1/
│   │     ├── 2025-01-01-'platform'      <- Daily results for RQ1 per platform - start of sample.
│   │     ├── ....                       ...
│   │     └── 2026-05-31-'platform'      <- Daily results for RQ1 per platform - end of sample.
│   ├── 08_rq2/
│   │     ├── 2025-01-01                 <- Daily results for RQ2 per platform - start of sample.
│   │     ├── ....                       ...
│   │     └── 2026-05-31                 <- Daily results for RQ2 per platform - end of sample.
│   ├── 09_rq3/
│   │     ├── 2025-01-01                 <- Daily results for RQ3 per platform - start of sample.
│   │     ├── ....                       ...
│   │     └── 2026-05-31                 <- Daily results for RQ3 per platform - end of sample.
│   ├── 10_collected/
│   │     └── 2026-05-31                 <- RQ1, RQ2, RQ3 Collected Aggregation Results.
│   └── 11_final/
│         └── 2026-05-31                 <- Data Quality, Qualitative Analysis, RQ1, RQ2 and RQ3 results for all platforms & dates. 
│
└── 01_code/
    ├── 00_data_processing/   
    │   ├── 01_global.R                  <- R file unzipping all nested global DSA-TD files.
    │   ├── 01a_stage.R                  <- R file staging sample, aggregating daily data.
    │   ├── 02_dq.R                      <- R file calculating data quality results per CSV file.
    │   ├── 03_clean.R                   <- R file cleaning SOR data.
    │   └── 04_upstream_clean.R          <- R file clearing unzipped file folders no longer needed.
    │
    ├── 01_qual/      
    │   └── 01_qual.R                    <- R file performing analysis of qualitative SOR data.
    │
    ├── 02_quant/   
    │   ├── 00_rq1.R                     <- R file aggregating data for RQ1.
    │   ├── 01_rq2.R                     <- R file aggregating data for RQ2.
    │   └── 02_rq3.R                     <- R file aggregating data for RQ3.
    │
    ├── 03_final_sample_prep/    
    │   ├── 00_collect.R                 <- R file collecting all RQ aggregation results.
    │   └── 01_sample_prep.R             <- R file generating final samples. 
    │    
    ├── 04_analysis/  
    │   ├── 00_monthly_users.ipynb                     <- Jupyter Notebook/Python file formatting sourced monthly average user data per platform.
    │   ├── 01a_data_quality_overview.ipynb            <- Jupyter Notebook/Python file performing analysis on data quality results.
    │   ├── 01b_data_quality_data_size.ipynb           <- Jupyter Notebook/Python file sourcing data size from EU-DSA-TD website.
    │   ├── 02a_rq1_qual_analysis.ipynb                <- Jupyter Notebook/Python file performing RQ1 analysis from qualitative data.
    │   ├── 02b_rq1_qual_visualisation.ipynb           <- Jupyter Notebook/Python file generating RQ1 visualisations from qualitative data.
    │   ├── 03_rq1_quant_analysis.ipynb                <- Jupyter Notebook/Python file performing RQ1 analysis from quantitative data.
    │   ├── 05_rq3_sample_creation.ipynb               <- Jupyter Notebook/Python file generating RQ3 regression sample.
    │   ├── 06_rq3_regression.ipynb                    <- Jupyter Notebook/Python file performing RQ3 regression analysis.   
    │   └── 07_rq3_simple_regression_application.ipynb <- Jupyter Notebook/Python file applying RQ3 regression models to other platforms.
    │
    ├── 00_run.R                                       <- R file providing overall run file for R data processing & aggregation pipeline.
    ├── 00_run_pipeline.R                              <- R file accepting parameters from '00_run.R' and running downstream scripts.
    └── xx_config.R                                    <- R file providing configuration of harded coded parameters & look up tables for pipeline.
```
### Operating Data Processing Pipeline
In order to operate the data processing pipeline in R, data must be downloaded in CSV format from the EU's DSA-TD website in the standard nested zipped format containing day for one
day for one platform. In the '00_run.R' script the following parameters must be provided. After setting the parameters, executing the script will
automatically unzip the downloaded data, perform data quality analyses, clean and aggregate data into results.

```         
├── input/output paths
│    ├── inp_code                                     <- Define the path where all code lives.
│    ├── inp                                          <- Define the path where input data lives.
├── file remove?   
│    ├── remove_global_files                          <- TRUE, FALSE - Should the global file be deleted?
├── automatic or manual run?                          
│    ├── plat_man, plat_man_('month'/'date'/'year')   <- Define platform, month and date for automatic run of one platform.
│    ├── global_file_man                              <- Define filename of zipped SOR data for automatic one file run.
│    ├── aut, aut_plat, aut_plat_month, aut_man       <- Y/N - Should the software be run for all files in one platform, for one month only, for one file only? 
├── run steps? 
│    ├── run_('data_processing','sample_stage',       <- Y/N - Define which steps of the software should be run.
│             'dq','qual','cleaning','upstream',
│             'rq1','rq2','rq3')
├── run results? 
│    ├── run_results_only                             <- Y/N - Run only RQ1, RQ2 and RQ3 scripts.
├── collect results? 
│    ├── collect                                      <- Y/N - Should all available results be amalgamated automatically?
│    ├── collection_only                              <- Y/N - Should only the result collection process be run?
│    ├── collect_('dq','qual','rq1','rq2','rq3')      <- Y/N - Which results should be collected? (Per Software Step)
├── run final sample prep? 
│    ├── final_sample_prep                            <- Y/N - Should the final sample preparation step be run?
│    ├── date_to_extract                              <- Define date to form folder name of collected results (i.e. Folder '2025-06-27' contains all results collected on this date).
│    ├── out_version                                  <- Define string for version column for result output.
  
```
