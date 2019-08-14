#' Populate your Opal instance with the new version of the data dictionary
#'
#' @import opal
#'
#' @export
lc.populate <- local(function() {
  hostname <- readline('Hostname (http://localhost): ')
  username <- readline('Username (administrator): ')
  password <- readline('Password: ')
  projectBootstrapEnabled <- readline('Create project (no): ')
  dictVersion <- readline('Version of data dictionary (1): ')
  
  if(password == '') {
    message('Please fill in the password')
  }
  if(hostname == '') hostname == 'http://localhost'
  if(username == '') username <- 'administrator'
  if(dictVersion == '') dictVersion <- '1'
  
  downloadBaseDir <- paste('https://github.com/sidohaakma/analysis-protocols/blob/master/R/data/dictionaries/', dictVersion, '/', sep = '')
  https://github.com/sidohaakma/analysis-protocols/blob/master/R/data/dictionaries/1/1_monthly_repeated_measures.xlsx?raw=true
  
  dict_source_file_non_repeated <- paste(dictVersion, '_non_repeated_measures.xlsx', sep = '')
  dict_source_file_monthly_repeated <- paste(dictVersion, '_monthly_repeated_measures.xlsx', sep = '')
  dict_source_file_yearly_repeated <- paste(dictVersion, '_yearly_repeated_measures.xlsx', sep = '')
  
  download.file(paste(downloadBaseDir, dict_source_file_non_repeated, '?raw=true', sep = ''), destfile=dict_source_file_non_repeated, method="libcurl")
  download.file(paste(downloadBaseDir, dict_source_file_monthly_repeated, '?raw=true', sep = ''), destfile=dict_source_file_monthly_repeated, method="libcurl")
  download.file(paste(downloadBaseDir, dict_source_file_yearly_repeated, '?raw=true', sep = ''), destfile=dict_source_file_yearly_repeated, method="libcurl")
  
  uploadDirectory <- paste('/home/',username,sep="")
  dict_source_yearly_repeated <- paste(getwd(), '/', dict_source_file_yearly_repeated, sep = '')
  dict_source_monthly_repeated <- paste(getwd(), '/', dict_source_file_monthly_repeated, sep = '')
  dict_source_non_repeated <- paste(getwd(), '/', dict_source_file_non_repeated, sep = '')
  
  message(paste('Login to: "', hostname, '"', sep = ''))
  cohortHost <- opal.login(username = username, password = password, url = hostname)
  
  message(paste('Upload dictionaries to: "', hostname, '"', sep = ''))
  opal.file_upload(opal = cohortHost, source = dict_source_non_repeated, destination = uploadDirectory)
  opal.file_upload(opal = cohortHost, source = dict_source_monthly_repeated, destination = uploadDirectory)
  opal.file_upload(opal = cohortHost, source = dict_source_yearly_repeated, destination = uploadDirectory)
  
})