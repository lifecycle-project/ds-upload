# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

#' Upload dictionaries and data into the DataSHIELD backend.
#'
#' @param dict_version version of the data dictionary to be used
#' @param data_version version of the dataset to be uploaded
#' @param dict_kind can be 'core' or 'outcome'
#' @param cohort_id cohort name: [du.enum.cohorts]
#' @param database_name is the name of the data backend of DataSHIELD, default = opal_data
#' @param data_input_format format of the database to be reshaped. Can be [du.enum.input.format]
#' @param upload directly upload the reshaped database to the logged in DataSHIELD server, TRUE or FALSE
#' @param data_input_path path to the to-be-uploaded data
#' @param action action to be performed, can be [du.enum.action]
#' @param run_mode default = NORMAL, [du.enum.run.mode]
#' @param override_project overrides the generated project name
#'
#' @examples
#' \dontrun{
#' du.upload(
#'   data_input_format = "CSV",
#'   data_input_path = "~/path-to-file/all_measurements_v1_2.csv",
#'   data_version = "1_0",
#'   dict_version = "2_1",
#'   cohort_id = "gecko"
#' )
#' }
#'
#' @export
du.upload <- function(dict_version, data_version = "1_0", dict_kind,
                      cohort_id, database_name = "opal_data", data_input_format = du.enum.input.format()$CSV, data_input_path,
                      action = du.enum.action()$ALL, upload = TRUE, run_mode = du.enum.run.mode()$NORMAL, override_project = NULL) {
  message("######################################################")
  message("  Start upload data into DataSHIELD backend")
  message("------------------------------------------------------")
  
  du.check.package.version()
  du.check.session(upload)
  du.populate.dict.versions()
  
  ds_upload.globals$run_mode <- run_mode

  if (missing(cohort_id) & run_mode != du.enum.run.mode()$NON_INTERACTIVE) {
    cohort_id <- readline("- Specify cohort identifier (e.g. dnbc): ")
  }
  if (cohort_id == "") {
    stop("No cohort identifier is specified! Program is terminated.")
  } else {
    if (!(cohort_id %in% du.enum.cohorts())) {
      stop(
        "Cohort: [ ", cohort_id, " ] is not a known cohort in the network. Please choose from: [ ",
        paste(du.enum.cohorts(), collapse = ", "), " ]"
      )
    }
  }

  if (missing(data_version) & run_mode != du.enum.run.mode()$NON_INTERACTIVE) {
    data_version <- readline("- Specify version of cohort data upload (e.g. 1_0): ")
  }

  dict_version <- du.validate.dict.version(dict_kind, dict_version)

  if (data_version == "" || !du.check.version(data_version)) {
    stop("No data version is specified or the data version does not match syntax: 'number_number'! Program is terminated.")
  }

  workdirs <- NULL
  tryCatch(
    {
      workdirs <- du.create.temp.workdir()
      du.dict.download(dict_version = dict_version, dict_kind = dict_kind)
      du.check.action(action)

      if ((action == du.enum.action()$ALL | action == du.enum.action()$POPULATE) && upload == TRUE) {
        project <- du.populate(dict_version, cohort_id, data_version, database_name, dict_kind, override_project)
      }

      if (action == du.enum.action()$ALL | action == du.enum.action()$RESHAPE) {
        if (missing(data_input_path) & run_mode != du.enum.run.mode()$NON_INTERACTIVE) {
          input_path <- readline("- Specify input path (for your data): ")
        } else if (missing(data_input_path) & run_mode == du.enum.run.mode()$NON_INTERACTIVE) {
          stop("No source file specified, Please specify your source file")
        }
        if (missing(data_input_format)) {
          data_input_format <- du.enum.input.format()$CSV
        }
        du.reshape(
          upload, project, data_version, data_input_format, dict_version,
          dict_kind, data_input_path, run_mode
        )
      }
    },
    finally = {
      du.clean.temp.workdir(upload, workdirs)
    }
  )
}

du.validate.dict.version <- function(dict_kind, dict_version) {
  if (missing(dict_kind) || du.is.empty(dict_kind)) {
    stop("You must specify a dictionary kind")
  }
  
  if (!missing(dict_version) && !du.is.empty(dict_version))
  {
    if (!(dict_version %in% ds_upload.globals$dictionaries[[dict_kind]])){
      stop(
        "Version: [ ", dict_version, " ] is not available in published data dictionaries for [ ", dict_kind, " ]. Possible dictionaries are: ",
        paste(ds_upload.globals$dictionaries[[dict_kind]], collapse = ", ")
      )
    } else {
      dict_version
    }
  } else {
    latest_version_index <- length(ds_upload.globals$dictionaries[[dict_kind]])
    latest_version <- ds_upload.globals$dictionaries[[dict_kind]][latest_version_index]
    message(" * No dictionary version specified. Using latest: [ ", latest_version, " ]")
    latest_version
  }
}
