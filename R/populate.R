#' Populate your Opal instance with the new version of the data dictionary
#' Involves only the core variables
#'
#' @param dict_version dictionary version
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' @param database_name the database name specified in your Opal instance (defaults to 'opal_data')
#' @param dict_kind dictionnary kind, can be 'core' or 'outcome'
#'
#' @return project id to use in central quality control
#'
#' @noRd
du.populate <- local(function(dict_version, cohort_id, data_version, database_name, dict_kind) {
  message("######################################################")
  message("  Start importing data dictionaries                   ")
  message("######################################################")

  project <- paste0("lc_", cohort_id, "_", dict_kind, "_", dict_version)

  dictionaries <- du.dict.retrieve.tables(ds_upload.globals$api_dict_released_url, dict_kind, dict_version, data_version)

  if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
    armadillo_project <- str_replace_all(cohort_id, "-", "")
    du.armadillo.create.project(cohort_id)
  }

  if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL) {
    du.opal.project.create(project, database_name)
    du.opal.dict.import(project, dictionaries, dict_kind)
  }

  return(project)

  message("######################################################")
  message("  Importing data dictionaries has finished            ")
  message("######################################################")
})

#' Create tables in Opal to import the data for the beta dictionaries
#'
#' @param dict_name dictionary path to search on
#' @param database_name name of the database in Opal
#'
#' @importFrom stringr str_replace_all
#'
#' @return project id to use in central quality control
#'
#' @noRd
du.populate.beta <- function(dict_name, database_name, data_version) {
  project <- paste0("lc_", du.enum.dict.kind()$BETA, "_", dict_name)

  dictionaries <- du.dict.retrieve.tables(api_url = ds_upload.globals$api_dict_beta_url, dict_name = dict_name, data_version = data_version)

  if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
    project <- str_replace_all(dict_name, "-", "")
    project <- str_replace_all(dict_name, "_", "")
    du.armadillo.create.project(project)
  }

  if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL) {
    du.opal.project.create(project, database_name)
    du.opal.dict.import(project, dictionaries, du.enum.dict.kind()$BETA)
  }

  return(project)
}
