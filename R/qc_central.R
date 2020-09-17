#' Check all versions of the servers
#'
#' @importFrom httr GET
#'
#' @keywords internal
du.quality.central.servers.version <- function() {
  for (cohort_url in ds_upload.globals$cohorts) {
    if (cohort_url != "") {
      response <- GET(paste(cohort_url, "/ws/system/version", sep = ""))
      print(response)
    }
  }
}
