# Use environment to store some path variables to use in different functions
lifecycleProject.globals <- new.env()

#' Populate your Opal instance with the new version of the data dictionary
#'
#' @param hostname specify hostname of Opal instance
#' @param username specify username (of administrator) of Opal instance
#' @param password specify password (of administrator) of Opal instance
#' @param createProject create the 'lifecycle'-project in Opal instance
#' @param dictVersion dictionary version (data scheme version)
#' @param cohortId cohort identifier (based upon identifiers in catalogue)
#' @param dataVersion version of the data (specific to the cohort)
#'
#' @import opal
#'
#' @export
lc.populate <- function(hostname, username, password, createProject, dictVersion, cohortId, dataVersion, dataChanges) {
  message('######################################################')
  message('  Start importing data dictionaries                   ')
  message('######################################################')
  
  if (missing(hostname)) hostname <- readline('- Hostname (http://localhost): ')
  if (missing(username)) username <- readline('- Username (administrator): ')
  if (missing(password)) password <- readline('- Password: ')
  if (missing(createProject)) createProject <- readline('- Create project (default == no): ')
  if (missing(dictVersion)) dictVersion <- readline('- Specify version of data dictionary (default == 1_0): ')
  if (missing(cohortId)) cohortId <- readline('- Specify cohort identifier (e.g. dnbc): ')
  if (missing(dataVersion)) dataVersion <- readline('- Specify version of cohort data upload (e.g. 1_0): ')
  if (missing(dataChanges)) dataChanges <- readline('- Specify changes in data upload version (e.g. "new participants added": ')
  
  if (hostname == '') hostname <- 'http://localhost'
  if (username == '') username <- 'administrator'
  if (dictVersion == '') dictVersion <- '1_0'
  
  if(cohortId == '') {
    stop("No cohort identifier is specified! Program is terminated.", call. = FALSE)
  }
  
  if(dataVersion == '') {
    stop("No data version is specified! Program is terminated.", call. = FALSE)
  }
  
  if(dataChanges == '') {
    stop("No changes in data are specified! Program is terminated.", call. = FALSE)
  }
  
  message('------------------------------------------------------')
  message(paste('  Login to: "', hostname, '"', sep = ''))
  cohortHost <- opal.login(username = username, password = password, url = hostname)
  
  lc.dict.download(dictVersion, cohortId, dataVersion)
  lc.dict.upload(cohortHost, username)
  lc.dict.notify(cohortId, dataVersion, dataChanges)

}

lc.dict.download <- local(function(dictVersion, cohortId, dataVersion) {
  message('------------------------------------------------------')
  message("  Start download dictionaries")
  downloadBaseDir <- paste('https://github.com/sidohaakma/analysis-protocols/blob/master/R/data/dictionaries/', dictVersion, '/', sep = '')
  
  dict_source_file_non_repeated <- paste(dictVersion, '_non_repeated_measures.xlsx', sep = '')
  dict_source_file_monthly_repeated <- paste(dictVersion, '_monthly_repeated_measures.xlsx', sep = '')
  dict_source_file_yearly_repeated <- paste(dictVersion, '_yearly_repeated_measures.xlsx', sep = '')
  
  lifecycleProject.globals$dict_dest_file_non_repeated <- paste(dictVersion, '_', cohortId, '_', dataVersion, '_non_repeated_measures.xlsx', sep = '')
  lifecycleProject.globals$dict_dest_file_monthly_repeated <- paste(dictVersion, '_', cohortId, '_', dataVersion,'_monthly_repeated_measures.xlsx', sep = '')
  lifecycleProject.globals$dict_dest_file_yearly_repeated <- paste(dictVersion, '_', cohortId, '_', dataVersion, '_yearly_repeated_measures.xlsx', sep = '')
  
  message(paste('* Download: ', dict_source_file_non_repeated, sep = ''))
  download.file(paste(downloadBaseDir, dict_source_file_non_repeated, '?raw=true', sep = ''), destfile=lifecycleProject.globals$dict_dest_file_non_repeated, method="libcurl", quiet = TRUE)
  message(paste('* Download: ', dict_source_file_monthly_repeated, sep = ''))
  download.file(paste(downloadBaseDir, dict_source_file_monthly_repeated, '?raw=true', sep = ''), destfile=lifecycleProject.globals$dict_dest_file_monthly_repeated, method="libcurl", quiet = TRUE)
  message(paste('* Download: ', dict_source_file_yearly_repeated, sep = ''))
  download.file(paste(downloadBaseDir, dict_source_file_yearly_repeated, '?raw=true', sep = ''), destfile=lifecycleProject.globals$dict_dest_file_yearly_repeated, method="libcurl", quiet = TRUE)
  
  message("  Successfully downloaded dictionaries")
}

lc.dict.upload <- function(cohortHost, username) {
  message('------------------------------------------------------')
  message('  Start uploading dictionaries')
  uploadDirectory <- paste('/home/',username,sep="")
  
  message(paste('* Upload: ', paste(getwd(), '/', lifecycleProject.globals$dict_dest_file_non_repeated, sep = ''), sep = ''))
  opal.file_upload(opal = cohortHost, source = paste(getwd(), '/', lifecycleProject.globals$dict_dest_file_non_repeated, sep = ''), destination = uploadDirectory)
  message(paste('* Upload: ', paste(getwd(), '/', lifecycleProject.globals$dict_dest_file_monthly_repeated, sep = ''), sep = ''))
  opal.file_upload(opal = cohortHost, source = paste(getwd(), '/', lifecycleProject.globals$dict_dest_file_monthly_repeated, sep = ''), destination = uploadDirectory)
  message(paste('* Upload: ', paste(getwd(), '/', lifecycleProject.globals$dict_dest_file_yearly_repeated, sep = ''), sep = ''))
  opal.file_upload(opal = cohortHost, source = paste(getwd(), '/', lifecycleProject.globals$dict_dest_file_yearly_repeated, sep = ''), destination = uploadDirectory)
  
  unlink(lifecycleProject.globals$dict_dest_file_non_repeated)
  unlink(lifecycleProject.globals$dict_dest_file_monthly_repeated)
  unlink(lifecycleProject.globals$dict_dest_file_yearly_repeated)
  
  message('  Succesfully uploaded dictionaries')
})

lc.dict.import <- local(function() {
  message('------------------------------------------------------')
  message('* Start importing dictionaries')
  #TODO: implement importing the dictionaries (version 1.0)
})

lc.dict.notify <- local(function(cohortId, dataVersion, dataChanges) {
  sender <- "lifecycleProject@gmail.com"
  recipients <- c("s.haakma@rug.nl")
  
  emailSubject = paste('New upload for cohort: [ ', cohortId, ' ] version: [ ', dataVersion, ' ]', sep = '')
  emailContent = paste('There is a new data upload into Opal for cohort: [ ', cohortId, ' ]\n',
                        'The new version of the data is: [ ', dataVersion, ' ] \n',
                        'The changes that are made are: [ ', dataChanges, ' ]', sep = '')
  
  #send.mail(
  #  from = sender, 
  #  to = recipients, 
  # subject = emailSubject,
  #  Sys.Date(),
  #  "{}", 
  #  body = emailContent, 
  #  encoding = "utf-8", 
  #  smtp = list(
  #    host.name = "smtp.gmail.com", 
  #    port = 465, 
  #    user.name=sender, 
  #    passwd="djkacLKaa", 
  #    ssl=TRUE),
  #  authenticate = TRUE, 
  #  send = TRUE, 
  #  html = TRUE, 
  #  inline = TRUE)
  
  message('------------------------------------------------------')
  message("  Notify LifeCycle project")
  message("")
  message("  Example email message")
  message(paste(emailSubject , '\n\n', emailContent, sep = ''))
  message("")
  message("  LifeCycle project notified")
})