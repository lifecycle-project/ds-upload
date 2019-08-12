
# Create a LifeCycle environment
lc.env <- new.env()

local({
  lc.cohorts <- c("elfe", "dnbc")
  lc.urls <- c("https://opal1.domain.org", "https://opal2.domain.org")
  lc.usernames <- c("usr1", "usr2")
  lc.passwords <- c("pw1", "pw2")
  lc.tables <- c("Project1.table1", "Project2.table2")
}, lc.env)

#' Login to a number of cohorts via DataSHIELD
#'
#' Login to a number of cohorts through DataSHIELD
#'
#' @param cohorts list of cohorts that you want to login to
#' @param username your username
#' @param password your password
#'
#' @return opals list of logged in cophorts
#'
#' @importFrom opal datashield
#'
#' @export
lc.login <- local(function(cohorts, table, username, password) {
  login-data <- data.frame(lc.cohorts,lc.urls,lc.usernames,lc.passwords,lc.tables)
  servers <- datashield.login(logins=login-data,assign=TRUE)

  return servers
}
