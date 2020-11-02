#' Validates the variables for a certain table
#'
#' @param project specify project you want to perform quality control on
#' @param verbose ouput the functions output when set to TRUE
#'
#' @importFrom DSI datashield.login newDSLoginBuilder datashield.assign.table
#' @importFrom opalr opal.projects opal.tables
#' @importFrom dplyr %>%
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

          qc_dataframe_symbol <- "qc"
          
          datashield.assign.table(conns = conns, table = table_identifier, symbol = qc_dataframe_symbol)

          if (grepl(du.enum.table.types()$NONREP, table)) {
            qc.non.repeated(conns, qc_dataframe_symbol, verbose)
          }
          if (grepl(du.enum.table.types()$YEARLY, table)) {
            qc.yearly.repeated(conns, qc_dataframe_symbol, verbose)
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
  
  jsonResult = toJSON(result)
  
  if (verbose) {
    print(result)
    print(jsonResult)
  }
}

#' Quality control for yearly repeated measures
#' 
#' @param conns connection object for DataSHIELD backends
#' @param table table to perform quality control on
#' @param verbose print output to screen
#'
#' @importFrom dsBaseClient ds.colnames ds.class ds.meanSdGp ds.table
#' @importFrom dplyr all_of %>%
#' @importFrom purrr map
#'
#' @keywords internal
qc.yearly.repeated <- function(conns, table, verbose) {
  type <- pivot_longer <- NULL
  
  vars <- ds.colnames(table, datasources = conns)
  # make it a flat list 
  plain_vars <- as.vector(unlist(vars, use.names=FALSE))
  # exclude variables not required:
  plain_vars <- plain_vars[!plain_vars %in% c("child_id", "age_years")]
  
  
  message("Construct dataframe")
  types_table = data.frame(cbind("type"))
  
  plain_vars %>%
    map(function(variable) {
      message(paste0(variable," start"))
      type_vect = ds.class(paste0(table,'$',variable))
      types_table = cbind(types_table,unlist(type_vect))
      message(paste0(variable," end"))  
    })
  
  types_table = types_table[,-1]
  colnames(types_table) = plain_vars
  
  types_table <- types_table %>%
    pivot_longer(
      cols = all_of(plain_vars),
      names_to = "variable",
      values_to = "type",
      values_drop_na = TRUE
    )
  
  message("select factor and produce output")
  factors <- types_table %>%
    filter(type == 'factor')
  factors <- list(factors$variable)
  
  factors %>%
    map(function(factor) {
      message(paste0(factor," start"))
      table_output = ds.table(paste0(table,'$',factor), paste0(table,'$',"age_years"))
      if (verbose) {
      print(table_output)
      }
      message(paste0(factor," end"))
    })
  
  message("select integer and produce output")
  
  integers <- types_table %>%
    filter(type == 'integer')
  integers <- list(integers$variable)
  
  integers %>%
    map(function(integer) {
      message(paste0(integer," start"))
      means <- ds.meanSdGp(
        x = paste0(table,'$',integer),
        y = paste0(table,"$age_years"),
        type = "split",
        do.checks = FALSE,
        datasources = conns
      )
      if (verbose) {
        print(means)
      }
      message(paste0(integer," end"))
    })
  
}
