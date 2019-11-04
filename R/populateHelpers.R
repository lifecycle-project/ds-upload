#' Read the input file from different sources
#' 
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param input_path path for importfile
#' 
#' @importFrom readr read_csv cols col_double
#' @importFrom haven read_dta read_sas read_spss
#' 
#' @return dataframe with source data
lc.read.source.file <- local(function(input_path, input_format = 'CSV') {
  lc_data <- NULL
  
  if(missing(input_path)) {
    input_path <- readline('- Specify input path (for your data): ')
    input_format <- readline('- Specify input format (possible formats: CSV,STATA,SPSS or SAS - default = CSV): ')
  }
  if (input_format %in% lifecycle.globals$input_formats) {
    if (input_format == 'STATA') lc_data <- read_dta(input_path)
    else if (input_format == 'SPSS') lc_data <- read_spss(input_path)
    else if (input_format == 'SAS') lc_data <- read_sas(input_path)
    else lc_data <- read_csv(input_path, col_types = cols(.default = col_double()))
  } else {
    stop(paste(input_format, ' is not a valid input format, Possible input formats are: ', lifecycle.globals$input_formats, sep = ','))
  }
  
  return(lc_data)
})

#' Create the project with data dictionary version in between
#'
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' @param dict_kind can be outcome or core
#' @param project prpject resource in Opal
#' @param database_name the database name of the Opal instance (default = opal_data)
#' 
#' 
#' @importFrom dplyr between
#' @importFrom opalr opal.post
#'
lc.dict.project.create <- local(function(dict_version, dict_kind = 'core', project, database_name, cohort_id) {
  message('------------------------------------------------------')
  message(paste('  Start creating the project: [ ', dict_kind, ' ] with version: [ ', dict_version, ' ]', sep = ''))
  project <- paste('lifecycle_', cohort_id, '_', dict_kind, '_', dict_version, sep = '')
  projects <- opal.projects(lifecycle.globals$opal)
  if(!(project %in% projects$name)) {
    json <- sprintf('{"database":"%s","description":"%s","name":"%s","title":"%s"}', database_name, paste('Project for [ ', dict_kind ,' ] variables and data dictionary version: [ ', dict_version,' ]', sep = ''), project, project)
    opal.post(lifecycle.globals$opal, 'projects', body = json, contentType = 'application/x-protobuf+json')
  } else {
    message(paste('* Project: [ ', project,' ] already exists', sep = ''))
  }
})

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
  
  dict_dest_file_non_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version, '_non_repeated.xlsx', sep = '')
  dict_dest_file_monthly_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version,'_monthly_repeated.xlsx', sep = '')
  dict_dest_file_yearly_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version, '_yearly_repeated.xlsx', sep = '')
  
  message(paste('* Download: [ ', dict_source_file_non_repeated, ' ]', sep = ''))
  download.file(paste(download_base_dir, dict_source_file_non_repeated, '?raw=true', sep = ''), destfile=dict_dest_file_non_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  message(paste('* Download: [ ', dict_source_file_monthly_repeated, ' ]', sep = ''))
  download.file(paste(download_base_dir, dict_source_file_monthly_repeated, '?raw=true', sep = ''), destfile=dict_dest_file_monthly_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  message(paste('* Download: [ ', dict_source_file_yearly_repeated, ' ]', sep = ''))
  download.file(paste(download_base_dir, dict_source_file_yearly_repeated, '?raw=true', sep = ''), destfile=dict_dest_file_yearly_repeated, mode = "wb", method="libcurl", quiet = TRUE)
  
  message('  Successfully downloaded dictionaries')
})

#' Import the tables into Opal
#' 
#' @param project project resource in Opal
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' @param dict_kind can be 'core' or 'outcome'
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' 
#' @importFrom readxl read_xlsx
#' 
lc.dict.import <- local(function(project, dict_version, dict_kind, cohort_id, data_version) {
  message('------------------------------------------------------')
  message('  Start importing dictionaries')
  
  dict_table_non_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version, '_non_repeated', sep = '')
  dict_table_monthly_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version, '_monthly_repeated', sep = '')
  dict_table_yearly_repeated <- paste(dict_version, '_', dict_kind, '_', cohort_id, '_', data_version, '_yearly_repeated', sep = '')
  
  json_non_repeated <- sprintf('{"entityType":"Participant","name":"%s"}', dict_table_non_repeated)
  json_monthly_repeated <- sprintf('{"entityType":"Participant","name":"%s"}', dict_table_monthly_repeated)
  json_yearly_repeated <- sprintf('{"entityType":"Participant","name":"%s"}', dict_table_yearly_repeated)
  
  tables <- opal.tables(lifecycle.globals$opal, project)
  
  if(!(dict_table_non_repeated %in% tables$name)) {
    message(paste('* Create table: [ ', dict_table_non_repeated,' ]', sep = ''))
    opal.post(lifecycle.globals$opal, 'datasource', project, 'tables', body=json_non_repeated, contentType = 'application/x-protobuf+json')
  } else {
    message(paste('* Table: [ ', dict_table_non_repeated,' ] already exists', sep = ''))
  }
  if(!(dict_table_monthly_repeated %in% tables$name)) {
    message(paste('* Create table: [ ', dict_table_monthly_repeated,' ]', sep = ''))
    opal.post(lifecycle.globals$opal, 'datasource', project, 'tables', body=json_monthly_repeated, contentType = 'application/x-protobuf+json')
  } else {
    message(paste('* Table: [ ', dict_table_monthly_repeated,' ] already exists', sep = ''))
  }
  if(!(dict_table_yearly_repeated %in% tables$name)) {
    message(paste('* Create table: [ ', dict_table_yearly_repeated,' ]', sep = ''))
    opal.post(lifecycle.globals$opal, 'datasource', project, 'tables', body=json_yearly_repeated, contentType = 'application/x-protobuf+json')
  } else {
    message(paste('* Table: [ ', dict_table_yearly_repeated,' ] already exists', sep = ''))
  }
  
  variables_non_repeated_measures <- read_xlsx(path = paste(getwd(), '/', dict_table_non_repeated, '.xlsx', sep = ''), sheet = 1)
  variables_yearly_repeated_measures <- read_xlsx(path = paste(getwd(), '/', dict_table_yearly_repeated, '.xlsx', sep = ''), sheet = 1)
  variables_monthly_repeated_measures <- read_xlsx(path = paste(getwd(), '/', dict_table_monthly_repeated, '.xlsx', sep = ''), sheet = 1)
  
  categories_non_repeated_measures <- read_xlsx(path = paste(getwd(), '/', dict_table_non_repeated, '.xlsx', sep = ''), sheet = 2)
  categories_monthly_repeated_measures <- read_xlsx(path = paste(getwd(), '/', dict_table_yearly_repeated, '.xlsx', sep = ''), sheet = 2)
  categories_yearly_repeated_measures <- read_xlsx(path = paste(getwd(), '/', dict_table_monthly_repeated, '.xlsx', sep = ''), sheet = 2)
  
  lc.populate.match.categories(project, dict_table_non_repeated, variables_non_repeated_measures, categories_non_repeated_measures, paste(dict_table_non_repeated, '.xlsx', sep = ''))
  lc.populate.match.categories(project, dict_table_monthly_repeated, variables_monthly_repeated_measures, categories_monthly_repeated_measures, paste(dict_table_yearly_repeated, '.xlsx', sep = ''))
  lc.populate.match.categories(project, dict_table_yearly_repeated, variables_yearly_repeated_measures, categories_yearly_repeated_measures, paste(dict_table_monthly_repeated, '.xlsx', sep = ''))
  
  message('  All dictionaries are populated correctly')
})

#' Match the categories with the variables to be import them
#' Import the variables
#' 
#' @param project project resource in Opal
#' @param table dictionary to upload to Opal
#' @param variables dictionary variables to upload
#' @param categories dictionary categories to upload
#' @param source_file source file for the dictionaries
#'
#' @importFrom opalr opal.post
#' @importFrom dplyr select %>% nest_join rename
#'
lc.populate.match.categories <- local(function(project, table, variables, categories, source_file) {
  # workaround to avoid global variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  label <- name <- NULL
  
  variables$entityType <- 'Participant'
  variables$isRepeatable <- FALSE
  variables$attributes <- data.frame(namespace = '', name = 'label', locale = '', value = variables$label)
  variables <- select(variables, -c(label))
  
  if (nrow(categories) > 0) {
    message(paste('* Matched categories for table: [ ', table,' ]', sep = ''))
    categories <- transform(categories, name = as.character(name))
    categories$attributes <- data.frame(namespace = '', name = 'label', locale = '', value = categories$label)
    categories <- select(categories, -c(label))
    variables <- variables %>% nest_join(categories, by = c('name' = 'variable'))
  }
  
  message(paste('* Import variables into: [ ', table,' ]', sep = ''))
  opal.post(lifecycle.globals$opal, 'datasource', project, 'table', table, 'variables', body=toJSON(variables), contentType = 'application/x-protobuf+json')  
#  message(paste('* Remove the table: [', source_file,']', sep = ''))
#  unlink(source_file)
})