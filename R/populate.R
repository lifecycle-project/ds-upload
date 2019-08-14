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
  uploadDirectory <- paste('/home/',username,sep="")
  
  dict_source_yearly_repeated <- paste('dictionaries/', dictVersion, '/', dictVersion, '_monthly_repeated_measures.xlsx', sep = "")
  dict_source_monthly_repeated <- paste('dictionaries/', dictVersion, '/', dictVersion, '_yearly_repeated_measures.xlsx', sep = "")
  dict_source_non_repeated <- paste('dictionaries/',dictVersion, '/', dictVersion, '_non_repeated_measures.xlsx', sep = "")
  
  message(paste('Login to: "', hostname, '"'))
  cohortHost <- opal.login(username = username, password = password, url = hostname)
  
  message(paste('Upload dictionaries to: "', hostname, '"'))
  opal.file_upload(opal = cohortHost, source = dict_source_non_repeated, destination = uploadDirectory)
  opal.file_upload(opal = cohortHost, source = dict_source_monthly_repeated, destination = uploadDirectory)
  opal.file_upload(opal = cohortHost, source = dict_source_yearly_repeated, destination = uploadDirectory)
  
})