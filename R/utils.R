# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

cohorts <- c(
  "dnbc", "gecko", "alspac", "genr", "moba", "sws", "bib", "chop", "elfe",
  "eden", "ninfea", "hbcs", "inma", "isglobal", "nfbc66", "nfbc86", "raine", "rhea",
  "abcd"
)

ds_upload.globals$input_formats <- c("CSV", "STATA", "SPSS", "SAS")
ds_upload.globals$variable_category <- c(
  "ALL", "META", "MATERNAL", "PATERNAL", "CHILD",
  "HOUSEHOLD"
)
ds_upload.globals$cohort_ids <- cohorts

ds_upload.globals$api_content_url <- "https://api.github.com/repos/lifecycle-project/ds-dictionaries/contents/"

#' Download all released data dictionaries
#'
#' @param dict_version dictionary version
#' @param dict_kind dictionary kind (possible kinds are 'core' or 'outcome')
#'
#' @importFrom utils download.file packageVersion
#'
#' @keywords internal
du.dict.download <- local(function(dict_version, dict_kind) {
  message("######################################################")
  message("  Start download dictionaries")
  message("------------------------------------------------------")

  dir.create(dict_kind)

  files <- du.get.response.as.dataframe(paste(ds_upload.globals$api_content_url, "/dictionaries/",
    dict_kind, "/", dict_version, "?ref=", dict_version,
    sep = ""
  ))

  for (f in 1:nrow(files)) {
    file <- files[f, ]
    message(paste("* Download: [ ", file$name, " ]", sep = ""))
    download.file(url = file$download_url, destfile = paste(dict_kind, "/", file$name,
      sep = ""
    ), mode = "wb", method = "libcurl", quiet = TRUE)
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
#' @keywords internal
du.num.extract <- local(function(input_string) {
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
#' @keywords internal
du.summarize <- local(function(df, .var) {
  .var <- sym(.var)

  data_summary <- df %>% summarise(
    variable = paste(.var), min = min(!!.var, na.rm = TRUE),
    max = max(!!.var, na.rm = TRUE), median = median(!!.var, na.rm = TRUE), mean = mean(!!.var,
      na.rm = TRUE
    ), n = n(), missing = sum(is.na(!!.var))
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
#' @keywords internal
du.check.version <- local(function(version) {
  return(str_detect(version, "\\d+\\_\\d+"))
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
#' @keywords internal
du.get.response.as.dataframe <- local(function(url) {
  response <- GET(url)
  json_response <- content(response, as = "text")
  return(fromJSON(json_response))
})

#'
#' Check the package version
#'
#' @importFrom jsonlite fromJSON
#' @importFrom utils packageVersion packageName
#'
#' @keywords internal
du.check.package.version <- function() {
  url <- paste0("https://registry.molgenis.org/service/rest/v1/search?repository=r-hosted&name=", packageName())
  result <- fromJSON(txt = url)
  currentVersion <- packageVersion(packageName())
  if (any(result$items$version > currentVersion)) {
    message(paste0("***********************************************************************************"))
    message(paste0("  [WARNING] You are not running the latest version of the ", packageName(), "-package."))
    message(paste0(
      "  [WARNING] If you want to upgrade to newest version : [ ", max(result$items$version),
      " ],"
    ))
    message(paste0("  [WARNING] Please run 'install.packages(\"", packageName(), "\", repos = \"https://registry.molgenis.org/repository/R/\")'"))
    message(paste0(
      "  [WARNING] Check the release notes here: https://github.com/lifecycle-project/analysis-protocols/releases/tag/",
      max(result$items$version)
    ))
    message(paste0("***********************************************************************************"))
  }
}

#' Check if there is an active session with a DataSHIELD backend
#'
#' @param upload is a session needed or not
#'
#' @keywords internal
du.check.session <- function(upload = FALSE) {
  if (upload == TRUE) {
    if (!exists("hostname", envir = ds_upload.globals)) {
      stop("You need to login first, please run du.login")
    }
    if (!exists("username", envir = ds_upload.globals)) {
      stop("You need to login first, please run du.login")
    }
  }
}

#' Check is action is the correct value
#'
#' @param action action to perform
#'
#' @keywords internal
du.check.action <- function(action = "all") {
  if (!(action %in% c("all", "reshape", "populate"))) {
    stop("Unknown action type, please fill in 'populate', 'reshape' or 'all'")
  }
}


#' Create a temparory directory in the current workdir to store all temporary file in
#'
#' @param dict_kind dictionary kinds can be 'core', 'outcome' or 'beta'
#'
#' @keywords internal
du.create.temp.workdir <- function(dict_kind) {
  message(" * Create temporary workdir")
  original_workdir <- getwd()

  file_prefix <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")

  temp_workdir <- paste0(file_prefix, "_", dict_kind)
  temp_workdir <- temp_workdir[which(!(temp_workdir %in% list.files()))]

  dir.create(paste0(getwd(), "/", temp_workdir, sep = ""))
  setwd(paste0(getwd(), "/", temp_workdir, sep = ""))

  return(c(original_workdir, temp_workdir))
}

#' Cleanup all the temporary files from the upload
#'
#' @param upload should we upload the contents to the backend
#' @param workdirs a list containing the original workdir and the created workdir
#'
#' @keywords internal
du.clean.temp.workdir <- function(upload, workdirs) {
  message(" * Reinstate default working directory")
  original_workdir <- workdirs[0]
  temp_workdir <- workdirs[1]
  setwd(original_workdir)
  if (upload == TRUE) {
    message(" * Cleanup temporary directory")
    unlink(temp_workdir, recursive = T)
  } else {
    message(" * Be advised: you need to cleanup the temporary directories yourself now.")
  }
}
