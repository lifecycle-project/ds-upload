#' Logout of backend sessions in DataSHIELD
#'
#' Logout of backend sessions in DataSHIELD
#'
#' @importFrom opal datashield
#'
#' @export
lc.logout <- local(function() {
  datashield.logout(servers)
  cat("Successfully logged out of servers")
}