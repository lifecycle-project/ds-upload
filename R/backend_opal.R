#' Uploading the generated data files to Opal backend
#'
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_name name of the data file
#'
#' @importFrom opalr opal.file_upload opal.file_mkdir opal.file_ls
#'
#' @keywords internal
du.reshape.upload <- function(dict_kind, file_name) {
  upload_directory <- paste0("/home/", ds_upload.globals$username)
  
  message(paste0("* Upload: [ ", file_name, ".csv ] to directory [ ", dict_kind, " ]"))
  dirs <- opal.file_ls(ds_upload.globals$opal, upload_directory)
  if (!(dict_kind %in% dirs$name)) {
    opal.file_mkdir(ds_upload.globals$opal, paste0(upload_directory, "/", dict_kind))
  }
  opal.file_upload(ds_upload.globals$opal, source = paste0(getwd(), "/", file_name, ".csv"), destination = paste0(upload_directory, "/", dict_kind))
  
  unlink(paste0(getwd(), "/", file_name, ".csv"))
}

#' Importing generated data files
#'
#' @param file_prefix a date to prefix the file with
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version the data release version
#' @param file_name name of the data file
#'
#' @importFrom readr read_csv
#' @importFrom opalr opal.post
#' @importFrom opalr opal.projects
#' @importFrom opalr opal.tables
#' @importFrom jsonlite toJSON
#'
#' @keywords internal
du.reshape.import <- function(file_prefix, dict_kind, file_version, file_name) {
  message("------------------------------------------------------")
  message("  Start importing data files")
  
  file_ext <- ".csv"
  
  projects <- opal.projects(ds_upload.globals$opal)
  project <- readline(paste("Which project you want to upload into: [ ", paste0(projects$name,
                                                                                collapse = ", "
  ), " ]: ", sep = ""))
  
  if (!(project %in% projects$name)) {
    stop(paste("Invalid projectname: [ ", project, " ]", sep = ""))
  }
  
  tables <- opal.tables(ds_upload.globals$opal, project)
  
  table_name <- ""
  if (file_name %in% tables$name) {
    table <- tables$name
  }
  
  data <- read_csv(paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version,
                         "_", file_name, file_ext,
                         sep = ""
  ))
  
  message(paste("* Import: ", paste(getwd(), "/", file_prefix, "_", dict_kind, "_",
                                    file_version, "_", file_name, file_ext,
                                    sep = ""
  ), sep = ""))
  opal.post(ds_upload.globals$opal, "datasource", ds_upload.globals$project, "table",
            table_name, "variables",
            body = toJSON(data), contentType = "application/x-protobuf+json"
  )
  
  unlink(paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version, "_", file_name,
               file_ext,
               sep = ""
  ))
  
  message("  Succesfully imported the files")
}

#' Create the project with data dictionary version in between
#'
#' @param project prpject resource in Opal
#' @param database_name the database name of the Opal instance (default = opal_data)
#'
#' @importFrom dplyr between
#' @importFrom opalr opal.post
#'
#' @keywords internal
du.project.create <- function(project, database_name) {
  canonical_project_name <- strsplit(project, "_")
  dict_kind <- canonical_project_name[[1]][3]
  dict_version <- paste0(canonical_project_name[[1]][3], "_rep")
  
  message("------------------------------------------------------")
  message(paste("  Start creating project: [ ", project, " ]", sep = ""))
  
  projects <- opal.projects(ds_upload.globals$opal)
  
  if (!(project %in% projects$name)) {
    json <- sprintf(
      "{\"database\":\"%s\",\"description\":\"%s\",\"name\":\"%s\",\"title\":\"%s\"}",
      database_name, paste("Project for [ ", dict_kind, " ] variables and data dictionary version: [ ",
                           dict_version, " ]",
                           sep = ""
      ), project, project
    )
    opal.post(ds_upload.globals$opal, "projects", body = json, contentType = "application/x-protobuf+json")
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
#' @keywords internal
du.dict.import <- function(project, dictionaries, dict_kind) {
  message("------------------------------------------------------")
  message("  Start importing dictionaries")
  
  dictionaries %>%
    map(function(dict) {
      json_table <- sprintf("{\"entityType\":\"Participant\",\"name\":\"%s\"}", dict$table)
      tables <- opal.tables(ds_upload.globals$opal, project)
      if (!(dict$table %in% tables$name)) {
        message(paste("* Create table: [ ", dict$table, " ]", sep = ""))
        url <- paste0("datasource/", project, "/tables")
        opal.post(ds_upload.globals$opal, url,
                  body = json_table,
                  contentType = "application/x-protobuf+json"
        )
      } else {
        message(paste("* Table: [ ", dict$table, " ] already exists", sep = ""))
      }
      
      du.match.dict.categories(project, dict_kind, dict$table, dict$file_name)
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
#' @keywords internal
du.match.dict.categories <- function(project, dict_kind, table, file_name) {
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
  opal.post(ds_upload.globals$opal, url,
            body = toJSON(variables), contentType = "application/x-protobuf+json"
  )
}