#' Opal login
#'
#' @param login_data data frame containing login credentials
#'
#' @importFrom opalr opal.login
#'
#' @noRd
du.opal.login <- function(login_data) {
  requireNamespace("opalr")
  opal <- opal.login(
    username = as.character(login_data$username), password = as.character(login_data$password),
    url = as.character(login_data$server), opts = login_data$options
  )
  return(opal)
}

#' Uploading the generated data files to Opal backend
#'
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_name name of the data file
#'
#' @importFrom opalr opal.file_upload opal.file_mkdir opal.file_ls
#'
#' @noRd
du.opal.upload <- function(dict_kind, file_name) {
  requireNamespace("opalr")
  upload_directory <- paste0("/home/", ds_upload.globals$login_data$username)

  message(paste0("* Upload: [ ", file_name, ".csv ] to directory [ ", dict_kind, " ]"))
  dirs <- opal.file_ls(ds_upload.globals$conn, upload_directory)
  if (!(dict_kind %in% dirs$name)) {
    opal.file_mkdir(ds_upload.globals$conn, paste0(upload_directory, "/", dict_kind))
  }
  opal.file_upload(ds_upload.globals$conn, source = paste0(getwd(), "/", file_name, ".csv"), destination = paste0(upload_directory, "/", dict_kind))

  unlink(paste0(getwd(), "/", file_name, ".csv"))
}

#' Create the project with data dictionary version in between
#'
#' @param project prpject resource in Opal
#' @param database_name the database name of the Opal instance (default = opal_data)
#'
#' @importFrom dplyr between
#' @importFrom opalr opal.post
#'
#' @noRd
du.opal.project.create <- function(project, database_name) {
  requireNamespace("opalr")
  canonical_project_name <- strsplit(project, "_")
  dict_kind <- canonical_project_name[[1]][3]
  dict_version <- paste0(canonical_project_name[[1]][4], "_", canonical_project_name[[1]][5])

  message("------------------------------------------------------")
  message(paste0("  Start creating project: [ ", project, " ]"))

  projects <- opalr::opal.projects(ds_upload.globals$conn)

  if (!(project %in% projects$name)) {
    json <- sprintf(
      "{\"database\":\"%s\",\"description\":\"%s\",\"name\":\"%s\",\"title\":\"%s\"}",
      database_name, paste0("Project for [ ", dict_kind, " ] variables and data dictionary version: [ ",
        dict_version, " ]"
      ), project, project
    )
    opal.post(ds_upload.globals$conn, "projects", body = json, contentType = "application/x-protobuf+json")
  } else {
    message(paste("* Project: [ ", project, " ] already exists", sep = ""))
  }
}

#' Import the data dictionaries into Opal
#'
#' @param project project in which the data is imported
#' @param dictionaries all the dictionaries pulled from the repository
#' @param dict_kind dictionary kind
#'
#' @importFrom readxl read_xlsx
#' @importFrom purrr map
#'
#' @noRd
du.opal.dict.import <- function(project, dictionaries, dict_kind) {
  requireNamespace("opalr")
  message("------------------------------------------------------")
  message("  Start importing dictionaries")

  dictionaries %>%
    map(function(dict) {
      json_table <- sprintf("{\"entityType\":\"Participant\",\"name\":\"%s\"}", dict$table)
      tables <- opalr::opal.tables(ds_upload.globals$conn, project)
      if (!(dict$table %in% tables$name)) {
        message(paste("* Create table: [ ", dict$table, " ]", sep = ""))
        url <- paste0("datasource/", project, "/tables")
        opal.post(ds_upload.globals$conn, url,
          body = json_table,
          contentType = "application/x-protobuf+json"
        )
      } else {
        message(paste("* Table: [ ", dict$table, " ] already exists", sep = ""))
      }

      du.opal.dict.match.categories(project, dict_kind, dict$table, dict$file_name)
    })

  message("  All dictionaries are populated correctly")
}

#' Match the categories with the variables to be import them
#' Import the variables
#'
#' @param project project resource in Opal
#' @param dict_kind kind of dictionary
#' @param table table name
#' @param file_name dictionary to upload to Opal
#'
#' @importFrom opalr opal.post
#' @importFrom dplyr select %>% nest_join rename
#' @importFrom readxl read_xlsx
#'
#' @noRd
du.opal.dict.match.categories <- function(project, dict_kind, table, file_name) {
  requireNamespace("opalr")
  # workaround to avoid global variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  label <- name <- NULL

  variables <- read_xlsx(path = paste0(getwd(), "/", dict_kind, "/", file_name), sheet = 1)
  categories <- read_xlsx(path = paste0(getwd(), "/", dict_kind, "/", file_name), sheet = 2)

  variables$entityType <- "Participant"
  variables$isRepeatable <- FALSE
  variables$attributes <- data.frame(namespace = "", name = "label", locale = "", value = variables$label)
  variables <- select(variables, -c(label))

  if (nrow(categories) > 0) {
    message(paste("* Matched categories for table: [ ", table, " ]", sep = ""))
    categories <- transform(categories, name = as.character(name))
    categories$attributes <- data.frame(
      namespace = "", name = "label", locale = "",
      value = categories$label
    )
    categories <- select(categories, -c(label))
    variables <- variables %>% nest_join(categories, by = c(name = "variable"))
  }

  message(paste("* Import variables into: [ ", table, " ]", sep = ""))

  url <- paste0("datasource/", project, "/table/", table, "/variables")
  opal.post(ds_upload.globals$conn, url,
    body = jsonlite::toJSON(variables), contentType = "application/x-protobuf+json"
  )
}
