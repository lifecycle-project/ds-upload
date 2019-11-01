# Use environment to store some path variables to use in different functions
lifecycle.globals <- new.env()

#' Populate your Opal instance with the new version of the data dictionary
#' Involves only the outcome variables
#'
#' @param dict_version dictionary version (possible dictionaries are: 1_0 / default = 1_0)
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' @param database_name the database name specified in your Opal instance (defaults to 'opal_data')
#'
#' @examples 
#' lc.populate.outcome(dict_version = '1_1', cohort_id = 'dnbc', data_version = '1_0')
#'
#' @export
lc.populate.outcome <- local(function(dict_version = '1_0', cohort_id, data_version, database_name = 'opal_data') {
  message('######################################################')
  message('  Start importing data dictionaries                   ')
  message('######################################################')
  
  if(!exists('hostname', envir = lifecycle.globals)) stop('You need to login first, please run lc.login')
  if(!exists('username', envir = lifecycle.globals)) stop('You need to login first, please run lc.login')
  
  if(missing(cohort_id)) cohort_id <- readline('- Specify cohort identifier (e.g. dnbc): ')
  if(cohort_id == '') {
    stop("No cohort identifier is specified! Program is terminated.", call. = FALSE)
  } else {
    if(!(cohort_id %in% lifecycle.globals$cohort_ids)) {
      stop('Cohort: [ ', cohort_id, ' ] is not know LifeCycle project. Please choose from: [ ', paste(lifecycle.globals$cohort_ids, collapse = ', '), ' ]')
    }
  }
  
  if(missing(data_version)) data_version <- readline('- Specify version of cohort data upload (e.g. 1_0): ')
  if(dict_version != '' && !(dict_version %in% lifecycle.globals$dictionaries_outcome)) {
    stop('Version: [ ', dict_version ,' ] is not available in published data dictionaries. Possible dictionaries are: ', paste(lifecycle.globals$dictionaries_core, collapse = ', '))
  } else {
    if(dict_version == '') dict_version <- '1_0'
  }
  if(data_version == '' || !checkVersion(data_version)) {
    stop("No data version is specified or the data version does not match syntax: 'number_number'! Program is terminated.", call. = FALSE)
  }
  
  dict_kind <- 'outcome'
  project <- paste('lifecycle_', dict_kind, '_', dict_version, sep = '')
  
  lc.dict.project.create(dict_version, dict_kind, project, database_name)
  lc.dict.outcome.download(dict_version, cohort_id, data_version)
  lc.dict.import(project, dict_version, dict_kind, cohort_id, data_version)
  
  message('######################################################')
  message('  Importing data dictionaries has finished            ')
  message('######################################################')
})

#' Download all released data dictionaries
#' 
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' 
#' @importFrom utils download.file
#' 
lc.dict.outcome.download <- local(function(dict_version, cohort_id, data_version) {
  message('------------------------------------------------------')
  message('  Start download dictionaries')
  download_base_dir <- paste('https://github.com/lifecycle-project/analysis-protocols/blob/master/R/data/dictionaries/outcome/', dict_version, '/', sep = '')
  
  dict_source_file_non_repeated <- paste(dict_version, '_non_repeated.xlsx', sep = '')
  dict_source_file_monthly_repeated <- paste(dict_version, '_monthly_repeated.xlsx', sep = '')
  dict_source_file_yearly_repeated <- paste(dict_version, '_yearly_repeated.xlsx', sep = '')
  
  message(paste('* Download: [ ', dict_source_file_non_repeated, ' ]', sep = ''))
  download.file(paste(download_base_dir, dict_source_file_non_repeated, '?raw=true', sep = ''), destfile=lifecycle.globals$dict_dest_file_non_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  message(paste('* Download: [ ', dict_source_file_monthly_repeated, ' ]', sep = ''))
  download.file(paste(download_base_dir, dict_source_file_monthly_repeated, '?raw=true', sep = ''), destfile=lifecycle.globals$dict_dest_file_monthly_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  message(paste('* Download: [ ', dict_source_file_yearly_repeated, ' ]', sep = ''))
  download.file(paste(download_base_dir, dict_source_file_yearly_repeated, '?raw=true', sep = ''), destfile=lifecycle.globals$dict_dest_file_yearly_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  
  message('  Successfully downloaded dictionaries')
})

