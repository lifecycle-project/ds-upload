#' Validates the variables for a certain table
#'
#' @importFrom DSI datashield.login newDSLoginBuilder datashield.assign.table
#' @importFrom opalr opal.projects opal.tables
#'
#' @export
du.quality.control <- function() {
  projects <- opal.projects(ds_upload.globals$opal)

  projects$name %>%
    as.character() %>%
    map(function(project) {
      tables <- opal.tables(ds_upload.globals$opal, project)
      tables$name %>%
        as.character() %>%
        map(function(table) {
          builder <- newDSLoginBuilder()
          builder$append(
            server = "validate", url = ds_upload.globals$hostname,
            user = ds_upload.globals$username, password = ds_upload.globals$password,
            driver = "OpalDriver"
          )
          logindata <- builder$build()

          connections <- datashield.login(logins = logindata, assign = FALSE)

          table_identifier <- paste0(project, ".", table)
          datashield.assign.table(conns = connections, table = table_identifier, symbol = table)

          if (grepl(du.enum.table.types()$NONREP, table)) {
            qc.non.repeated(connections, table)
          }
        })
    })
}

#' Check non repeated measures
#'
#' @importFrom dsBaseClient ds.ls ds.colnames
#' @importFrom dsHelper dh.getStats
#'
#' @keywords internal
qc.non.repeated <- function(connections, table) {
  ds.ls(datasources = connections)

  vars <- ds.colnames(datasources = connections, x = table)

  print(vars)

  table_1 <- dh.getStats(
    df = table,
    vars = vars
  )

  print(table_1)
}
