#' Login into the opal instance and
#'
#' @param hostname specify hostname of Opal instance
#' @param username specify username (of administrator) of Opal instance (default = administrator)
#' @param password specify password (of administrator) of Opal instance
#'
#' @importFrom opalr opal.login
#'
#' @export
lc.login <-
  local(function(hostname, username = 'administrator', password) {
    if (missing(hostname)) {
      hostname <- readline('- Hostname (e.g. https://my-own-opal.org): ')
      username <- readline('- Username: ')
    }
    if (missing(password))
      password <- readline('- Password: ')
    
    checkPackageVersion()
    
    lifecycle.globals$hostname <- hostname
    lifecycle.globals$username <- username
    lifecycle.globals$password <- password
    
    message(paste('  Login to: "', lifecycle.globals$hostname, '"', sep = ''))
    lifecycle.globals$opal <-
      opal.login(
        username = lifecycle.globals$username,
        password = lifecycle.globals$password,
        url = lifecycle.globals$hostname
      )
    message(paste('  Logged on to: "', lifecycle.globals$hostname, '"', sep = ''))
  })