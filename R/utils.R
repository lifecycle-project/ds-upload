# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

cohorts <- c("dnbc", "gecko", "alspac", "genr", "moba", "sws", "bib", "chop", "elfe", 
    "eden", "ninfea", "hbcs", "inma", "isglobal", "nfbc66", "nfbc86", "raine", "rhea", 
    "abcd")

ds_upload.globals$input_formats <- c("CSV", "STATA", "SPSS", "SAS")
ds_upload.globals$variable_category <- c("ALL", "META", "MATERNAL", "PATERNAL", "CHILD", 
    "HOUSEHOLD")
ds_upload.globals$cohort_ids <- cohorts

ds_upload.globals$api_base_url <- "https://api.github.com/repos/lifecycle-project/analysis-protocols/contents/"

#' Download all released data dictionaries
#'
#' @param dict_version dictionary version
#' @param dict_kind dictionary kind (possible kinds are 'core' or 'outcome')
#'
#' @importFrom utils download.file packageVersion
#'
du.dict.download <- local(function(dict_version, dict_kind) {
    message("######################################################")
    message("  Start download dictionaries")
    message("------------------------------------------------------")
    
    dir.create(dict_kind)
    
    files <- getResponseAsDataFrame(paste(ds_upload.globals$api_base_url, "R/data/dictionaries/", 
        dict_kind, "/", dict_version, "?ref=", ds_upload.globals$package_tag, sep = ""))
    
    for (f in 1:nrow(files)) {
        file <- files[f, ]
        message(paste("* Download: [ ", file$name, " ]", sep = ""))
        download.file(url = file$download_url, destfile = paste(dict_kind, "/", file$name, 
            sep = ""), mode = "wb", method = "libcurl", quiet = TRUE)
    }
    
    message("  Successfully downloaded dictionaries")
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
    
    data_summary <- df %>% summarise(variable = paste(.var), min = min(!!.var, na.rm = TRUE), 
        max = max(!!.var, na.rm = TRUE), median = median(!!.var, na.rm = TRUE), mean = mean(!!.var, 
            na.rm = TRUE), n = n(), missing = sum(is.na(!!.var)))
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
    
    ds_upload.globals$package_tag <- packageVersion("lifecycleProject")
    
    versions <- getResponseAsDataFrame(paste(ds_upload.globals$api_base_url, "R/data/dictionaries/", 
        dict_kind, "?ref=", ds_upload.globals$package_tag, sep = ""))
    
    if (dict_kind == "core") {
        ds_upload.globals$dictionaries_core <- versions$name
    } else {
        ds_upload.globals$dictionaries_outcome <- versions$name
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
    json_response <- content(response, as = "text")
    return(fromJSON(json_response))
})

#'
#' Check the package version 
#'
#' @importFrom jsonlite fromJSON
#' @importFrom utils packageVersion
#'
checkPackageVersion <- function() {
    packageName <- url <- "https://registry.molgenis.org/service/rest/v1/search?repository=r-hosted&name=dsUpload"
    result <- fromJSON(txt = url)
    currentVersion <- packageVersion("dsUpload")
    if (any(result$items$version > currentVersion)) {
        message(paste0("***********************************************************************************"))
        message(paste0("  [WARNING] You are not running the latest version of the lifecycleProject package."))
        message(paste0("  [WARNING] If you want to upgrade to newest version : [ ", max(result$items$version), 
            " ],"))
        message(paste0("  [WARNING] Please run 'install.packages(\"lifecycleProject\", repos = \"https://registry.molgenis.org/repository/R/\")'"))
        message(paste0("  [WARNING] Check the release notes here: https://github.com/lifecycle-project/analysis-protocols/releases/tag/", 
            max(result$items$version)))
        message(paste0("***********************************************************************************"))
    }
}

