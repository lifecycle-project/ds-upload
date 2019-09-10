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
    if(!(cohort_id %in% lifecycle.globals$cohorts)) {
      stop('Cohort: [ ', cohort_id, ' ] is not know LifeCycle project. Please choose from: [ ', paste(lifecycle.globals$cohorts, collapse = ', '), ' ]')
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
  
  lc.dict.download(dict_version, cohort_id, data_version)
  lc.dict.upload()
  lc.dict.notify(cohort_id, data_version, data_changes)

})

lc.dict.download <- local(function(dict_version, cohort_id, data_version) {
  message('------------------------------------------------------')
  message("  Start download dictionaries")
  download_base_dir <- paste('https://github.com/sidohaakma/analysis-protocols/blob/master/R/data/dictionaries/', dict_version, '/', sep = '')
  
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
  
  message("  Successfully downloaded dictionaries")
})

lc.dict.upload <- local(function() {
  message('------------------------------------------------------')
  message('  Start uploading dictionaries')
  upload_directory <- paste('/home/', lifecycle.globals$username, sep="")
  
  message(paste('* Upload: ', paste(getwd(), '/', lifecycle.globals$dict_dest_file_non_repeated, sep = ''), sep = ''))
  opal.file_upload(opal = lifecycle.globals$opal, source = paste(getwd(), '/', lifecycle.globals$dict_dest_file_non_repeated, sep = ''), destination = upload_directory)
  message(paste('* Upload: ', paste(getwd(), '/', lifecycle.globals$dict_dest_file_monthly_repeated, sep = ''), sep = ''))
  opal.file_upload(opal = lifecycle.globals$opal, source = paste(getwd(), '/', lifecycle.globals$dict_dest_file_monthly_repeated, sep = ''), destination = upload_directory)
  message(paste('* Upload: ', paste(getwd(), '/', lifecycle.globals$dict_dest_file_yearly_repeated, sep = ''), sep = ''))
  opal.file_upload(opal = lifecycle.globals$opal, source = paste(getwd(), '/', lifecycle.globals$dict_dest_file_yearly_repeated, sep = ''), destination = upload_directory)
  
  unlink(lifecycle.globals$dict_dest_file_non_repeated)
  unlink(lifecycle.globals$dict_dest_file_monthly_repeated)
  unlink(lifecycle.globals$dict_dest_file_yearly_repeated)
  
  message('  Succesfully uploaded dictionaries')
})

lc.dict.import <- local(function() {
  message('------------------------------------------------------')
  message('* Start importing dictionaries')
  opal.
  #TODO: implement importing the dictionaries (version 1.0)
})

lc.dict.notify <- local(function(cohort_id, data_version, data_changes) {
  message('------------------------------------------------------')
  message("  Notify LifeCycle project")
  
  sender <- "euchild.lifecycle.project@gmail.com"
  recipients <- c("s.haakma@rug.nl")
  
  emailSubject = paste('New upload for cohort: [ ', cohort_id, ' ] version: [ ', data_version, ' ]', sep = '')
  emailContent = paste('There is a new data upload into Opal for cohort: [ ', cohort_id, ' ]\n',
                        'The new version of the data is: [ ', data_version, ' ] \n',
                        'The changes that are made are: [ ', data_changes, ' ]', sep = '')
  
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
  #    port = 578, 
  #    user.name=sender, 
  #    passwd="?2017LifeCycle!", 
  #    ssl=TRUE),
  #  authenticate = TRUE, 
  #  send = TRUE, 
  #  html = TRUE, 
  #  inline = TRUE)
  
  message("  LifeCycle project notified")
})