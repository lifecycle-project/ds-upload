# Use environment to store some path variables to use in different functions
lifecycle.globals <- new.env()

#' Populate your Opal instance with the new version of the data dictionary
#' Involves only the core variables
#'
#' @param create_project create the 'lifecycle'-project in Opal instance (default = false)
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#'
#' @import opalr
#'
#' @export
lc.populate.core <- local(function(create_project = FALSE, dict_version = '1_0', cohort_id, data_version, data_changes) {
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
  
  if(missing(dict_version)) data_version <- readline('- Specify version of cohort data upload (e.g. 1_0): ')
  if(!(data_version %in% lifecycle.globals$dictionaries)) {
    stop('Version: [ ', data_version ,' ] is not available in published data dictionaries. Possible dictionaries are: ', paste(lifecycle.globals$dictionaries, collapse = ', '))
  }
  if(data_version == '') {
    stop("No data version is specified! Program is terminated.", call. = FALSE)
  }
  
  if(missing(data_changes)) data_changes <- readline('- Specify changes in data upload version (e.g. "new participants added": ')
  if(data_changes == '') {
    stop("No changes in data are specified! Program is terminated.", call. = FALSE)
  }
  
  if(dict_version == '') dict_version <- '1_0'
  
  if(create_project) {
    lc.dict.project.create(dict_version) 
  }
  
  lc.dict.download(dict_version, cohort_id, data_version)
  lc.dict.import(dict_version, cohort_id, data_version)
  
  message('######################################################')
  message('  Importing data dictionaries has finished            ')
  message('######################################################')
})

#' Create the project with data dictionary version in between
#'
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' 
#' @importFrom dplyr between
#'
lc.dict.project.create <- local(function(dict_version) {
  message('------------------------------------------------------')
  message(paste('  Start creating the project version: [ ', dict_version, ' ]', sep = ''))
  lifecycle.globals$project <- paste('lifecycle_dict_', dict_version, sep = '')
  projects <- opal.projects(lifecycle.globals$opal)
  if(!(lifecycle.globals$project %in% projects$name)) {
    json <- sprintf('{"database":"%s","description":"%s","name":"%s","title":"%s"}', 'opal_data', paste('LifeCycle project for data dictionary version: [ ', lifecycle.globals$project,' ]', sep = ''), lifecycle.globals$project, lifecycle.globals$project)
    opal.post(lifecycle.globals$opal, 'projects', body = json, contentType = 'application/x-protobuf+json')
  } else {
    message(paste('* Project: [ ', lifecycle.globals$project,' ] already exists', sep = ''))
  }
})

#' Download all released data dictionaries
#' 
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' 
lc.dict.download <- local(function(dict_version, cohort_id, data_version) {
  message('------------------------------------------------------')
  message('  Start download dictionaries')
  download_base_dir <- paste('https://github.com/lifecycle-project/analysis-protocols/blob/master/R/data/dictionaries/', dict_version, '/', sep = '')
  
  dict_source_file_non_repeated <- paste(dict_version, '_non_repeated_measures.xlsx', sep = '')
  dict_source_file_monthly_repeated <- paste(dict_version, '_monthly_repeated_measures.xlsx', sep = '')
  dict_source_file_yearly_repeated <- paste(dict_version, '_yearly_repeated_measures.xlsx', sep = '')
  
  lifecycle.globals$dict_dest_file_non_repeated <- paste(dict_version, '_', cohort_id, '_', data_version, '_non_repeated_measures.xlsx', sep = '')
  lifecycle.globals$dict_dest_file_monthly_repeated <- paste(dict_version, '_', cohort_id, '_', data_version,'_monthly_repeated_measures.xlsx', sep = '')
  lifecycle.globals$dict_dest_file_yearly_repeated <- paste(dict_version, '_', cohort_id, '_', data_version, '_yearly_repeated_measures.xlsx', sep = '')
  
  message(paste('* Download: ', dict_source_file_non_repeated, sep = ''))
  download.file(paste(download_base_dir, dict_source_file_non_repeated, '?raw=true', sep = ''), destfile=lifecycle.globals$dict_dest_file_non_repeated, method="libcurl", quiet = TRUE)
  message(paste('* Download: ', dict_source_file_monthly_repeated, sep = ''))
  download.file(paste(download_base_dir, dict_source_file_monthly_repeated, '?raw=true', sep = ''), destfile=lifecycle.globals$dict_dest_file_monthly_repeated, method="libcurl", quiet = TRUE)
  message(paste('* Download: ', dict_source_file_yearly_repeated, sep = ''))
  download.file(paste(download_base_dir, dict_source_file_yearly_repeated, '?raw=true', sep = ''), destfile=lifecycle.globals$dict_dest_file_yearly_repeated, method="libcurl", quiet = TRUE)
  
  message('  Successfully downloaded dictionaries')
})

#' Import the tables into Opal
#' 
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' 
#' @importFrom opalr opal.post
#' @importFrom openxlsx read.xlsx
#' 
lc.dict.import <- local(function(dict_version, cohort_id, data_version) {
  message('------------------------------------------------------')
  message('  Start importing dictionaries')
  
  dict_table_non_repeated <- paste(dict_version, '_', cohort_id, '_', data_version, '_non_repeated_measures', sep = '')
  dict_table_monthly_repeated <- paste(dict_version, '_', cohort_id, '_', data_version,'_monthly_repeated_measures', sep = '')
  dict_table_yearly_repeated <- paste(dict_version, '_', cohort_id, '_', data_version, '_yearly_repeated_measures', sep = '')
  
  json_non_repeated <- sprintf('{"entityType":"Participant","name":"%s"}', dict_table_non_repeated)
  json_monthly_repeated <- sprintf('{"entityType":"Participant","name":"%s"}', dict_table_monthly_repeated)
  json_yearly_repeated <- sprintf('{"entityType":"Participant","name":"%s"}', dict_table_yearly_repeated)
  
  tables <- opal.tables(lifecycle.globals$opal, lifecycle.globals$project)
  
  if(!(dict_table_non_repeated %in% tables$name)) {
    message(paste('* Create table: [ ', dict_table_non_repeated,' ]', sep = ''))
    opal.post(lifecycle.globals$opal, 'datasource', lifecycle.globals$project, 'tables', body=json_non_repeated, contentType = 'application/x-protobuf+json')
  } else {
    message(paste('* Table: [ ', dict_table_non_repeated,' ] already exists', sep = ''))
  }
  if(!(dict_table_monthly_repeated %in% tables$name)) {
    message(paste('* Create table: [', dict_table_monthly_repeated,']', sep = ''))
    opal.post(lifecycle.globals$opal, 'datasource', lifecycle.globals$project, 'tables', body=json_monthly_repeated, contentType = 'application/x-protobuf+json')
  } else {
    message(paste('* Table: [ ', dict_table_monthly_repeated,' ] already exists', sep = ''))
  }
  if(!(dict_table_yearly_repeated %in% tables$name)) {
    message(paste('* Create table: [', dict_table_yearly_repeated,']', sep = ''))
    opal.post(lifecycle.globals$opal, 'datasource', lifecycle.globals$project, 'tables', body=json_yearly_repeated, contentType = 'application/x-protobuf+json')
  } else {
    message(paste('* Table: [ ', dict_table_yearly_repeated,' ] already exists', sep = ''))
  }
  
  variables_non_repeated_measures <- read.xlsx(paste(getwd(), '/', lifecycle.globals$dict_dest_file_non_repeated, sep = ''))
  variables_monthly_repeated_measures <- read.xlsx(paste(getwd(), '/', lifecycle.globals$dict_dest_file_monthly_repeated, sep = ''))
  variables_yearly_repeated_measures <- read.xlsx(paste(getwd(), '/', lifecycle.globals$dict_dest_file_yearly_repeated, sep = ''))
  
  variables_non_repeated$entityType <- 'Participant'
  variables_non_repeated$isRepeatable <- FALSE
  
  variables_monthly_repeated$entityType <- 'Participant'
  variables_monthly_repeated$isRepeatable <- FALSE
  
  variables_yearly_repeated$entityType <- 'Participant'
  variables_yearly_repeated$isRepeatable <- FALSE
  
  message(paste('* Import variables into: [', dict_table_non_repeated,']', sep = ''))
  opal.post(lifecycle.globals$opal, 'datasource', lifecycle.globals$project, 'table', dict_table_non_repeated, 'variables', body=toJSON(variables_non_repeated), contentType = 'application/x-protobuf+json')  
  message(paste('* Import variables into: [', dict_table_monthly_repeated,']', sep = ''))
  opal.post(lifecycle.globals$opal, 'datasource', lifecycle.globals$project, 'table', dict_table_yearly_repeated, 'variables', body=toJSON(variables_yearly_repeated), contentType = 'application/x-protobuf+json')  
  message(paste('* Import variables into: [', dict_table_yearly_repeated,']', sep = ''))
  opal.post(lifecycle.globals$opal, 'datasource', lifecycle.globals$project, 'table', dict_table_monthly_repeated, 'variables', body=toJSON(variables_monthly_repeated), contentType = 'application/x-protobuf+json')  
  
  message('* Remove the tables from workspace')
  unlink(lifecycle.globals$dict_dest_file_non_repeated)
  unlink(lifecycle.globals$dict_dest_file_monthly_repeated)
  unlink(lifecycle.globals$dict_dest_file_yearly_repeated)
  
  message('  All dictionaries are populated correctly')
})
