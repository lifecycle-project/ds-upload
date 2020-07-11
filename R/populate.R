# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

#'
#' Get the possible dictionary versions from Github
#' 
#' @param dict_kind dictionary kind (can be 'core' or 'outcome')
#' @param dict_version dictionary version (can be 'x_x')
#' 
#' @importFrom utils packageVersion
#'
du.populate.dictionary.versions <- local(function(dict_kind, dict_version) {
    
    ds_upload.globals$package_tag <- packageVersion(packageName())
    
    versions <- du.get.response.as.dataframe(paste0(ds_upload.globals$api_content_url, "/dictionaries/", 
                                             dict_kind, "?ref=", dict_version))
    
    if (dict_kind == "core") {
        ds_upload.globals$dictionaries_core <- versions$name
    } else {
        ds_upload.globals$dictionaries_outcome <- versions$name
    }
    
})

#' Populate your Opal instance with the new version of the data dictionary
#' Involves only the core variables
#'
#' @param dict_version dictionary version
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' @param database_name the database name specified in your Opal instance (defaults to 'opal_data')
#' @param dict_kind dictionnary kind, can be 'core' or 'outcome'
#'
du.populate <- local(function(dict_version, cohort_id, data_version, database_name, dict_kind) {
    message("######################################################")
    message("  Start importing data dictionaries                   ")
    message("######################################################")
    
    project <- paste("lc_", cohort_id, "_", dict_kind, "_", dict_version, sep = "")
    
    du.dict.project.create(project, database_name)
    du.dict.import(project, dict_version, dict_kind, data_version)
    
    message("######################################################")
    message("  Importing data dictionaries has finished            ")
    message("######################################################")
})
