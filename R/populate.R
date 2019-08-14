#' Populate your Opal instance with the new version of the data dictionary
#'
#' @import opal
#'
#' @export
lc.populate <- local(function() {
  message('######################################################')
  message('  Start importing data dictionaries                   ')
  message('######################################################')
  
  hostname <- readline('- Hostname (http://localhost): ')
  username <- readline('- Username (administrator): ')
  password <- readline('- Password: ')
  projectBootstrapEnabled <- readline('- Create project (no): ')
  dictVersion <- readline('- Version of data dictionary (1): ')
  
  if(password == '') {
    message('- Please fill in the password')
  }
  if(hostname == '') hostname == 'http://localhost'
  if(username == '') username <- 'administrator'
  if(dictVersion == '') dictVersion <- '1'
  
  message('------------------------------------------------------')
  message(paste('  Login to: "', hostname, '"', sep = ''))
  cohortHost <- opal.login(username = username, password = password, url = hostname)
  
  lc.dict.download(dictVersion)
  lc.dict.upload(cohortHost, username, dictVersion)

  #message('######################################################')
  #message('  Importing data dictionaries finished                ')
  #message('######################################################')
  
})

lc.dict.download <- function(dictVersion) {
  message('------------------------------------------------------')
  message("  Start download dictionaries")
  downloadBaseDir <- paste('https://github.com/sidohaakma/analysis-protocols/blob/master/R/data/dictionaries/', dictVersion, '/', sep = '')
  
  dict_source_file_non_repeated <- paste(dictVersion, '_non_repeated_measures.xlsx', sep = '')
  dict_source_file_monthly_repeated <- paste(dictVersion, '_monthly_repeated_measures.xlsx', sep = '')
  dict_source_file_yearly_repeated <- paste(dictVersion, '_yearly_repeated_measures.xlsx', sep = '')
  
  message(paste('* Download: ', dict_source_file_non_repeated, sep = ''))
  download.file(paste(downloadBaseDir, dict_source_file_non_repeated, '?raw=true', sep = ''), destfile=dict_source_file_non_repeated, method="libcurl", quiet = TRUE)
  message(paste('* Download: ', dict_source_file_monthly_repeated, sep = ''))
  download.file(paste(downloadBaseDir, dict_source_file_monthly_repeated, '?raw=true', sep = ''), destfile=dict_source_file_monthly_repeated, method="libcurl", quiet = TRUE)
  message(paste('* Download: ', dict_source_file_yearly_repeated, sep = ''))
  download.file(paste(downloadBaseDir, dict_source_file_yearly_repeated, '?raw=true', sep = ''), destfile=dict_source_file_yearly_repeated, method="libcurl", quiet = TRUE)
  
  message("  Succefully downloaded dictionaries")
}

lc.dict.upload <- function(cohortHost, username, dictVersion) {
  message('------------------------------------------------------')
  message('  Start uploading dictionaries')
  uploadDirectory <- paste('/home/',username,sep="")
  
  dict_source_file_non_repeated <- paste(dictVersion, '_non_repeated_measures.xlsx', sep = '')
  dict_source_file_monthly_repeated <- paste(dictVersion, '_monthly_repeated_measures.xlsx', sep = '')
  dict_source_file_yearly_repeated <- paste(dictVersion, '_yearly_repeated_measures.xlsx', sep = '')

  dict_source_yearly_repeated <- paste(getwd(), '/', dict_source_file_yearly_repeated, sep = '')
  dict_source_monthly_repeated <- paste(getwd(), '/', dict_source_file_monthly_repeated, sep = '')
  dict_source_non_repeated <- paste(getwd(), '/', dict_source_file_non_repeated, sep = '')
  
  message(paste('* Upload: ', dict_source_non_repeated, sep = ''))
  opal.file_upload(opal = cohortHost, source = dict_source_non_repeated, destination = uploadDirectory)
  message(paste('* Upload: ', dict_source_file_monthly_repeated, sep = ''))
  opal.file_upload(opal = cohortHost, source = dict_source_monthly_repeated, destination = uploadDirectory)
  message(paste('* Upload: ', dict_source_yearly_repeated, sep = ''))
  opal.file_upload(opal = cohortHost, source = dict_source_yearly_repeated, destination = uploadDirectory)
  
  unlink(dict_source_file_non_repeated)
  unlink(dict_source_file_monthly_repeated)
  unlink(dict_source_file_yearly_repeated)
  
  message('  Succesfully uploaded dictionaries')
}

lc.dict.import <- function() {
  message('------------------------------------------------------')
  message('* Start importing dictionaries')
}