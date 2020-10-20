#' Populate your Opal instance with the new version of the data dictionary
#' Involves only the core variables
#'
#' @param dict_version dictionary version
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' @param database_name the database name specified in your Opal instance (defaults to 'opal_data')
#' @param dict_kind dictionnary kind, can be 'core' or 'outcome'
#'
#' @keywords internal
du.populate <- local(function(dict_version, cohort_id, data_version, database_name, dict_kind) {
  message("######################################################")
  message("  Start importing data dictionaries                   ")
  message("######################################################")

  project <- paste("lc_", cohort_id, "_", dict_kind, "_", dict_version, sep = "")

  du.project.create(project, database_name)

  dictionaries <- du.dict.retrieve.tables(ds_upload.globals$api_dict_released_url, dict_kind, dict_version, data_version)

  du.dict.import(project, dictionaries, dict_kind)

  message("######################################################")
  message("  Importing data dictionaries has finished            ")
  message("######################################################")
})

#' Create tables in Opal to import the data for the beta dictionaries
#'
#' @param dict_name dictionary path to search on
#' @param database_name name of the database in Opal
#'
#' @keywords internal
du.populate.beta <- local(function(dict_name, database_name) {
  project <- paste0("lc_", du.enum.dict.kind()$BETA, "_", dict_name)

  du.project.create(project, database_name)

  dictionaries <- du.dict.retrieve.tables(ds_upload.globals$api_dict_beta_url, dict_name)

  du.dict.import(project, dictionaries, du.enum.dict.kind()$BETA)
})
