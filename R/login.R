ds_upload.globals <- new.env()

#' Login into the DataSHIELD backend
#'
#' @param login_data login data frame containing the server url
#'
#' @importFrom opalr opal.login
#'
#' @examples
#' \dontrun{
#' 
#' login_data <- data.frame(
#'   server = "https://armadillo.dev.molgenis.org"
#'   storage = "https://armadillo-minio.dev.molgenis.org"
#'   username = "admin"
#'   password = "admin"
#'   insecure = FALSE
#'   options = NULL
#' )
#' 
#' du.login(login_data)
#' }
#'
#' @export
du.login <- function(login_data) {
  
  if (missing(login_data$server)) {
    hostname <- readline("- Hostname (e.g. https://my-own-datashield-backend.org): ")
    username <- readline("- Username: ")
  }
  if (missing(password)) {
    password <- readline("- Password: ")
  }

  du.check.package.version()
  
  if(missing(login_data$driver)) {
    login_data$driver = du.enum.backends()$OPAL
  }
  
  if (login_data$insecure) {
    login_data$options <- list(ssl.verifyhost = FALSE, ssl.verifypeer = FALSE)
  }
  
  message(paste("  Login to: \"", login_data$server, "\"", sep = ""))
  if(login_data$driver == du.enum.backends()$OPAL) {
    ds_upload.globals$conn <- du.opal.login(login_data)
  } else {
    du.armadillo.login(login_data)
  }
  message(paste("  Logged on to: \"", login_data$server, "\"", sep = ""))
  
  ds_upload.globals$login_data <- login_data
}

#'
#' Check the package version
#'
#' @importFrom jsonlite fromJSON
#' @importFrom utils packageVersion packageName
#'
#' @keywords internal
du.check.package.version <- function() {
  url <- paste0("https://registry.molgenis.org/service/rest/v1/search?repository=r-hosted&name=", packageName())
  result <- fromJSON(txt = url)
  currentVersion <- packageVersion(packageName())
  if (any(result$items$version > currentVersion)) {
    message(paste0("***********************************************************************************"))
    message(paste0("  [WARNING] You are not running the latest version of the ", packageName(), "-package."))
    message(paste0(
      "  [WARNING] If you want to upgrade to newest version : [ ", max(result$items$version),
      " ],"
    ))
    message(paste0("  [WARNING] Please run 'install.packages(\"", packageName(), "\", repos = \"https://registry.molgenis.org/repository/R/\")'"))
    message(paste0(
      "  [WARNING] Check the release notes here: https://github.com/lifecycle-project/analysis-protocols/releases/tag/",
      max(result$items$version)
    ))
    message(paste0("***********************************************************************************"))
  }
}

#' Check if there is an active session with a DataSHIELD backend
#'
#' @param upload is a session needed or not
#'
#' @keywords internal
du.check.session <- function(upload = FALSE) {
  if (upload == TRUE) {
    if (!exists("login_data", envir = ds_upload.globals)) {
      stop("You need to login first, please run du.login")
    }
  }
}
