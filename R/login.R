#' Login into the opal instance and
#'
#' @param hostname specify hostname of Opal instance
#' @param username specify username (of administrator) of Opal instance (default = administrator)
#' @param password specify password (of administrator) of Opal instance
#' @param insecure NOT RECOMMENDED, use an insecure SSL connection
#'
#' @importFrom opalr opal.login
#'
#' @examples
#' \dontrun{
#' du.login(
#'   hostname = "https://cohort-datashield-server.org",
#'   username = "local_dm",
#'   password = "very-secret-pw"
#' )
#' }
#'
#' @export
du.login <- local(function(hostname, username = "administrator", password, insecure = FALSE) {
  if (missing(hostname)) {
    hostname <- readline("- Hostname (e.g. https://my-own-opal.org): ")
    username <- readline("- Username: ")
  }
  if (missing(password)) {
    password <- readline("- Password: ")
  }

  du.check.package.version()

  ds_upload.globals$hostname <- hostname
  ds_upload.globals$username <- username
  ds_upload.globals$password <- password

  options <- list()

  if (insecure) {
    options <- list(ssl.verifyhost = FALSE, ssl.verifypeer = FALSE)
  }

  message(paste("  Login to: \"", ds_upload.globals$hostname, "\"", sep = ""))
  ds_upload.globals$opal <- opal.login(
    username = ds_upload.globals$username, password = ds_upload.globals$password,
    url = ds_upload.globals$hostname, opts = options
  )
  message(paste("  Logged on to: \"", ds_upload.globals$hostname, "\"", sep = ""))
})
