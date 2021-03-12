#' Validates the variables for a certain table
#'
#' @param project specify project you want to perform quality control on
#' @param verbose output the functions output when set to TRUE
#' @param limit limit the tables to run (can be non_rep, yearly_rep, monthly_rep, weekly_rep or trimester)
#'
#' @importFrom opalr opal.projects opal.tables
#' @importFrom MolgenisArmadillo armadillo.list_projects armadillo.list_tables
#' @importFrom dplyr %>%
#'
#' @export
du.quality.control <- function(project, verbose = FALSE, limit = du.enum.table.types()$ALL) {
  requireNamespace("dsBaseClient")
  message("  Starting quality control")
  message("------------------------------------------------------")
  du.check.session(TRUE)
  builder <- DSI::newDSLoginBuilder()
  if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL) {
    requireNamespace("DSOpal")
    projects <- opal.projects(ds_upload.globals$conn)
    builder$append(
      server = "validate",
      url = as.character(ds_upload.globals$login_data$server),
      driver = as.character(ds_upload.globals$login_data$driver),
      user = as.character(ds_upload.globals$login_data$username),
      password = as.character(ds_upload.globals$login_data$password)
    )
  } else {
    projects <- du.armadillo.list.projects()
    builder$append(
      server = "validate",
      url = as.character(ds_upload.globals$login_data$server),
      driver = as.character(ds_upload.globals$login_data$driver),
      token = as.character(ds_upload.globals$login_data$token)
    )
  }

  if (!missing(project)) {
    projects <- data.frame(name = project)
  }

  projects$name %>%
    as.character() %>%
    map(function(project) {
      if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL) {
        tables <- opal.tables(ds_upload.globals$conn, project)
        tables <- tables$name
      }
      if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
        tables <- du.armadillo.list.tables(project)
      }

      tables %>%
        as.character() %>%
        map(function(table) {
          qc_dataframe_symbol <- "QC"

          tables_to_assign <- paste0(project, ".", table)

          if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
            tables_to_assign <- paste0(project, "/", table)
          }

          if (grepl(du.enum.table.types()$NONREP, table) && (limit == du.enum.table.types()$NONREP | limit == du.enum.table.types()$ALL)) {
            message(paste0(" * Starting with: ", project, " - ", table))
            conns <- DSI::datashield.login(logins = builder$build(), assign = FALSE)
            DSI::datashield.assign.table(conns = conns, table = tables_to_assign, symbol = qc_dataframe_symbol)
            qc.non.repeated(conns, qc_dataframe_symbol, verbose)
            DSI::datashield.logout(conns)
          } else if(grepl(du.enum.table.types()$YEARLY, table) && (limit == du.enum.table.types()$YEARLY | limit == du.enum.table.types()$ALL)) {
            message(paste0(" * Starting with: ", project, " - ", table))
            conns <- DSI::datashield.login(logins = builder$build(), assign = FALSE)
            DSI::datashield.assign.table(conns = conns, table = tables_to_assign, symbol = qc_dataframe_symbol)
            qc.yearly.repeated(conns, qc_dataframe_symbol, verbose)
            DSI::datashield.logout(conns)
          } else if (grepl(du.enum.table.types()$MONTHLY, table) && (limit == du.enum.table.types()$MONTHLY | limit == du.enum.table.types()$ALL)) {
            message(paste0(" * Starting with: ", project, " - ", table))
            conns <- DSI::datashield.login(logins = builder$build(), assign = FALSE)
            DSI::datashield.assign.table(conns = conns, table = tables_to_assign, symbol = qc_dataframe_symbol)
            qc.monthly.repeated(conns, qc_dataframe_symbol, verbose)
            DSI::datashield.logout(conns)
          } else if (grepl(du.enum.table.types()$TRIMESTER, table) && (limit == du.enum.table.types()$TRIMESTER | limit == du.enum.table.types()$ALL)) {
            message(paste0(" * Starting with: ", project, " - ", table))
            conns <- DSI::datashield.login(logins = builder$build(), assign = FALSE)
            DSI::datashield.assign.table(conns = conns, table = tables_to_assign, symbol = qc_dataframe_symbol)
            qc.trimester(conns, qc_dataframe_symbol, verbose)
            DSI::datashield.logout(conns)
          } else {
            message(paste0(" * Skipping: ", project, " - ", table))
            return()
          }
        })
    })

  message("######################################################")
  message("  Quality control has finished                        ")
  message("######################################################")
}

#' Check non repeated measures
#'
#' @param conns connections object for DataSHIELD backend
#' @param table to quality check
#' @param verbose print verbose output
#'
#' @importFrom jsonlite toJSON
#'
#' @noRd
qc.non.repeated <- function(conns, table, verbose) {
  requireNamespace("dsHelper")
  vars <- dsBaseClient::ds.colnames(datasources = conns, x = table)

  # make it a plain old vector
  plain_vars <- as.vector(unlist(vars, use.names = FALSE))

  # strip unnecessary fields
  plain_vars <- plain_vars[!plain_vars %in% c("row_id", "child_id")]
  
  outputNonRep <- dsHelper::dh.getStats(
    conns = conns,
    df = table,
    vars = plain_vars
  )

  jsonOutputNonRep <- toJSON(outputNonRep)

  if (verbose) {
    print(jsonOutputNonRep)
  }
}

#' Quality control for yearly repeated measures
#'
#' @param conns connection object for DataSHIELD backends
#' @param table table to perform quality control on
#' @param verbose print output to screen
#'
#' @importFrom dplyr all_of %>%
#' @importFrom purrr map
#'
#' @noRd
qc.yearly.repeated <- function(conns, table, verbose) {
  requireNamespace("dsBaseClient")
  type <- NULL
  
  # Define dataframe and variables:
  vars <- dsBaseClient::ds.colnames(table, datasources = conns)

  # make it a flat list
  vars <- as.vector(unlist(vars, use.names = FALSE))
  # exclude variables not required:
  vars <- vars[!vars %in% c("child_id", "age_years")]

  ## Create vector of full names for datashield
  full_var_names <- paste0(table, "$", vars)

  class_list <- full_var_names %>% map(function(x) {
    dsBaseClient::ds.class(x, datasources = conns)
  })
  
  
  f <- class_list %>% map(function(x) {
    any(str_detect(x, "factor") == TRUE)
  })
  i <- class_list %>% map(function(x) {
    any(str_detect(x, "numeric|integer") == TRUE)
  })
  
  ## Create separate vectors for factors and integers
  factors <- vars[(which(f == TRUE))]
  integers <- vars[(which(i == TRUE))]

  # Convert age_years to a factor variable (required for the table):
  dsBaseClient::ds.asFactor(
    input.var.name = paste0(table, "$age_years"),
    newobj.name = "age_years2",
    datasources = conns
  )
  dsBaseClient::ds.cbind(x = c(table, "age_years2"), newobj = table, datasources = conns)
  # Store some summary information:
  summary <- dsBaseClient::ds.levels(paste0(table, "$age_years2"), datasources = conns)
  levels <- summary$validate$Levels

  outputFactVars <- factors %>%
    map(function(factVar) { 
      summaryVar <- dsBaseClient::ds.summary(paste0(table, "$", factVar), datasources = conns)
      qc.process.factor.vars(factVar, table, levels, summaryVar$validate$categories, "age_years2", conns) }) %>%
    rbind() %>%
    toJSON()
  
  outputIntVars <- integers %>% 
    map(function(intVar) { qc.process.integer.vars(intVar, table, levels, conns) }) %>%
    rbind()
  
  if (verbose) {
    print(outputIntVars[[1]])
    print(outputFactVars[[1]])
  }
}

#' Quality control for monthly repeated measures
#'
#' @param conns connection object for DataSHIELD backends
#' @param table table to perform quality control on
#' @param verbose print output to screen
#'
#' @importFrom dplyr all_of %>%
#' @importFrom purrr map
#'
#' @noRd
qc.monthly.repeated <- function(conns, table, verbose) {
  requireNamespace("dsBaseClient")
  vars <- dsBaseClient::ds.colnames(table, datasources = conns)
  # make it a flat list
  vars <- as.vector(unlist(vars, use.names = FALSE))
  # exclude variables not required:
  vars <- vars[!vars %in% c("row_id", "child_id", "age_months", "age_years", "height_age", "weight_age")]

  ## Create vector of full names for datashield
  full_var_names <- paste0(table, "$", vars)

  class_list <- full_var_names %>% map(function(x) {
    dsBaseClient::ds.class(x, datasources = conns)
  })

  f <- class_list %>% map(function(x) {
    any(str_detect(x, "factor") == TRUE)
  })
  i <- class_list %>% map(function(x) {
    any(str_detect(x, "numeric|integer") == TRUE)
  })

  ## Create separate vectors for factors and integers
  factors <- vars[(which(f == TRUE))]
  integers <- vars[(which(i == TRUE))]

  ################################################################################
  # Convert age_months to a factor variable:
  dsBaseClient::ds.asFactor(
    input.var.name = paste0(table, "$age_months"),
    newobj.name = "age_months2",
    datasources = conns
  )
  dsBaseClient::ds.cbind(x = c(table, "age_months2"), newobj = table, datasources = conns)

  summary1 <- dsBaseClient::ds.levels(paste0(table, "$age_months2"), datasources = conns)
  n1 <- length(summary1$validate$Levels) 

  # Convert age_years to a factor variable (required for the tables):
  dsBaseClient::ds.asFactor(
    input.var.name = paste0(table, "$age_years"),
    newobj.name = "age_years2",
    datasources = conns
  )
  dsBaseClient::ds.cbind(x = c(table, "age_years2"), newobj = table, datasources = conns)

  # summarise some information from age_years2
  
  summary <- dsBaseClient::ds.levels(paste0(table, "$age_years2"), datasources = conns)
  levels <- summary$validate$Levels
  
  outputIntVars <- integers %>% 
    map(function(intVar) { qc.process.integer.vars(intVar, table, levels, conns) }) %>%
    rbind()
  
  if(verbose) {
    print(outputIntVars)  
  }
}

#' Quality control for trimester measures
#'
#' @param conns connection object for DataSHIELD backends
#' @param table table to perform quality control on
#' @param verbose print output to screen
#'
#' @importFrom dplyr all_of %>%
#' @importFrom purrr map
#'
#' @noRd
qc.trimester <- function(conns, table, verbose) {
  requireNamespace("dsBaseClient")
  vars <- dsBaseClient::ds.colnames(table, datasources = conns)
  # make it a flat list
  vars <- as.vector(unlist(vars, use.names = FALSE))
  # exclude variables not required:
  vars <- vars[!vars %in% c("row_id", "child_id", "age_trimester")]

  ## Create vector of full names for datashield
  full_var_names <- paste0(table, "$", vars)

  class_list <- full_var_names %>% map(function(x) {
    dsBaseClient::ds.class(x, datasources = conns)
  })

  f <- class_list %>% map(function(x) {
    any(str_detect(x, "factor") == TRUE)
  })
  i <- class_list %>% map(function(x) {
    any(str_detect(x, "numeric|integer") == TRUE)
  })

  ## Create separate vectors for factors and integers
  factors <- vars[(which(f == TRUE))]
  integers <- vars[(which(i == TRUE))]

  ################################################################################
  # Create separate data frames for each variable in "factors" with summary information (N and proportions)

  # Convert age_trimester to a factor variable (required for the table):
  dsBaseClient::ds.asFactor(
    input.var.name = paste0(table, "$age_trimester"),
    newobj.name = "age_trimester2",
    datasources = conns
  )
  dsBaseClient::ds.cbind(x = c(table, "age_trimester2"), newobj = table, datasources = conns)
  # Store some summary information:
  summary <- dsBaseClient::ds.levels(paste0(table, "$age_trimester2"))
  levels <- summary$validate$Levels

  outputFactVars <- factors %>%
    map(function(factVar) { 
      summaryVar <- dsBaseClient::ds.levels(paste0(table, "$", factVar), datasources = conns)
      qc.process.factor.vars(factVar, table, levels, summaryVar$validate$Levels, "age_trimester2", conns) 
      }) %>%
    cbind()
    
  if(verbose) {
    print(outputFactVars)
  }
}

#' To produce the output for integers, we first need to create a data frame of complete cases for each variable.
#' This is because the "ds.meanByClass" function just includes NA in its "length" output.
#' 
#' This will make the function quite slow, but the alternative "ds.meanSDGroup" often fails if there are small cells
#' would be nice to include median(IQR), but this would require a bit more work (reshaping etc)
#' 
#' @param integer the age specification of the variable
#' @param table the table in the DataSHIELD backend you want to query
#' @param levels these are possible variable levels
#' @param conns connections to the DataSHIELD backends
#' 
#' @return a table of mean by class information
#' 
#' @noRd
qc.process.integer.vars <- function(intVar, table, levels, conns) {
  requireNamespace("dsBaseClient")
  message(paste0(" * Start evaluating integer: [ ", intVar, " ]"))
    
  dsBaseClient::ds.dataFrame(x = c(paste0(table, "$", intVar), paste0(table, "$age_years2")), newobj = "complete", datasources = conns)
  dsBaseClient::ds.completeCases(x1 = "complete", newobj = "complete", datasources = conns)
    
  output <- dsBaseClient::ds.meanByClass(x = 'complete',
              outvar = intVar,
              covar = 'age_years2',
              type = 'combine',
              datasources = conns)

  # this is OK as the reshape script keeps time 0?
  colnames <- c("Age 0") 
  for (i in 2:length(levels)) {
    colnames <- c(colnames, paste0("Age ", levels[i]))
  }
  
  colnames(output) <- c(colnames)
   
  rm(colnames)
  dsBaseClient::ds.rm("complete", datasources = conns)
  
  message(paste0(" * Succesfully evaluated: [ ", intVar, " ]"))
  
  return(output)
}

#' Generate summary statistics for factors
#'
#' @param factVar variable name that needs to checked
#' @param table table where the variable should be located
#' @param levels repeats number of the variable
#' @param options categories of the variable
#' @param ageVariable the type of age variable
#' @param conns connections to the backend
#' 
#' @noRd
qc.process.factor.vars <- function(factVar, table, levels, options, ageVariable, conns) {
  requireNamespace("dsBaseClient")
  message(paste0(" * Start evaluating factor: [ ", factVar, " ]"))
  n <- length(options)
  n2 <- length(levels)
  output <- dsBaseClient::ds.table(paste0(table, "$", factVar), paste0(table, "$", ageVariable), datasources = conns)
  counts <- data.frame(matrix(unlist(output$output.list$TABLE_STUDY.1_counts), nrow = n + 1, ncol = n2, byrow = F))
  prop <- data.frame(matrix(unlist(output$output.list$TABLES.COMBINED_all.sources_col.props), nrow = n + 1, ncol = n2, byrow = F))
  out <- data.frame(cbind(counts[,c(1)],prop[,c(1)]))
  
  for (i in 2:n2) {
    eval(parse(text = (paste0("out_", factVar, " <- data.frame(cbind(out,paste0(counts[,c(", i, ")],' (',prop[,c(", i, ")],')')))"))))
  }
  
  colnames <- c("N (proportion) age 0")
  for (i in 2:length(levels)) {
    colnames <- c(colnames, paste0("N (proportion) age ", levels[i]))
  }
  
  eval(parse(text = paste0("colnames(out_", factVar, ") <- c(colnames)")))
  eval(parse(text = paste0("rownames(out_", factVar, ") <- c(options, 'NA')")))
  
  rm(n, output, counts, prop, colnames)
  
  message(paste0(" * Succesfully evaluated: [ ", factVar, " ]"))
  
  return(data.frame())
}
