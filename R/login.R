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
#'   server = "https://armadillo.dev.molgenis.org",
#'   username = "admin",
#'   password = "admin",
#'   insecure = FALSE,
#'   options = NULL
#' )
#'
#' du.login(login_data)
#' }
#' @export
du.login <- function(login_data) {
  if (is.null(login_data$server)) {
    login_data$server <- readline("- Hostname (e.g. https://my-own-datashield-backend.org): ")
    login_data$username <- readline("- Username: ")
  }

  if (is.null(login_data$driver)) {
    backend <- readline("- Which server are you logging on to (opal/armadillo): ")
    if (backend == "opal") {
      login_data$driver <- du.enum.backends()$OPAL
    } else {
      login_data$driver <- du.enum.backends()$ARMADILLO
    }
  }

  if (is.null(login_data$username) & login_data$driver == du.enum.backends()$OPAL) {
    login_data$username <- "administrator"
  }

  if (is.null(login_data$password) & !is.null(login_data$username)) {
    password <- readline("- Password: ")
  }

  if (is.null(login_data$insecure)) {
    login_data$options <- data.frame(ssl.verifyhost = FALSE, ssl.verifypeer = FALSE)
  }

  message(paste("  Login to: \"", login_data$server, "\"", sep = ""))
  if (login_data$driver == du.enum.backends()$OPAL) {
    ds_upload.globals$conn <- du.opal.login(login_data)
  } else {
    token <- du.armadillo.login(login_data)
    login_data$token <- token
  }
  message(paste("  Logged on to: \"", login_data$server, "\"", sep = ""))

  ds_upload.globals$login_data <- login_data
}

#' Check if there is an active session with a DataSHIELD backend
#'
#' @param upload is a session needed or not
#'
#' @noRd
du.check.session <- function(upload = FALSE) {
  if (upload == TRUE) {
    if (!exists("login_data", envir = ds_upload.globals)) {
      stop("You need to login first, please run du.login")
    }
  }
}
