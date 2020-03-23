# Use environment to store some path variables to use in different functions
lifecycle.globals <- new.env()

#' Populate your Opal instance with the new version of the data dictionary
#' Involves only the core variables
#'
#' @param dict_version dictionary version (possible dictionaries are: 1_0, 2_0 / default = 2_0)
#' @param cohort_id cohort identifier (possible values are: 'dnbc', 'gecko', 'alspac', 'genr', 'moba', 'sws', 'bib', 'chop', 'elfe', 'eden', 'ninfea', 'hbcs', 'inma', 'isglobal', 'nfbc66', 'nfbc86', 'raine', 'rhea')
#' @param data_version version of the data (specific to the cohort)
#' @param database_name the database name specified in your Opal instance (defaults to 'opal_data')
#' @param dict_kind dictionnary kind, can be 'core' or 'outcome'
#'
lc.populate <-
  local(function(dict_version,
                 cohort_id,
                 data_version,
                 database_name,
                 dict_kind) {
    message('######################################################')
    message('  Start importing data dictionaries                   ')
    message('######################################################')
    
    project <-
      paste('lc_', cohort_id, '_', dict_kind, '_', dict_version, sep = '')
    
    lc.dict.project.create(project, database_name)
    lc.dict.import(project, dict_version, dict_kind, data_version)
    
    message('######################################################')
    message('  Importing data dictionaries has finished            ')
    message('######################################################')
  })
