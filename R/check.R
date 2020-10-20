lifecycle.globals <- new.env()

#'
#'
#' Validates the variables for a certain table
#' 
#' @importFrom opal datashield.login
#' @importFrom dsBaseClient ds.ls ds.length ds.colnames
#' 
#' @param project specify the project which you want to check
#' @param table specify the table in the corresponding project you want to check
#' 
#' @export
lc.check <- local(function() {
  # use the columns in lc_data to check if there is data
  # reshape the repeated measures to know which years are there
  
  
  serverName <- "validate"
  url <- lifecycle.globals$hostname
  user <- lifecycle.globals$username
  password <- lifecycle.globals$password
  table <- paste0(project, ".", table)
  logindata <- data.frame(serverName, url, user, password, table)
  server <- datashield.login(logins = logindata, assign = T)
  
  columns <- ds.colnames(x = "D", datasources = server)
  
  prefixedColumns <- sapply(columns, function(column) paste0("D$",column))
  
  results <- list()
  
  for(prefixedColumn in prefixedColumns) {
    column <- substring(prefixedColumn, 3)
    results[ column ] <- ds.numNA(x = prefixedColumn, datasources = server)
  }
  
  print(results)
  
  #noDataVariables <- list()
  #for(column in columns) {
  #  if(results[ column ][1]) {
  #    noDataVariables <- c(noDataVariables, column)
  #  }
  #}
  
  #if(length(noDataVariables) > 0) {
  #  message("[WARNING] These column are not containing any data. Please check if this is correct.")
  #  message(noDataVariables)
  #} else {
  #  message("[OK] All data is present")
  #}
  
})



