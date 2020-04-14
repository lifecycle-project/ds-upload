#' Function that wraps around and bind the populate and reshape processes:
#'
#' @param dict_version version of the data dictionnary to be used
#' @param data_version version of the dataset to be uploaded
#' @param dict_kind can be 'core' or 'outcome'
#' @param cohort_id cohort name
#' @param database_name is the name of the data backend of Opal
#' @param data_input_format format of the database to be reshaped. Can be 'CSV', 'STATA', or 'SAS'
#' @param upload_to_opal Wether to directly upload the reshaped database to the logged in opal server
#' @param data_input_path Path to the to-be-reshaped database
#' @param data_output_path Path where the reshaped databases will be written
#' @param action action to be performed, can be 'reshape', 'populate' or 'all'
#'
#' @export
lc.upload <-
  local(function(dict_version = '2_0',
                 data_version = '1_0',
                 dict_kind = 'core',
                 cohort_id,
                 database_name = 'opal_data',
                 data_input_format = 'CSV',
                 data_input_path,
                 data_output_path = getwd(),
                 action = "all",
                 upload_to_opal = TRUE) {
    
    checkPackageVersion()
    
    message('######################################################')
    message('  Start upload data into Opal')
    message('------------------------------------------------------')
    
    populateDictionaryVersions(dict_kind)
    
    if(upload_to_opal == TRUE) {
      if (!exists('hostname', envir = lifecycle.globals))
        stop('You need to login first, please run lc.login')
      if (!exists('username', envir = lifecycle.globals))
        stop('You need to login first, please run lc.login')
    }
    
    if (missing(cohort_id))
      cohort_id <-
        readline('- Specify cohort identifier (e.g. dnbc): ')
    if (cohort_id == '') {
      stop("No cohort identifier is specified! Program is terminated.")
    } else {
      if (!(cohort_id %in% lifecycle.globals$cohort_ids)) {
        stop(
          'Cohort: [ ',
          cohort_id,
          ' ] is not know LifeCycle project. Please choose from: [ ',
          paste(lifecycle.globals$cohort_ids, collapse = ', '),
          ' ]'
        )
      }
    }
    
    if (missing(data_version)) {
      data_version <-
        readline('- Specify version of cohort data upload (e.g. 1_0): ')
    }
    
    if (dict_version != '' &&
        dict_kind == 'core' &&
        !(dict_version %in% lifecycle.globals$dictionaries_core)) {
      stop(
        'Version: [ ',
        dict_version ,
        ' ] is not available in published data dictionaries. Possible dictionaries are: ',
        paste(lifecycle.globals$dictionaries_core, collapse = ', ')
      )
    } else if (dict_version != '' &&
               dict_kind == 'outcome' &&
               !(dict_version %in% lifecycle.globals$dictionaries_outcome)) {
      stop(
        'Version: [ ',
        dict_version ,
        ' ] is not available in published data dictionaries. Possible dictionaries are: ',
        paste(lifecycle.globals$dictionaries_outcome, collapse = ', ')
      )
    } else {
      if (dict_version == '' && dict_kind == 'core') {
        dict_version <- '2_0'
      } else if (dict_version == '' && dict_kind == 'outcome') {
        dict_version <- '1_0'
      } else if (dict_version == '' && dict_kind == '') {
        stop("No dictionary version or kind is specified. Program is terminated.")
      }
    }
    if (data_version == '' || !checkVersion(data_version)) {
      stop(
        "No data version is specified or the data version does not match syntax: 'number_number'! Program is terminated."
      )
    }
    
    #  Set workingdirectory to user-home
    workdir <- getwd()
    
    # Create temporary workdir and set working directory to it:
    # Generate 15 random strings and check that at least one of them isn't an existing dir
    tempDirectoryName <-
      do.call(paste0, replicate(15, sample(LETTERS, 1, TRUE), FALSE))
    tempDirectoryName <-
      tempDirectoryName[which(!(tempDirectoryName %in% list.files()))]
    
    # And use the first non-existing random string to name our temp folder
    dir.create(paste0(getwd(), '/', tempDirectoryName[1], sep = ""))
    setwd(paste0(getwd(), '/', tempDirectoryName[1], sep = ""))
    
    tryCatch({
      lc.dict.download(dict_version, dict_kind)
      
      if (!(action %in% c("all", "reshape", "populate"))) {
        stop("Unknown action type, please fill in 'populate', 'reshape' or 'all'")
      }
      
      if (action == "all" | action == "populate") {
        lc.populate(dict_version,
                    cohort_id,
                    data_version,
                    database_name,
                    dict_kind)
      }
      
      if (action == "all" | action == "reshape") {
        if (missing(data_input_path)) {
          input_path <- readline('- Specify input path (for your data): ')
        }
        if (missing(data_input_format)) {
          data_input_format <- 'CSV'
        }
        lc.reshape(
          upload_to_opal,
          data_version,
          data_input_format,
          dict_version,
          dict_kind,
          data_input_path,
          data_output_path
        )
      }
    },
    finally = {
      message(" * Reinstate default working directory")
      setwd(workdir)
      if (upload_to_opal == TRUE) {
        message(" * Cleanup temporary directory")
        unlink(tempDirectoryName[1], recursive = T)
      } else {
        message(" * Be advised: you need to cleanup the temporary directories yourself now.")
      }
    })
    
    
  })