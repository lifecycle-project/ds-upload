# Use environment to store some path variables to use in different functions
lifecycle.globals <- new.env()

cohorts <- c('dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
cohort_urls <- c('https://opal.sund.ku.dk', 'https://opal.gcc.rug.nl', '', 'https://opal.erasmusmc.nl', 'https://moba.nhn.no', 'https://opal.mrc.soton.ac.uk:8443', '', 'https://lifecycle-project.med.uni-muenchen.de', 'https://elfe-opal.sicopre.elfe-france.fr', '', 'https://www.lifecycle-ninfea.unito.it', '', '', 'https://opal.isglobal.org', '', '', 'https://opal.gohad.uwa.edu.au', '')

lifecycle.globals$input_formats <- c('CSV', 'STATA', 'SPSS', 'SAS')
lifecycle.globals$variable_category <- c('ALL','META','MATERNAL','PATERNAL','CHILD','HOUSEHOLD')
lifecycle.globals$cohorts <- setNames(as.list(cohort_urls), cohorts)
lifecycle.globals$cohort_ids <- cohorts
lifecycle.globals$dictionaries_core <- c('1_0', '1_1')

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

#' Read the input file from different sources
#' 
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param input_path path for importfile
#' 
#' @importFrom readr read_csv cols col_double
#' @importFrom haven read_dta read_sas read_spss
#' 
#' @return dataframe with source data
#'  
lc.read.source.file <- local(function(input_path, input_format = 'CSV') {
  lc_data <- NULL
  
  if(missing(input_path)) {
    input_path <- readline('- Specify input path (for your data): ')
    input_format <- readline('- Specify input format (possible formats: CSV,STATA,SPSS or SAS - default = CSV): ')
  }
  if (input_format %in% lifecycle.globals$input_formats) {
    if (input_format == 'STATA') lc_data <- read_dta(input_path)
    else if (input_format == 'SPSS') lc_data <- read_spss(input_path)
    else if (input_format == 'SAS') lc_data <- read_sas(input_path)
    else lc_data <- read_csv(input_path, col_types = cols(.default = col_double()))
  } else {
    stop(paste(input_format, ' is not a valid input format, Possible input formats are: ', lifecycle.globals$input_formats, sep = ','))
  }
  
  return(lc_data)
})