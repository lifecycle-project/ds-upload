# Use environment to store some path variables to use in different functions
lifecycle.globals <- new.env()

cohorts <-
  c(
    'dnbc',
    'gecko',
    'alspac',
    'genr',
    'moba',
    'sws',
    'bib',
    'chop',
    'elfe',
    'eden',
    'ninfea',
    'hbcs',
    'inma',
    'isglobal',
    'nfbc66',
    'nfbc86',
    'raine',
    'rhea',
    'abcd'
  )

lifecycle.globals$input_formats <- c('CSV', 'STATA', 'SPSS', 'SAS')
lifecycle.globals$variable_category <-
  c('ALL', 'META', 'MATERNAL', 'PATERNAL', 'CHILD', 'HOUSEHOLD')
lifecycle.globals$cohort_ids <- cohorts

lifecycle.globals$api_base_url <- 'https://api.github.com/repos/lifecycle-project/analysis-protocols/contents/'

#' Download all released data dictionaries
#'
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 1_1 / default = 1_0)
#' @param dict_kind dictionary kind (possible kinds are 'core' or 'outcome')
#'
#' @importFrom utils download.file packageVersion
#'
lc.dict.download <- local(function(dict_version, dict_kind) {
  message('######################################################')
  message('  Start download dictionaries')
  message('------------------------------------------------------')
  
  dir.create(dict_kind)

  files <- getResponseAsDataFrame(paste(lifecycle.globals$api_base_url, 'R/data/dictionaries/', dict_kind, '/', dict_version, '?ref=', lifecycle.globals$package_tag, sep = ""))
  
  for(f in 1:nrow(files)) {
    file <- files[f,]
    message(paste('* Download: [ ', file$name, ' ]', sep = ''))
    download.file(
      url = file$download_url,
      destfile = paste(dict_kind, '/' ,file$name, sep = ''),
      mode = "wb",
      method = "libcurl",
      quiet = TRUE
    )
  }
  
  message('  Successfully downloaded dictionaries')
})

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
    summarise(
      variable = paste(.var),
      min = min(!!.var, na.rm = TRUE),
      max = max(!!.var, na.rm = TRUE),
      median = median(!!.var, na.rm = TRUE),
      mean = mean(!!.var, na.rm = TRUE),
      n = n(),
      missing = sum(is.na(!!.var))
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

#'
#' Get the possible dictionary versions from Github
#' 
#' @param dict_kind dictionary kind (can be 'core' or 'outcome')
#' 
#' @importFrom utils packageVersion
#'
#'
populateDictionaryVersions <- local(function(dict_kind) {
 
  lifecycle.globals$package_tag <- packageVersion('lifecycleProject')
  
  versions <- getResponseAsDataFrame(paste(lifecycle.globals$api_base_url, 'R/data/dictionaries/', dict_kind, '?ref=', lifecycle.globals$package_tag, sep = ""))
  
  if(dict_kind == 'core') {
    lifecycle.globals$dictionaries_core <- versions$name
  } else {
    lifecycle.globals$dictionaries_outcome <- versions$name
  }
   
})

#'
#' Parse response to dataframe
#'
#' @param url get this location
#' 
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON 
#' 
#' @return response as dataframe
#'
getResponseAsDataFrame <- local(function(url) {
  response <- GET(url)
  json_response <-content(response,as="text")
  return(fromJSON(json_response))
})

#'
#' Check the package version 
#'
#' @importFrom jsonlite fromJSON
#' @importFrom utils packageVersion
#'
checkPackageVersion <- function() {
  url <- 'http://registry.molgenis.org/service/rest/v1/search?repository=r-hosted&name=lifecycleProject'
  result <- fromJSON(txt=url)
  currentVersion <- packageVersion("lifecycleProject")
  if(any(result$items$version > currentVersion)) {
    message(paste0("***********************************************************************************"))
    message(paste0("  [WARNING] You are not running the latest version of the lifecycleProject package."))
    message(paste0("  [WARNING] If you want to upgrade to newest version : [ " , max(result$items$version), " ],"))
    message(paste0("  [WARNING] please run 'install.packages(\"lifecyclePackage\")'"))
    message(paste0("***********************************************************************************"))
  }
}

