#' Download all released data dictionaries
#'
#' @param dict_name used for beta dictionaries
#' @param dict_version dictionary version
#' @param dict_kind dictionary kind (possible kinds are 'core' or 'outcome')
#'
#' @importFrom purrr pmap
#' @importFrom dplyr select
#' @importFrom utils download.file packageVersion
#'
#' @keywords internal
du.dict.download <- local(function(dict_name, dict_version, dict_kind) {
  message("######################################################")
  message("  Start download dictionaries")
  message("------------------------------------------------------")

  dir.create(dict_kind)

  if (!missing(dict_name)) {
    api_url <- paste0(ds_upload.globals$api_dict_beta_url, "dictionaries/", dict_name)
  } else {
    api_url <- paste0(
      ds_upload.globals$api_dict_released_url, "dictionaries/",
      dict_kind, "/", dict_version, "?ref=", dict_version
    )
  }

  dictionaries <- du.get.response.as.dataframe(api_url)

  dictionaries %>%
    select("name", "download_url") %>%
    pmap(function(name, download_url) {
      message(paste0("* Download: [ ", name, " ]"))
      download.file(url = download_url, destfile = paste0(dict_kind, "/", name), mode = "wb", method = "libcurl", quiet = TRUE)
    })

  message("  Successfully downloaded dictionaries")
})


#' Create the project with data dictionary version in between
#'
#' @param project prpject resource in Opal
#' @param database_name the database name of the Opal instance (default = opal_data)
#'
#' @importFrom dplyr between
#' @importFrom opalr opal.post
#'
#' @keywords internal
du.project.create <- local(function(project, database_name) {
  canonical_project_name <- strsplit(project, "_")
  dict_kind <- canonical_project_name[[1]][3]
  dict_version <- paste0(canonical_project_name[[1]][4], "_", canonical_project_name[[1]][5])

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
})

#' Retrieve the released dictionaries from 'ds-dictionaries' to match against
#'
#' @param api_url url to retrieve the tables from
#' @param dict_version model version of the data
#' @param dict_kind dictionary kind can be outcome, core, exposure
#' @param data_version data version if used to create the tables
#'
#' @importFrom dplyr select
#' @importFrom purrr pmap
#' @importFrom fs path_ext_remove
#'
#' @return dictionaries list of tables
#'
#' @keywords internal
du.dict.retrieve.tables <- function(api_url, dict_name, dict_version, data_version) {
  beta <- TRUE
  api_url_path <- paste0(api_url, "dictionaries/", dict_name)

  if (!missing(dict_version) && !missing(data_version)) {
    message(" * Check released dictionaries")
    api_url_path <- paste0(api_url, "dictionaries/", dict_name, "/", dict_version, "?ref=", dict_version)
    beta <- FALSE
  }

  dictionaries <- du.get.response.as.dataframe(api_url_path)

  if (any(names(dictionaries) == "message")) {
    stop(paste0("There are no dictionaries avialable in the folder: [ ", dict_name, " ]"))
  }

  tables <- dictionaries %>%
    select("name") %>%
    pmap(function(name) {
      if (!beta) {
        canonical_table_name <- strsplit(name, "_")
        table <- paste0(data_version, "_", canonical_table_name[[1]][3])
      } else {
        table <- path_ext_remove(name)
      }
      return(data.frame(table = table, file_name = name))
    })

  return(tables)
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
du.dict.import <- local(function(project, dictionaries, dict_kind) {
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
})

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
du.match.dict.categories <- local(function(project, dict_kind, table, file_name) {
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
})

#' Get the possible dictionary versions from Github
#'
#' @param dict_kind dictionary kind (can be 'core' or 'outcome')
#' @param dict_version dictionary version (can be 'x_x')
#'
#' @keywords internal
du.populate.dict.versions <- local(function(dict_kind, dict_version) {
  versions <- du.get.response.as.dataframe(paste0(
    ds_upload.globals$api_dict_released_url, "dictionaries/",
    dict_kind, "?ref=", dict_version
  ))

  if (dict_kind == du.enum.dict.kind()$CORE) {
    ds_upload.globals$dictionaries_core <- versions$name
  } else {
    ds_upload.globals$dictionaries_outcome <- versions$name
  }
})


#'
#' Retrieve the right file from download directory
#'
#' @param dict_table a specific table that you want to check
#' @param dict_kind can be 'core' or 'outcome'
#'
#' @importFrom readxl read_xlsx
#'
#' @return a raw version of the dictionary
#'
#' @keywords internal
du.retrieve.dictionaries <- local(function(dict_table, dict_kind) {
  dict_file_list <- list.files(paste(getwd(), "/", dict_kind, sep = ""))

  if (!missing(dict_table)) {
    dict_file_list <- dict_file_list[grep(dict_table, dict_file_list)]
  }

  raw_dict <- list()
  for (file_name in dict_file_list) {
    raw_dict <- rbind(raw_dict, read_xlsx(path = paste(dict_kind, "/", file_name,
      sep = ""
    ), sheet = 1))
  }
  return(as.data.frame(raw_dict))
})
