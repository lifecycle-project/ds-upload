# Use environment to store some path variables to use in different functions
lifecycle.globals <- new.env()

cohorts <- c('dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
cohort_urls <- c('https://opal.sund.ku.dk', 'https://opal.gcc.rug.nl', '', 'https://opal.erasmusmc.nl', 'https://moba.nhn.no', 'https://opal.mrc.soton.ac.uk:8443', '', 'https://lifecycle-project.med.uni-muenchen.de', 'https://elfe-opal.sicopre.elfe-france.fr', '', 'https://www.lifecycle-ninfea.unito.it', '', '', 'https://opal.isglobal.org', '', '', 'https://opal.gohad.uwa.edu.au', '')
lifecycle.globals$cohorts <- setNames(as.list(cohort_urls), cohorts)
lifecycle.globals$cohort_ids <- cohorts
lifecycle.globals$dictionaries <- c('1_0')

#' Login into the opal instance and 
#' 
#' @param hostname specify hostname of Opal instance
#' @param username specify username (of administrator) of Opal instance (default = administrator)
#' @param password specify password (of administrator) of Opal instance
#' 
#' @importFrom opalr opal.login
#' 
#' @export
#' 
lc.login <- local(function(hostname, username = 'administrator', password) {
  if(missing(hostname)) hostname <- readline('- Hostname (e.g. https://my-own-opal.org): ')
  if(missing(hostname) && missing(password))
  if(missing(password)) password <- readline('- Password: ')
  
  lifecycle.globals$hostname <- hostname
  lifecycle.globals$username <- username
  lifecycle.globals$password <- password
  
  message(paste('  Login to: "', lifecycle.globals$hostname, '"', sep = ''))
  lifecycle.globals$opal <- opal.login(username = lifecycle.globals$username, password = lifecycle.globals$password, url = lifecycle.globals$hostname)
  message(paste('  Logged on to: "', lifecycle.globals$hostname, '"', sep = ''))
})

#' Numerical extraction function
#' Number at the end of the string: Indicates year. We need to extract this to create the age_years variable.
#' This is the function to do so.
#' 
#' @param input_string convert this string into an integer value
#' 
#' @importFrom stringr str_extract
#' 
#' @export
numextract <- local(function(input_string) { 
  str_extract(input_string, "\\d*$") 
})

#' This function creates a summary table
#' 
#' @param df data frame to summarise
#' @param .var variable to summarise
#' 
#' @importFrom dplyr summarise n
#' @importFrom rlang sym
#' @importFrom stats median
#' 
#' @return a summary of the data
#' 
#' @export
#' 
summarizeR <- local(function(df, .var) {
  
  .var <- sym(.var)
  
  data_summary <- df %>%
    summarise(variable=paste(.var),
                     min = min(!! .var, na.rm = TRUE),
                     max = max(!! .var, na.rm = TRUE),
                     median = median(!! .var, na.rm = TRUE),
                     mean = mean(!! .var, na.rm = TRUE),
                     n=n(),
                     missing=sum(is.na(!! .var))
    )
  return(data_summary)
})

