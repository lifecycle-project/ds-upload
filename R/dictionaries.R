#' Download all released data dictionaries
#'
#' @param dict_version dictionary version
#' @param dict_kind dictionary kind (possible kinds are 'core' or 'outcome')
#'
#' @importFrom purrr map pluck
#' @importFrom utils download.file packageVersion
#'
#' @keywords internal
du.dict.download.releases <- local(function(dict_version, dict_kind) {
  message("######################################################")
  message("  Start download dictionaries")
  message("------------------------------------------------------")

  dir.create(dict_kind)

  dictionaries <- du.get.response.as.dataframe(paste0(
    ds_upload.globals$api_dict_released_url, "dictionaries/",
    dict_kind, "/", dict_version, "?ref=", dict_version
  ))

  dictionaries %>%
    pluck(c("name", "download_url")) %>%
    map(function(name, download_url) {
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
#' @importFrom purrr map pluck
#'
#' @return dictionaries list of tables
#'
#' @keywords internal
du.dict.retrieve.tables <- function(api_url, dict_name, dict_version, data_version) {
  api_url_path <- paste0(
    api_url, "dictionaries/",
    dict_name
  )

  if (!missing(dict_version)) {
    api_url_path <- paste0(api_url_path, "?ref=", dict_version)
  }

  dictionaries <- du.get.response.as.dataframe(api_url_path)

  tables <- dictionaries %>%
    pluck("name") %>%
    map(function(name) {
      canonical_table_name <- strsplit(name, "_")
      print(canonical_table_name)
      return(paste0(
        data_version, "_", canonical_table_name[[1]][3]
      ))
    })

  return(tables)
}


#' Import the data dictionaries into Opal
#'
#' @param project project in which the data is imported
#' @param dictionaries all the dictionaries pulled from the repository
#' @param data_version data version to put into the table
#'
#' @importFrom readxl read_xlsx
#' @importFrom purrr map
#'
#' @keywords internal
du.dict.import <- local(function(project, dictionaries, data_version) {
  message("------------------------------------------------------")
  message("  Start importing dictionaries")

  dictionaries %>% map(function(table) {
    json_table <- sprintf("{\"entityType\":\"Participant\",\"name\":\"%s\"}", table)
    tables <- opal.tables(ds_upload.globals$opal, project)

    if (!(table %in% tables$name)) {
      message(paste("* Create table: [ ", table, " ]", sep = ""))
      opal.post(ds_upload.globals$opal, "datasource", project, "tables",
        body = json_table,
        contentType = "application/x-protobuf+json"
      )
    } else {
      message(paste("* Table: [ ", table, " ] already exists", sep = ""))
    }

    du.match.dict.categories(project, dict_kind, table)
  })

  message("  All dictionaries are populated correctly")
})

#' Match the categories with the variables to be import them
#' Import the variables
#'
#' @param project project resource in Opal
#' @param table dictionary to upload to Opal
#' @param source_file source file for the dictionaries
#'
#' @importFrom opalr opal.post
#' @importFrom dplyr select %>% nest_join rename
#'
#' @keywords internal
du.match.dict.categories <- local(function(project, dict_kind, table) {
  # workaround to avoid global variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  label <- name <- NULL

  variables <- read_xlsx(path = paste0(getwd(), "/", dict_kind, "/", table, ".xlsx"), sheet = 1)
  categories <- read_xlsx(path = paste0(getwd(), "/", dict_kind, "/", table, , ".xlsx"), sheet = 2)

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
  opal.post(ds_upload.globals$opal, "datasource", project, "table", table, "variables",
    body = toJSON(variables), contentType = "application/x-protobuf+json"
  )
})

#' Get the possible dictionary versions from Github
#'
#' @param dict_kind dictionary kind (can be 'core' or 'outcome')
#' @param dict_version dictionary version (can be 'x_x')
#'
#' @keywords internal
du.populate.dictionary.versions <- local(function(dict_kind, dict_version) {
  versions <- du.get.response.as.dataframe(paste0(
    ds_upload.globals$api_dict_released_url, "dictionaries/",
    dict_kind, "?ref=", dict_version
  ))

  if (dict_kind == "core") {
    ds_upload.globals$dictionaries_core <- versions$name
  } else {
    ds_upload.globals$dictionaries_outcome <- versions$name
  }
})
