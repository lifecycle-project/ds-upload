#' Download all released data dictionaries
#' 
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' @param dict_kind dictionary kind (possible kinds are 'core' or 'outcome')
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' 
#' @importFrom utils download.file
#' 

lc.dict.download <- local(function(dict_version, dict_kind, cohort_id, data_version) {
  message('------------------------------------------------------')
  message('  Start download dictionaries')
  packageTag <- packageVersion('lifecycleProject')
  download_base_dir <- paste('https://github.com/lifecycle-project/analysis-protocols/blob/', packageTag,'/R/data/dictionaries/', dict_kind ,'/', dict_version, '/', sep = '')
  dict_source_file_non_repeated <- paste(dict_version, '_non_repeated.xlsx', sep = '')
  dict_source_file_monthly_repeated <- paste(dict_version, '_monthly_repeated.xlsx', sep = '')
  dict_source_file_yearly_repeated <- paste(dict_version, '_yearly_repeated.xlsx', sep = '')
  dict_source_file_weekly_repeated <- paste(dict_version, '_weekly_repeated.xlsx', sep = '')
  
  dict_dest_file_non_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version, '_non_repeated.xlsx', sep = '')
  dict_dest_file_monthly_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version,'_monthly_repeated.xlsx', sep = '')
  dict_dest_file_yearly_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version, '_yearly_repeated.xlsx', sep = '')
  dict_dest_file_weekly_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version, '_weekly_repeated.xlsx', sep = '')
  
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
  
  message('  Successfully downloaded dictionaries')
})

#' Function that wraps around and bind the populate and reshape processes:
#' 
#' @param dict_version version of the data dictionnary to be used
#' @param dict_kind can be 'core' or 'outcome'
#' @param cohort_id cohort name
#' @param data_version version of the dataset to be uploaded
#' @param database_name ?
#' @param data_input_format format of the database to be reshaped. Can be 'CSV', 'STATA', or 'SAS'
#' @param upload_to_opal Wether to directly upload the reshaped database to the logged in opal server
#' @param data_input_path Path to the to-be-reshaped database
#' @param data_output_path Path where the reshaped databases will be written
#' @param action actio to be performed, can be 'reshape', 'populate' or 'all'
#' 
#' 
#' @export

lc.upload <- function(dict_version, dict_kind, cohort_id, data_version,
                      database_name = 'opal_data', data_input_format = 'CSV',
                      upload_to_opal = T, data_input_path, data_output_path = getwd(),
                      action = "all"){
  
  # Download dictionnaries from the remote repo:
  
  lc.dict.download(dict_version, dict_kind, cohort_id, data_version)
  
  # Check the action to be performed:
  
  if(!(action %in% c("all", "reshape", "populate"))){
    stop("unknown action type")
  }
  
  # And perform them
  
  if(action == "all" | action == "populate"){
    lc.populate(dict_version, cohort_id, data_version, database_name, dict_kind)
  }
  
  if(action == "all" | action == "reshape"){
    lc.reshape(upload_to_opal, data_version, data_input_format, dict_kind,
               data_input_path, cohort_id, output_path)
  }
  
  ## Delete the dictionnaries:
  
  file_name <- paste(dict_version, '.+repeated\\.xlsx', sep = '')
  dict_file_list <- list.files('.', pattern = file_name)
  unlink(dict_file_list)
}