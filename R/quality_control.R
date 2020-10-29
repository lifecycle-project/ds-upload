#' Validates the variables for a certain table
#'
#' @param project specify project you want to perform quality control on
#' @param verbose ouput the functions output when set to TRUE
#'
#' @importFrom DSI datashield.login newDSLoginBuilder datashield.assign.table
#' @importFrom opalr opal.projects opal.tables
#'
#' @export
du.quality.control <- function(project, verbose = FALSE) {
  message("  Starting quality control")
  message("------------------------------------------------------")
  if (!missing(project)) {
    projects <- data.frame(name = project)
  } else {
    projects <- opal.projects(ds_upload.globals$opal)
  }

  projects$name %>%
    as.character() %>%
    map(function(project) {
      tables <- opal.tables(ds_upload.globals$opal, project)
      tables$name %>%
        as.character() %>%
        map(function(table) {
          message(paste0(" * Starting with: ", project, " - ", table))

          builder <- newDSLoginBuilder()
          builder$append(
            server = "validate", url = ds_upload.globals$hostname,
            user = ds_upload.globals$username, password = ds_upload.globals$password,
            driver = "OpalDriver"
          )
          logindata <- builder$build()

          conns <- datashield.login(logins = logindata, assign = FALSE)

          table_identifier <- paste0(project, ".", table)


          datashield.assign.table(conns = conns, table = table_identifier, symbol = "D")

          if (grepl(du.enum.table.types()$NONREP, table)) {
            qc.non.repeated(conns, "D", verbose)
          }
        })
    })

  message("######################################################")
  message("  Quality control has finished                        ")
  message("######################################################")

  upload_summaries <- readline(" * Upload results to the catalogue? (yes/no): ")
  if (upload_summaries == "yes") {
    message("------------------------------------------------------")
    message("  Starting to upload the results to the catalogue")
    message("  Uploaded results succesfully")
    message("------------------------------------------------------")
  }
}

#' Check non repeated measures
#' 
#' @param conns connections object for DataSHIELD backend
#' @param table to quality check
#' @param verbose print verbose output 
#'
#' @importFrom dsBaseClient ds.ls ds.colnames
#' @importFrom dsHelper dh.getStats
#'
#' @keywords internal
qc.non.repeated <- function(conns, table, verbose) {
  vars <- ds.colnames(datasources = conns, x = table)

  # make it a plain old vector
  plain_vars <- as.vector(unlist(vars, use.names = FALSE))

  # strip unnecessary fields
  plain_vars <- plain_vars[!plain_vars %in% c("child_id")]

  result <- dh.getStats(
    conns = conns,
    df = table,
    vars = plain_vars
  )

  if(verbose) {
    print(result)
  }
}
