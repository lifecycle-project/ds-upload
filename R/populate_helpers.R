#' Create the project with data dictionary version in between
#'
#' @param project prpject resource in Opal
#' @param database_name the database name of the Opal instance (default = opal_data)
#'
#' @importFrom dplyr between
#' @importFrom opalr opal.post
du.dict.project.create <- local(function(project, database_name) {
    canonical_project_name <- strsplit(project, "_")
    dict_kind <- canonical_project_name[[1]][3]
    dict_version <- paste(canonical_project_name[[1]][4], "_", canonical_project_name[[1]][5], 
        sep = "")
    
    message("------------------------------------------------------")
    message(paste("  Start creating project: [ ", project, " ]", sep = ""))
    
    projects <- opal.projects(ds_upload.globals$opal)
    
    if (!(project %in% projects$name)) {
        json <- sprintf("{\"database\":\"%s\",\"description\":\"%s\",\"name\":\"%s\",\"title\":\"%s\"}", 
            database_name, paste("Project for [ ", dict_kind, " ] variables and data dictionary version: [ ", 
                dict_version, " ]", sep = ""), project, project)
        opal.post(ds_upload.globals$opal, "projects", body = json, contentType = "application/x-protobuf+json")
    } else {
        message(paste("* Project: [ ", project, " ] already exists", sep = ""))
    }
})

#' Import the data dictionaries into Opal
#'
#' @param project project in which the data is imported
#' @param dict_version dictionary version (concerning core or outcome)
#' @param dict_kind dictionary kind (core or outcome)
#' @param data_version version of the data (specific to the cohort)
#'
#' @importFrom readxl read_xlsx
du.dict.import <- local(function(project, dict_version, dict_kind, data_version) {
    message("------------------------------------------------------")
    message("  Start importing dictionaries")
    
    files <- du.get.response.as.dataframe(paste0(ds_upload.globals$api_content_url, "/dictionaries/", 
        dict_kind, "/", dict_version, "?ref=", dict_version))
    
    for (f in 1:nrow(files)) {
        file <- files[f, ]
        canonical_table_name <- strsplit(file$name, "_")
        table <- paste(dict_version, "_", dict_kind, "_", data_version, "_", canonical_table_name[[1]][3], 
            "_rep", sep = "")
        
        json_table <- sprintf("{\"entityType\":\"Participant\",\"name\":\"%s\"}", table)
        tables <- opal.tables(ds_upload.globals$opal, project)
        
        if (!(table %in% tables$name)) {
            message(paste("* Create table: [ ", table, " ]", sep = ""))
            opal.post(ds_upload.globals$opal, "datasource", project, "tables", body = json_table, 
                contentType = "application/x-protobuf+json")
        } else {
            message(paste("* Table: [ ", table, " ] already exists", sep = ""))
        }
        
        variables <- read_xlsx(path = paste(getwd(), "/", dict_kind, "/", file$name, 
            sep = ""), sheet = 1)
        categories <- read_xlsx(path = paste(getwd(), "/", dict_kind, "/", file$name, 
            sep = ""), sheet = 2)
        
        du.populate.match.categories(project, table, variables, categories, file$name)
    }
    
    message("  All dictionaries are populated correctly")
})

#' Match the categories with the variables to be import them
#' Import the variables
#'
#' @param project project resource in Opal
#' @param table dictionary to upload to Opal
#' @param variables dictionary variables to upload
#' @param categories dictionary categories to upload
#' @param source_file source file for the dictionaries
#'
#' @importFrom opalr opal.post
#' @importFrom dplyr select %>% nest_join rename
du.populate.match.categories <- local(function(project, table, variables, categories, 
    source_file) {
    # workaround to avoid global variable warnings, check:
    # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
    label <- name <- NULL
    
    variables$entityType <- "Participant"
    variables$isRepeatable <- FALSE
    variables$attributes <- data.frame(namespace = "", name = "label", locale = "", value = variables$label)
    variables <- select(variables, -c(label))
    
    if (nrow(categories) > 0) {
        message(paste("* Matched categories for table: [ ", table, " ]", sep = ""))
        categories <- transform(categories, name = as.character(name))
        categories$attributes <- data.frame(namespace = "", name = "label", locale = "", 
            value = categories$label)
        categories <- select(categories, -c(label))
        variables <- variables %>% nest_join(categories, by = c(name = "variable"))
    }
    
    message(paste("* Import variables into: [ ", table, " ]", sep = ""))
    opal.post(ds_upload.globals$opal, "datasource", project, "table", table, "variables", 
        body = toJSON(variables), contentType = "application/x-protobuf+json")
})

#'
#' Get the possible dictionary versions from Github
#' 
#' @param dict_kind dictionary kind (can be 'core' or 'outcome')
#' @param dict_version dictionary version (can be 'x_x')
#' 
#' @importFrom utils
#'
du.populate.dictionary.versions <- local(function(dict_kind, dict_version) {
    
    versions <- du.get.response.as.dataframe(paste0(ds_upload.globals$api_content_url, "dictionaries/", 
                                                    dict_kind, "?ref=", dict_version))
    
    if (dict_kind == "core") {
        ds_upload.globals$dictionaries_core <- versions$name
    } else {
        ds_upload.globals$dictionaries_outcome <- versions$name
    }
    
})
