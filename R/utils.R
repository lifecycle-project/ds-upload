# Use environment to store some path variables to use in different functions
lifecycle.globals <- new.env()

cohorts <- c('dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')

lifecycle.globals$input_formats <- c('CSV', 'STATA', 'SPSS', 'SAS')
lifecycle.globals$variable_category <- c('ALL','META','MATERNAL','PATERNAL','CHILD','HOUSEHOLD')
lifecycle.globals$cohort_ids <- cohorts

lifecycle.globals$dictionaries_core <- c('1_0', '2_0')
lifecycle.globals$dictionaries_outcome <- c('1_0')

#' Download all released data dictionaries
#' 
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' @param dict_kind dictionary kind (possible kinds are 'core' or 'outcome')
#' 
#' @importFrom utils download.file packageVersion
#' 
lc.dict.download <- local(function(dict_version, dict_kind) {
  
  message('------------------------------------------------------')
  message('  Start download dictionaries')
  packageTag <- packageVersion('lifecycleProject')
  download_base_dir <- paste('https://github.com/lifecycle-project/analysis-protocols/blob/', packageTag,'/R/data/dictionaries/', dict_kind ,'/', dict_version, '/', sep = '')
  dict_source_file_non_repeated <- paste(dict_version, '_non_rep.xlsx', sep = '')
  dict_source_file_monthly_repeated <- paste(dict_version, '_monthly_rep.xlsx', sep = '')
  dict_source_file_yearly_repeated <- paste(dict_version, '_yearly_rep.xlsx', sep = '')
  dict_source_file_weekly_repeated <- paste(dict_version, '_weekly_rep.xlsx', sep = '')
  dict_source_file_trimester_repeated <- paste(dict_version, '_trimester_rep.xlsx', sep = '')
  
  dict_dest_file_non_repeated <- paste(dict_version, '_', dict_kind, '_non_rep.xlsx', sep = '')
  dict_dest_file_monthly_repeated <- paste(dict_version, '_', dict_kind, '_monthly_rep.xlsx', sep = '')
  dict_dest_file_yearly_repeated <- paste(dict_version, '_', dict_kind, '_yearly_rep.xlsx', sep = '')
  dict_dest_file_weekly_repeated <- paste(dict_version, '_', dict_kind, '_weekly_rep.xlsx', sep = '')
  dict_dest_file_trimester_repeated <- paste(dict_version, '_', dict_kind, '_trimester_rep.xlsx', sep = '')
  
  message(paste('* Download: [ ', dict_source_file_non_repeated, ' ]', sep = ''))
  download.file(paste(download_base_dir, dict_source_file_non_repeated, '?raw=true', sep = ''), destfile=dict_dest_file_non_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  message(paste('* Download: [ ', dict_source_file_monthly_repeated, ' ]', sep = ''))
  download.file(paste(download_base_dir, dict_source_file_monthly_repeated, '?raw=true', sep = ''), destfile=dict_dest_file_monthly_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  message(paste('* Download: [ ', dict_source_file_yearly_repeated, ' ]', sep = ''))
  download.file(paste(download_base_dir, dict_source_file_yearly_repeated, '?raw=true', sep = ''), destfile=dict_dest_file_yearly_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  
  if(dict_kind == "outcome"){
    message(paste('* Download: [ ', dict_source_file_weekly_repeated, ' ]', sep = ''))
    download.file(paste(download_base_dir, dict_source_file_weekly_repeated, '?raw=true', sep = ''), destfile=dict_dest_file_weekly_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  }
  
  if(dict_kind == 'core' && dict_version != '1_0') {
    message(paste('* Download: [ ', dict_source_file_trimester_repeated, ' ]', sep = ''))
    download.file(paste(download_base_dir, dict_source_file_trimester_repeated, '?raw=true', sep = ''), destfile=dict_dest_file_trimester_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  }
  
  message('  Successfully downloaded dictionaries')
})

#' Numerical extraction function
#' Number at the end of the string: Indicates year. We need to extract this to create the age_years variable.
#' This is the function to do so.
#' 
#' @param input_string convert this string into an integer value
#' 
#' @importFrom stringr str_extract
#' 
numextract <- local(function(input_string) { 
  str_extract(input_string, "\\d*$") 
})

#' This function creates a summary table
#' 
#' @param df data frame to summarise
#' @param .var variable to summarise
#' 
#' @importFrom dplyr summarise n
#' @importFrom rlang sym
#' @importFrom stats median
#' 
#' @return a summary of the data
#' 
summarizeR <- local(function(df, .var) {
  
  .var <- sym(.var)
  
  data_summary <- df %>%
    summarise(variable=paste(.var),
                     min = min(!! .var, na.rm = TRUE),
                     max = max(!! .var, na.rm = TRUE),
                     median = median(!! .var, na.rm = TRUE),
                     mean = mean(!! .var, na.rm = TRUE),
                     n=n(),
                     missing=sum(is.na(!! .var))
    )
  return(data_summary)
})

#'
#' Check if the given version matches the syntax number . underscore . number
#' 
#' @param version the version input of the user
#' 
#' @importFrom stringr str_detect
#'
checkVersion <- local(function(version) {
  return(str_detect(version, "\\d+\\_\\d+"))
})

