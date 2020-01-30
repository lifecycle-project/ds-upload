#' Uploading the generated data files
#' 
#' @param file_prefix a date to prefix the file with
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version the data release version
#' @param file_name name of the data file
#' 
#' @importFrom opalr opal.file_upload
#' 
lc.reshape.upload <- local(function(file_prefix, dict_kind, file_version, file_name) {
  upload_directory <- paste('/home/', lifecycle.globals$username, sep = '')
  file_ext <- '.csv'
  
  message(paste('* Upload: ', paste(getwd(), '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, file_ext, sep = ''), sep = ''))
  opal.file_upload(opal = lifecycle.globals$opal, source = paste(getwd(), '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, file_ext, sep = ''), destination = upload_directory)
  
  unlink(paste(getwd(), '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, file_ext, sep = ''))
})

#' Importing generated data files
#' 
#' @param file_prefix a date to prefix the file with
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version the data release version
#' @param file_name name of the data file
#' 
#' @importFrom readr read_csv
#' @importFrom opalr opal.post
#' @importFrom opalr opal.projects
#' @importFrom opalr opal.tables
#' @importFrom jsonlite toJSON
#' 
lc.reshape.import <- local(function(file_prefix, dict_kind, file_version, file_name) {
  
  message('------------------------------------------------------')
  message('  Start importing data files')
  
  file_ext <- '.csv'
  
  projects <- opal.projects(lifecycle.globals$opal)
  project <- readline(paste('Which project you want to upload into: [ ', paste0(projects$name, collapse = ', '), ' ]: ', sep = ''))
  
  if(!(project %in% projects$name)) {
    stop(paste('Invalid projectname: [ ', project,' ]', sep = ''))
  }
  
  tables <- opal.tables(lifecycle.globals$opal, project)
  
  table_name <- ''
  if(file_name %in% tables$name) {
    table = tables$name 
  } 
  
  data <- read_csv(paste(getwd(), '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, file_ext, sep = ''))
  
  message(paste('* Import: ', paste(getwd(), '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, file_ext, sep = ''), sep = ''))
  opal.post(lifecycle.globals$opal, 'datasource', lifecycle.globals$project, 'table', table_name, 'variables', body=toJSON(data), contentType = 'application/x-protobuf+json')  
  
  unlink(paste(getwd(), '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, file_ext, sep = ''))
  
  message('  Succesfully imported the files')
})

#' Get the table without rows containing only NA's. 
#' 
#' We have to remove the first column (child_id), that is generated always.
#' 
#' @param dataframe dataframe to check
#' 
#' @importFrom dplyr %>%
#'
#' @returnfiltered dataframe
#'
lc.data.frame.remove.all.na.rows <- local(function(dataframe) {
  
  df <- dataframe[ -c(1) ]
  
  naLines <- df %>%
    is.na() %>%
    apply(MARGIN = 1, FUN = all)
  
  return(df[!naLines,])
})
