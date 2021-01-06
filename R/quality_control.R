#' Validates the variables for a certain table
#'
#' @param project specify project you want to perform quality control on
#' @param assign_threshold specify number of variables to assign in one run (default = 20)
#' @param verbose output the functions output when set to TRUE
#'
#' @importFrom DSI datashield.login newDSLoginBuilder datashield.assign.table
#' @importFrom opalr opal.projects opal.tables
#' @importFrom MolgenisArmadillo armadillo.list_projects armadillo.list_tables
#' @importFrom dplyr %>%
#'
#' @export
du.quality.control <- function(project, assign_threshold = 20, verbose = FALSE) {
  requireNamespace("dsBaseClient")
  message("  Starting quality control")
  message("------------------------------------------------------")
  du.check.session(TRUE)
  builder <- newDSLoginBuilder()
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
    requireNamespace("DSMolgenisArmadillo")
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
          message(paste0(" * Starting with: ", project, " - ", table))

          conns <- datashield.login(logins = builder$build(), assign = FALSE)

          qc_dataframe_symbol <- "QC"

          tables_to_assign <- paste0(project, ".", table)
          if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
            tables_to_assign <- paste0(project, "/", table)
          }

          tryCatch(
            {
              datashield.assign.table(conns = conns, table = tables_to_assign, symbol = qc_dataframe_symbol)
            },
            error = function(e) {
              message("Please decrease the number of variables assigned in one go")
              return()
            }
          )

          if (grepl(du.enum.table.types()$NONREP, table)) {
            qc.non.repeated(conns, qc_dataframe_symbol, verbose)
          }
          if (grepl(du.enum.table.types()$YEARLY, table)) {
            qc.yearly.repeated(conns, qc_dataframe_symbol, verbose)
          }
          if (grepl(du.enum.table.types()$MONTHLY, table)) {
            qc.monthly.repeated(conns, qc_dataframe_symbol, verbose)
          }
          if (grepl(du.enum.table.types()$TRIMESTER, table)) {
            qc.trimester(conns, qc_dataframe_symbol, verbose)
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
#' @importFrom dsBaseClient ds.ls ds.colnames
#' @importFrom dsHelper dh.getStats
#' @importFrom jsonlite toJSON
#'
#' @noRd
qc.non.repeated <- function(conns, table, verbose) {
  vars <- ds.colnames(datasources = conns, x = table)

  # make it a plain old vector
  plain_vars <- as.vector(unlist(vars, use.names = FALSE))

  # strip unnecessary fields
  plain_vars <- plain_vars[!plain_vars %in% c("child_id")]

  result <- dh.getStats(
    conns = conns,
    table = table,
    vars = plain_vars
  )

  jsonResult <- toJSON(result)

  if (verbose) {
    print(result)
  }
}

#' Quality control for yearly repeated measures
#'
#' @param conns connection object for DataSHIELD backends
#' @param table table to perform quality control on
#' @param verbose print output to screen
#'
#' @importFrom dsBaseClient ds.colnames ds.class ds.meanSdGp ds.table ds.asFactor ds.cbind ds.levels ds.dataFrame ds.completeCases ds.rm ds.summary
#' @importFrom dplyr all_of %>%
#' @importFrom purrr map
#'
#' @noRd
qc.yearly.repeated <- function(conns, table, verbose) {
  # Define variables to be read in
  myvar <- list("child_id", "age_years", "edu_m_", "famsize_child", "famsize_adult") # This is just for test purposes, actual script will link to dds on Github

  # Define dataframe and variables:
  vars <- ds.colnames(table, datasources = conns)
  # make it a flat list
  vars <- as.vector(unlist(vars, use.names = FALSE))
  # exclude variables not required:
  vars <- vars[!vars %in% c("child_id", "age_years")]

  ## Create vector of full names for datashield
  full_var_names <- paste0(table, "$", vars)

  class_list <- full_var_names %>% map(function(x) {
    ds.class(x, datasources = conns)
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

  # Convert age_years to a factor variable (required for the table):
  ds.asFactor(
    input.var.name = paste0(table, "$age_years"),
    newobj.name = "age_years2",
    datasources = conns
  )
  ds.cbind(x = c(table, "age_years2"), newobj = table, datasources = conns)
  # Store some summary information:
  summary2 <- ds.levels(paste0(table, "$age_years2"), datasources = conns)
  n2 <- length(summary2$validate$Levels)
  levels <- summary2$validate$Levels

  for (j in 1:length(factors)) {
    message(" * Start evaluating factor: [ ", paste0(factors[j]), " ]")
    summary1 <- ds.summary(paste0(table, "$", factors[j]), datasources = conns)
    n <- length(summary1$validate$categories) 
    output <- ds.table(paste0(table, "$", factors[j]), paste0(table, "$age_years2"), datasources = conns)
    counts <- data.frame(matrix(unlist(output$output.list$TABLE_STUDY.1_counts), nrow = n + 1, ncol = n2, byrow = F))
    prop <- data.frame(matrix(unlist(output$output.list$TABLES.COMBINED_all.sources_col.props), nrow = n + 1, ncol = n2, byrow = F))
    eval(parse(text = (paste0("out_", factors[j], " <- data.frame(cbind(paste0(counts[,c(1)],' (',prop[,c(1)],')')))"))))


    for (i in 2:n2) {
      eval(parse(text = (paste0("out_", factors[j], " <- data.frame(cbind(out_", factors[j], ",paste0(counts[,c(", i, ")],' (',prop[,c(", i, ")],')')))"))))
    }

    colnames <- c("N (proportion) age 0") # all cohorts should have age 0
    for (i in 2:length(levels)) {
      colnames <- c(colnames, paste0("N (proportion) age ", levels[i]))
    }

    eval(parse(text = paste0("colnames(out_", factors[j], ") <- c(colnames)")))
    eval(parse(text = paste0("rownames(out_", factors[j], ") <- c(summary1$validate$categories, 'NA')")))

    rm(summary1, n, output, counts, prop, colnames)
  }


  output <- data.frame()
  for (j in 1:length(integers)) {
    out <- qc.process.integer.vars(integers[j], table, levels, conns)
    cbind(output, out)
  }
  print(output)
}

#' Quality control for monthly repeated measures
#'
#' @param conns connection object for DataSHIELD backends
#' @param table table to perform quality control on
#' @param verbose print output to screen
#'
#' @importFrom dsBaseClient ds.colnames ds.class ds.meanSdGp ds.table ds.asFactor ds.cbind ds.levels ds.dataFrame ds.completeCases ds.rm
#' @importFrom dplyr all_of %>%
#' @importFrom purrr map
#'
#' @noRd
qc.monthly.repeated <- function(conns, table, verbose) {
  vars <- ds.colnames(table, datasources = conns)
  # make it a flat list
  vars <- as.vector(unlist(vars, use.names = FALSE))
  # exclude variables not required:
  vars <- vars[!vars %in% c("row_id", "child_id", "age_months", "age_years", "height_age", "weight_age")]

  ## Create vector of full names for datashield
  full_var_names <- paste0(table, "$", vars)

  class_list <- full_var_names %>% map(function(x) {
    ds.class(x, datasources = conns)
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
  ds.asFactor(
    input.var.name = paste0(table, "$age_months"),
    newobj.name = "age_months2",
    datasources = conns
  )
  ds.cbind(x = c(table, "age_months2"), newobj = table, datasources = conns)

  summary1 <- ds.levels(paste0(table, "$age_months2"), datasources = conns)
  n1 <- length(summary1$validate$Levels) 

  # Convert age_years to a factor variable (required for the tables):
  ds.asFactor(
    input.var.name = paste0(table, "$age_years"),
    newobj.name = "age_years2",
    datasources = conns
  )
  ds.cbind(x = c(table, "age_years2"), newobj = table, datasources = conns)

  # summarise some information from age_years2
  
  summary2 <- ds.levels(paste0(table, "$age_years2"), datasources = conns)
  n2 <- length(summary2$validate$Levels)
  levels <- summary2$validate$Levels

  output <- data.frame()
  
  for (j in 1:length(integers)) {
    out <- qc.process.integer.vars(integers[j], table, levels, conns)
    print("gelukt!")
    cbind(output, out)
    print("ook gelukt")
  }
  print("klaar")
  print(output)
}

#' Quality control for trimester measures
#'
#' @param conns connection object for DataSHIELD backends
#' @param table table to perform quality control on
#' @param verbose print output to screen
#'
#' @importFrom dsBaseClient ds.colnames ds.class ds.meanSdGp ds.table ds.asFactor ds.cbind ds.levels ds.dataFrame ds.completeCases ds.rm
#' @importFrom dplyr all_of %>%
#' @importFrom purrr map
#'
#' @noRd
qc.trimester <- function(conns, table, verbose) {
  vars <- ds.colnames(table, datasources = conns)
  # make it a flat list
  vars <- as.vector(unlist(vars, use.names = FALSE))
  # exclude variables not required:
  vars <- vars[!vars %in% c("child_id", "age_trimester")]

  ## Create vector of full names for datashield
  full_var_names <- paste0(table, "$", vars)

  class_list <- full_var_names %>% map(function(x) {
    ds.class(x, datasources = conns)
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
  ds.asFactor(
    input.var.name = paste0(table, "$age_trimester"),
    newobj.name = "age_trimester2",
    datasources = conns
  )
  ds.cbind(x = c(table, "age_trimester2"), newobj = table, datasources = conns)
  # Store some summary information:
  summary2 <- ds.levels(paste0(table, "$age_trimester2"))
  n2 <- length(summary2$dnbc$Levels) # how can I replace "dnbc" with "names(conns)"?
  levels <- summary2$dnbc$Levels

  for (j in 1:length(factors)) {
    print(paste0(factors[j], " start"))
    summary1 <- ds.levels(paste0(table, "$", factors[j]), datasources = conns)
    n <- length(summary1$dnbc$Levels) 
    output <- ds.table(paste0(table, "$", factors[j]), paste0(table, "$age_trimester2"), datasources = conns)
    counts <- data.frame(matrix(unlist(output$output.list$TABLE_STUDY.1_counts), nrow = n + 1, ncol = n2, byrow = F))
    prop <- data.frame(matrix(unlist(output$output.list$TABLES.COMBINED_all.sources_col.props), nrow = n + 1, ncol = n2, byrow = F))
    eval(parse(text = (paste0("out_", factors[j], " <- data.frame(cbind(paste0(counts[,c(1)],' (',prop[,c(1)],')')))"))))

    for (i in 2:n2) {
      eval(parse(text = (paste0("out_", factors[j], " <- data.frame(cbind(out_", factors[j], ",paste0(counts[,c(", i, ")],' (',prop[,c(", i, ")],')')))"))))
    }

    colnames <- c("N (proportion) trimester 1") # all cohorts have trimester 1?
    for (i in 2:length(levels)) {
      colnames <- c(colnames, paste0("N (proportion) trimester ", levels[i]))
    }

    eval(parse(text = paste0("colnames(out_", factors[j], ") <- c(colnames)")))
    eval(parse(text = paste0("rownames(out_", factors[j], ") <- c(summary1$dnbc$Levels, 'NA')")))
    rm(summary1, n, output, counts, prop, colnames)
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
qc.process.integer.vars <- function(int_var, table, levels, conns) {
  message(paste0(" * Start evaluating integer: [ ", int_var, " ]"))
    
  ds.dataFrame(x = c(paste0(table, "$", int_var), paste0(table, "$age_years2")), newobj = "complete", datasources = conns)
  ds.completeCases(x1 = "complete", newobj = "complete", datasources = conns)
    
  output <- ds.meanByClass(x = 'complete',
              outvar = int_var,
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
  ds.rm("complete", datasources = conns)
  
  message(paste0(" * Succesfully evaluated: [ ", int_var, " ]"))
  
  return(output)
}