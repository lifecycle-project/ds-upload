# Use environment to store some path variables to use in different functions
lifecycle.globals <- new.env()

cohorts <- c('dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')

lifecycle.globals$input_formats <- c('CSV', 'STATA', 'SPSS', 'SAS')
lifecycle.globals$variable_category <- c('ALL','META','MATERNAL','PATERNAL','CHILD','HOUSEHOLD')
lifecycle.globals$cohort_ids <- cohorts

lifecycle.globals$dictionaries_core <- c('1_0', '1_1')
lifecycle.globals$dictionaries_outcome <- c('1_0')

#' Numerical extraction function
#' Number at the end of the string: Indicates year. We need to extract this to create the age_years variable.
#' This is the function to do so.
#' 
#' @param input_string convert this string into an integer value
#' 
#' @importFrom stringr str_extract
#' 
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

#'
#' Check if the given version matches the syntax number . underscore . number
#' 
#' @param version the version input of the user
#' 
#' @importFrom stringr str_detect
#'
checkVersion <- local(function(version) {
  return(str_detect(version, "\\d+\\_\\d+"))
})

