# Use environment to store some path variables to use in different functions
lifecycle.globals <- new.env()

#' Login into the opal instance and 
#' 
#' @param hostname specify hostname of Opal instance
#' @param username specify username (of administrator) of Opal instance
#' @param password specify password (of administrator) of Opal instance
#' 
#' @export
#' 
lc.login <- function(hostname, username, password) {
  if(missing(hostname)) hostname <- readline('- Hostname (http://localhost): ')
  if(missing(username)) username <- readline('- Username (administrator): ')
  if(missing(password)) password <- readline('- Password: ')
  
  lifecycle.globals$hostname <- hostname
  lifecycle.globals$username <- username
  lifecycle.globals$password <- password
  
  message('######################################################')
  message(paste('  Login to: "', lifecycle.globals$hostname, '"', sep = ''))
  lifecycle.globals$opal <- opal.login(username = lifecycle.globals$username, password = lifecycle.globals$password, url = lifecycle.globals$hostname)
  message(paste('  Logged on to: "', lifecycle.globals$hostname, '"', sep = ''))
  message('######################################################')
}