#' Logout of backend sessions in DataSHIELD
#'
#' @importFrom opal datashield.logout
#'
#' @export
lc.logout <- local(function() {
  datashield.logout(servers)
  cat("Successfully logged out of servers")
})