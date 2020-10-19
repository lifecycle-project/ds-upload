# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

ds_upload.globals$api_dict_released_url <- "https://api.github.com/repos/lifecycle-project/ds-dictionaries/contents/"
ds_upload.globals$api_dict_beta_url <- "https://api.github.com/repos/lifecycle-project/ds-beta-dictionaries/contents/"

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


#' Create a temporary directory in the current working directory to store all temporary files
#'
#' @keywords internal
du.create.temp.workdir <- function() {
  message(" * Create temporary workdir")
  original_workdir <- getwd()

  timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")

  temp_workdir <- paste0(timestamp)
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
  original_workdir <- unlist(workdirs)[1]
  temp_workdir <- unlist(workdirs)[2]
  setwd(original_workdir)
  if (upload == TRUE) {
    message(" * Cleanup temporary directory")
    unlink(temp_workdir, recursive = T)
  } else {
    message(" * Be advised: you need to cleanup the temporary directories yourself now.")
  }
}
