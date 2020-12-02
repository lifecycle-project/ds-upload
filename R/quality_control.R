#' Validates the variables for a certain table
#'
#' @param project specify project you want to perform quality control on
#' @param verbose ouput the functions output when set to TRUE
#'
#' @importFrom DSI datashield.login newDSLoginBuilder datashield.assign.table
#' @importFrom opalr opal.projects opal.tables
#'
#' @export
du.quality.control <- function(project, number_of_variable = 20, verbose = FALSE) {
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
          
          # assign the data in blocks
          
          
          try {
            datashield.assign.table(conns = conns, table = table_identifier, symbol = qc_dataframe_symbol)
          } catch(Exception e) {
            message("please decrease the number of variables assigned in one go")
          }

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
#' @importFrom dplyr all_of
#'
#' @keywords internal
qc.yearly.repeated <- function(conns, table, verbose) {
  type <- pivot_longer <- NULL
  
  #Define dataframe and variables:
  df <- "D"
  vars <- ds.colnames(df, datasources = conns)
  # make it a flat list 
  vars <- as.vector(unlist(vars, use.names=FALSE))
  # exclude variables not required:
  vars <- vars[!vars %in% c("child_id", "age_years")]
  
  
  # Create vectors of factors and integers (I've replaced my previous code with Tim's code) 
  
  
  ## Create vector of full names for datashield
  full_var_names <- paste0(df, "$", vars)
  
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
  
  #Convert age_years to a factor variable:
  ds.asFactor(input.var.name = paste0(df,"$age_years"),
              newobj.name = "age_years2")
  ds.cbind(x = c(df, "age_years2"), newobj = df)
  
  
  for (j in 1:length(factors)){
    print(paste0(factors[j]," start"))
    summary1 <-ds.summary(paste0(df,"$",factors[j]))
    n<-length(summary1$dnbc$categories) # how can I replace "dnbc" with "names(conns)"?
    summary2 <-ds.summary(paste0(df,"$age_years2")) 
    n2<-length(summary2$dnbc$categories) # how can I replace "dnbc" with "names(conns)"?
    output <-ds.table(paste0(df,"$",factors[j]), paste0(df,"$age_years2"), datasources = conns)
    counts <- data.frame(matrix(unlist(output$output.list$TABLE_STUDY.1_counts), nrow = n+1, ncol = n2, byrow=F)) 
    prop <- data.frame(matrix(unlist(output$output.list$TABLES.COMBINED_all.sources_col.props), nrow = n+1, ncol = n2, byrow=F))
    to_eval = paste0("out_",factors[j]," <- data.frame(cbind(counts[,c(1)],prop[,c(1)],counts[,c(2)],prop[,c(2)],
                          counts[,c(3)],prop[,c(3)],counts[,c(4)],prop[,c(4)],
                          counts[,c(5)],prop[,c(5)],counts[,c(6)],prop[,c(6)],
                          counts[,c(7)],prop[,c(7)],counts[,c(8)],prop[,c(8)],
                          counts[,c(9)],prop[,c(9)],counts[,c(10)],prop[,c(10)],
                          counts[,c(11)],prop[,c(11)],counts[,c(12)],prop[,c(12)],
                          counts[,c(13)],prop[,c(13)],counts[,c(14)],prop[,c(14)],
                          counts[,c(15)],prop[,c(15)],counts[,c(16)],prop[,c(16)]))") # I think this will fail if we have <16 cols?
    # is there a way of linking this with n2 above?
    # we could do it with "if, else", but it would make the script very long
    # OR edit age_years so that it covers all years 0-17 
    # ds.dataframe.fill
    # to_eval = paste0("fmla",i," <- as.formula(paste(data_table, '$', outcome,' ~ ', paste0(c(paste0(data_table, '$',covariates[! covariates %in% exceptions])), collapse= '+'),'+', data_table,'$',interaction,'*', data_table,'$', exposure))")
    eval(parse(text=to_eval))
    to_eval = paste0("colnames(out_",factors[j],") <- c(paste0(summary$dnbc$categories[1],' - N'), paste0(summary$dnbc$categories[1],' - Prop'), 
                paste0(summary$dnbc$categories[2],' - N'), paste0(summary$dnbc$categories[2],' - Prop'),
                paste0(summary$dnbc$categories[3],' - N'), paste0(summary$dnbc$categories[3],' - Prop'),
                paste0(summary$dnbc$categories[4],' - N'), paste0(summary$dnbc$categories[4],' - Prop'),
                paste0(summary$dnbc$categories[5],' - N'), paste0(summary$dnbc$categories[5],' - Prop'),
                paste0(summary$dnbc$categories[6],' - N'), paste0(summary$dnbc$categories[6],' - Prop'),
                paste0(summary$dnbc$categories[7],' - N'), paste0(summary$dnbc$categories[7],' - Prop'),
                paste0(summary$dnbc$categories[8],' - N'), paste0(summary$dnbc$categories[8],' - Prop'),
                paste0(summary$dnbc$categories[9],' - N'), paste0(summary$dnbc$categories[9],' - Prop'),
                paste0(summary$dnbc$categories[10],' - N'), paste0(summary$dnbc$categories[10],' - Prop'),
                paste0(summary$dnbc$categories[11],' - N'), paste0(summary$dnbc$categories[11],' - Prop'),
                paste0(summary$dnbc$categories[12],' - N'), paste0(summary$dnbc$categories[12],' - Prop'),
                paste0(summary$dnbc$categories[13],' - N'), paste0(summary$dnbc$categories[13],' - Prop'),
                paste0(summary$dnbc$categories[14],' - N'), paste0(summary$dnbc$categories[14],' - Prop'),
                paste0(summary$dnbc$categories[15],' - N'), paste0(summary$dnbc$categories[15],' - Prop'),
                paste0(summary$dnbc$categories[16],' - N'), paste0(summary$dnbc$categories[16],' - Prop'))")
    eval(parse(text=to_eval))
    to_eval = paste0("rownames(out_",factors[j],") <- c(summary1$dnbc$categories, 'NA')")
    eval(parse(text=to_eval))
    rm(summary1,summary2, n, n2, output,counts,prop)
  }
  
}
