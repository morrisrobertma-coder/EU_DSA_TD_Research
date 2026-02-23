#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# xx_config ----
# Purpose of Script: Load important definitions.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Input/Output Directions ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Folder Structure ----
# In/Out Path
zip_in <- paste0(inp, "00_sor_global_zipped/")
zip_mid_out <- paste0(inp, "01_sor_global_unzipped/")
zip_out <- paste0(inp, "02_sor_global_ununzipped/")
out_per_platform <- paste0(inp, "03_sor_platforms/")

# Per Company Output
out_facebook <- paste0(out_per_platform,"01_facebook/")
out_youtube <- paste0(out_per_platform,"02_youtube/")
out_whatsapp <- paste0(out_per_platform,"03_whatsapp/") 
out_instagram <- paste0(out_per_platform,"04_instagram/")
out_tiktok <- paste0(out_per_platform,"05_tiktok/")
out_snap <- paste0(out_per_platform,"06_snap/")
out_x <- paste0(out_per_platform,"07_x/")

# Data Quality
out_dq_path <- paste0(inp, "04_dq/")

# Data Cleaning
out_clean_path <- paste0(inp, "05_clean/")

### Platforms ----
# Company/Platform Name Mapping
map_platform <- as.data.table(tibble::tribble(
  ~platform, ~platform_name, ~output,
  "facebook", "Facebook", out_facebook,
  "youtube", "YouTube", out_youtube,
  "whatsapp", "WhatsApp Channels", out_whatsapp,
  "instagram", "Instagram", out_instagram,
  "tiktok", "TikTok", out_tiktok,
  "snapchat", "Snapchat", out_snap,
  "x", "X", out_x))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Variable Definition & Manipulation ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Platform Name ----
# Company/Platform Name Mapping
map_platforms <- as.data.table(tibble::tribble(
  ~platform, ~platform_name, ~abkurzung,
  "facebook", "Facebook", "f",
  "youtube", "YouTube", "yt",
  "whatsapp", "WhatsApp Channels", "w", 
  "instagram", "Instagram", "i",
  "tiktok", "TikTok", "tt",
  "snapchat", "Snapchat", "s",
  "x", "X","x"))

### Territorial Scope ---- 
#### European union and EEA- countries - 30 entries
eu_inc_eea <- c("AT,BE,BG,CY,CZ,DE,DK,EE,ES,FI,FR,GR,HR,HU,IE,IS,IT,LI,LT,LU,LV,MT,NL,NO,PL,PT,RO,SE,SI,SK")

#### European union excluding Iceland, Liechtenstein and Norway - 27 entries
eu_ex_eea <- c("AT,BE,BG,CY,CZ,DE,DK,EE,ES,FI,FR,GR,HR,HU,IE,IT,LT,LU,LV,MT,NL,PL,PT,RO,SE,SI,SK")

### Automated Detection ----
map_auto <- as.data.table(tibble::tribble(
  ~des, ~abkurzung,
  "Yes","y",
  "No","n"))

### Automated Decision ----
map_auto_des <- as.data.table(tibble::tribble(
  ~des, ~abkurzung,
  "AUTOMATED_DECISION_FULLY","f",
  "AUTOMATED_DECISION_PARTIALLY","p",
  "AUTOMATED_DECISION_NOT_AUTOMATED","n"))

### Content Type ----
map_cont <- as.data.table(tibble::tribble(
  ~des, ~abkurzung,
  "CONTENT_TYPE_APP","ap",
  "CONTENT_TYPE_AUDIO","au", 
  "CONTENT_TYPE_IMAGE","i",
  "CONTENT_TYPE_PRODUCT","p",
  "CONTENT_TYPE_SYNTHETIC_MEDIA","sm",
  "CONTENT_TYPE_TEXT","t",
  "CONTENT_TYPE_VIDEO","v",
  "CONTENT_TYPE_OTHER","o"))

### Source Type ----
map_source <- as.data.table(tibble::tribble(
  ~des, ~abkurzung,
  "SOURCE_ARTICLE_16","a16",
  "SOURCE_TRUSTED_FLAGGER","tf", 
  "SOURCE_TYPE_OTHER_NOTIFICATION","o",
  "SOURCE_VOLUNTARY","v"))

### Category ----
map_cat <- as.data.table(tibble::tribble(
  ~des, ~abkurzung,
  "STATEMENT_CATEGORY_ANIMAL_WELFARE","aw",
  "STATEMENT_CATEGORY_CONSUMER_INFORMATION","ci",
  "STATEMENT_CATEGORY_CYBER_VIOLENCE","cv",
  "STATEMENT_CATEGORY_CYBER_VIOLENCE_AGAINST_WOMEN","cvaw",
  "STATEMENT_CATEGORY_DATA_PROTECTION_AND_PRIVACY_VIOLATIONS","dppv",
  "STATEMENT_CATEGORY_ILLEGAL_OR_HARMFUL_SPEECH","ihs",
  "STATEMENT_CATEGORY_INTELLECTUAL_PROPERTY_INFRINGEMENTS","ipi",
  "STATEMENT_CATEGORY_NEGATIVE_EFFECTS_ON_CIVIC_DISCOURSE_OR_ELECTIONS","necde",
  "STATEMENT_CATEGORY_NOT_SPECIFIED_NOTICE","nsn",
  "STATEMENT_CATEGORY_OTHER_VIOLATION_TC","ovt",
  "STATEMENT_CATEGORY_PROTECTION_OF_MINORS","pm",
  "STATEMENT_CATEGORY_RISK_FOR_PUBLIC_SECURITY","rps",
  "STATEMENT_CATEGORY_SCAMS_AND_FRAUD","sf",
  "STATEMENT_CATEGORY_SELF_HARM","sh",
  "STATEMENT_CATEGORY_UNSAFE_AND_PROHIBITED_PRODUCTS","upp",
  "STATEMENT_CATEGORY_VIOLENCE","v"))

### Category Specification ----
map_cat_spec <- as.data.table(tibble::tribble(
  ~des, ~abkurzung,
  "KEYWORD_ANIMAL_HARM","ah",
  "KEYWORD_ADULT_SEXUAL_MATERIAL","asm",
  "KEYWORD_AGE_SPECIFIC_RESTRICTIONS","sr",
  "KEYWORD_AGE_SPECIFIC_RESTRICTIONS_MINORS","srm",
  "KEYWORD_BIOMETRIC_DATA_BREACH","bdb",
  "KEYWORD_BULLYING_AGAINST_GIRLS","bag",
  "KEYWORD_CHILD_SEXUAL_ABUSE_MATERIAL","csam",
  "KEYWORD_CHILD_SEXUAL_ABUSE_MATERIAL_DEEPFAKE","csamd",
  "KEYWORD_PROMOTING_EATING_DISORDERS","pdis",
  "KEYWORD_COORDINATED_HARM","coh",
  "KEYWORD_COPYRIGHT_INFRINGEMENT","copi",
  "KEYWORD_CYBER_BULLYING_INTIMIDATION","cybi",
  "KEYWORD_CYBER_HARASSMENT","cyh",
  "KEYWORD_CYBER_HARASSMENT_AGAINST_WOMEN","cyhaw",
  "KEYWORD_CYBER_INCITEMENT","cyi",
  "KEYWORD_CYBER_STALKING","cys",
  "KEYWORD_CYBER_STALKING_AGAINST_WOMEN","cysaw",
  "KEYWORD_DATA_FALSIFICATION","df",
  "KEYWORD_DEFAMATION","def",
  "KEYWORD_DESIGN_INFRINGEMENT","di",
  "KEYWORD_DISCRIMINATION","dis",
  "KEYWORD_MISINFORMATION_DISINFORMATION","mis",
  "KEYWORD_FEMALE_GENDERED_DISINFORMATION","fgdis",
  "KEYWORD_GEOGRAPHIC_INDICATIONS_INFRINGEMENT","gii",
  "KEYWORD_GEOGRAPHICAL_REQUIREMENTS","gr",
  "KEYWORD_GOODS_SERVICES_NOT_PERMITTED","gsnp",
  "KEYWORD_GROOMING_SEXUAL_ENTICEMENT_MINORS","gsem",
  "KEYWORD_HATE_SPEECH","hs",
  "KEYWORD_HIDDEN_ADVERTISEMENT","ha",
  "KEYWORD_HUMAN_EXPLOITATION","hex",
  "KEYWORD_HUMAN_TRAFFICKING","het",
  "KEYWORD_ILLEGAL_ORGANIZATIONS","ilo",
  "KEYWORD_IMPERSONATION_ACCOUNT_HIJACKING","iah",
  "KEYWORD_INAUTHENTIC_LISTINGS","il",
  "KEYWORD_INAUTHENTIC_USER_REVIEWS","iur",
  "KEYWORD_INCITEMENT_AGAINST_WOMEN","iaw",
  "KEYWORD_INCITEMENT_VIOLENCE_HATRED","ivh",
  "KEYWORD_INSUFFICIENT_INFORMATION_ON_TRADERS","iit",
  "KEYWORD_LANGUAGE_REQUIREMENTS","lr",
  "KEYWORD_MISLEADING_INFO_CONSUMER_RIGHTS","micr",
  "KEYWORD_MISLEADING_INFO_GOODS_SERVICES","migs",
  "KEYWORD_MISSING_PROCESSING_GROUND","mpg",
  "KEYWORD_NON_CONSENSUAL_IMAGE_SHARING","ncis",
  "KEYWORD_NON_CONSENSUAL_IMAGE_SHARING_AGAINST_WOMEN","ncisaw",
  "KEYWORD_NON_CONSENSUAL_MATERIAL_DEEPFAKE","ncmd",
  "KEYWORD_NON_CONSENSUAL_MATERIAL_DEEPFAKE_AGAINST_WOMEN","ncmdaw",
  "KEYWORD_NONCOMPLIANCE_PRICING","ncp",
  "KEYWORD_NUDITY","nud",
  "KEYWORD_PATENT_INFRINGEMENT","pati",
  "KEYWORD_PHISHING","phis",
  "KEYWORD_PROHIBITED_PRODUCTS","prop",
  "KEYWORD_PYRAMID_SCHEMES","pys",
  "KEYWORD_RIGHT_TO_BE_FORGOTTEN","rtbf",
  "KEYWORD_ENVIRONMENTAL_DAMAGE","envd",
  "KEYWORD_RISK_PUBLIC_HEALTH","rpubh",
  "KEYWORD_SELF_MUTILATION","selfm",
  "KEYWORD_STALKING","stk",
  "KEYWORD_SUICIDE","sui",
  "KEYWORD_TERRORIST_CONTENT","tc",
  "KEYWORD_TRADE_SECRET_INFRINGEMENT","trsi",
  "KEYWORD_TRADEMARK_INFRINGEMENT","tradei",
  "KEYWORD_TRAFFICKING_WOMEN_GIRLS","trwg",
  "KEYWORD_UNLAWFUL_SALE_ANIMALS","unsa",
  "KEYWORD_UNSAFE_CHALLENGES","unch",
  "KEYWORD_UNSAFE_PRODUCTS","unprod",
  "KEYWORD_VIOLATION_EU_LAW","vioeul",
  "KEYWORD_VIOLATION_NATIONAL_LAW","vionatl",
  "KEYWORD_OTHER",""))

### Decision Ground ----
map_des_ground <- as.data.table(tibble::tribble(
  ~des, ~abkurzung, 
  "DECISION_GROUND_ILLEGAL_CONTENT","illc",
  "DECISION_GROUND_INCOMPATIBLE_CONTENT","incpc"))

### Decision Visibility ----
map_des_vis <- as.data.table(tibble::tribble(
  ~des, ~abkurzung, 
  "DECISION_VISIBILITY_CONTENT_REMOVED","cr",
  "DECISION_VISIBILITY_CONTENT_DISABLED","dis",
  "DECISION_VISIBILITY_CONTENT_DEMOTED","dem",
  "DECISION_VISIBILITY_CONTENT_AGE_RESTRICTED","ar",
  "DECISION_VISIBILITY_CONTENT_INTERACTION_RESTRICTED","ir",
  "DECISION_VISIBILITY_CONTENT_LABELLED","lab",
  "DECISION_VISIBILITY_OTHER","o",))

### Decision Monetary ----
map_des_mon <- as.data.table(tibble::tribble(
  ~des, ~abkurzung,
  "DECISION_MONETARY_SUSPENSION","ms",
  "DECISION_MONETARY_TERMINATION","mt",
  "DECISION_MONETARY_OTHER","o"))

### Decision Provision ----
map_des_prov <- as.data.table(tibble::tribble(
  ~des, ~abkurzung,
  "DECISION_PROVISION_PARTIAL_SUSPENSION","ps",
  "DECISION_PROVISION_TOTAL_SUSPENSION","ts",
  "DECISION_PROVISION_PARTIAL_TERMINATION","pt",
  "DECISION_PROVISION_TOTAL_TERMINATION", "tt"))

### Decision Account ----
map_des_acc <- as.data.table(tibble::tribble(
  ~des, ~abkurzung,
  "DECISION_ACCOUNT_SUSPENDED","as",
  "DECISION_ACCOUNT_TERMINATED","at"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Columns to Keep ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cols_to_keep <- c("platform_name","territorial_scope","created_at",
                  "content_date","application_date", "automated_decection",
                  "automated_decision","content_type","content_language",
                  "source_type","category","category_specification",
                  "decision_ground","incompatible_content_ground",
                  "incompatible_content_illegal",
                  "decision_visibility", "decision_visibility_other",
                  "end_date_visibility_restriction", 
                  "decision_monetary","decision_monetary_other",
                  "end_date_monetary_restriction","decision_provision",
                  "end_date_service_restriction",
                  "decision_account", "end_date_account_restriction")

# Rename Columns
# n.b. only use this after the fully processing - not one to one mapping
# with 'cols_to_keep_above'
cols_order <- c('p_name','terr','date','time','content_d',
                'app_date','aut_det','aut_dec','content_type',
                'content_lang','source','cat','cat_spec',
                'des_ground','incomp_c_ground','incomp_c_illegal',
                'des_vis','des_vis_other','des_vis_end_date',
                'des_mon','des_mon_other','des_mon_end_date',
                'des_prov','des_prov_end_date','des_acc',
                'des_acc_end_date')

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# End
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
