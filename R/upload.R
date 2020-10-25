# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

#' Upload dictionaries and data into the DataSHIELD backend.
#'
#' @param dict_version version of the data dictionary to be used
#' @param data_version version of the dataset to be uploaded
#' @param dict_kind can be 'core' or 'outcome'
#' @param cohort_id cohort name
#' @param database_name is the name of the data backend of DataSHIELD, default = opal_data
#' @param data_input_format format of the database to be reshaped. Can be 'CSV', 'STATA', or 'SAS'
#' @param upload directly upload the reshaped database to the logged in DataSHIELD server
#' @param data_input_path path to the to-be-reshaped data
#' @param action action to be performed, can be 'reshape', 'populate' or 'all'
#' @param non_interactive if set to TRUE you will get no questions
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
du.upload <- function(dict_version = "2_1", data_version = "1_0", dict_kind = du.enum.dict.kind()$CORE,
                            cohort_id, database_name = "opal_data", data_input_format = du.enum.input.format()$CSV, data_input_path,
                            action = du.enum.action()$ALL, upload = TRUE, non_interactive = FALSE) {
  du.check.package.version()

  message("######################################################")
  message("  Start upload data into DataSHIELD backend")
  message("------------------------------------------------------")

  du.populate.dict.versions(dict_kind, dict_version)

  du.check.session(upload)

  if (missing(cohort_id) & !non_interactive) {
    cohort_id <- readline("- Specify cohort identifier (e.g. dnbc): ")
  }
  if (cohort_id == "") {
    stop("No cohort identifier is specified! Program is terminated.")
  } else {
    if (!(cohort_id %in% du.enum.cohorts())) {
      stop(
        "Cohort: [ ", cohort_id, " ] is not know LifeCycle project. Please choose from: [ ",
        paste(du.enum.cohorts(), collapse = ", "), " ]"
      )
    }
  }

  if (missing(data_version) & !non_interactive) {
    data_version <- readline("- Specify version of cohort data upload (e.g. 1_0): ")
  }

  if (dict_version != "" && dict_kind == du.enum.dict.kind()$CORE && !(dict_version %in% ds_upload.globals$dictionaries_core)) {
    stop(
      "Version: [ ", dict_version, " ] is not available in published data dictionaries. Possible dictionaries are: ",
      paste(ds_upload.globals$dictionaries_core, collapse = ", ")
    )
  } else if (dict_version != "" && dict_kind == du.enum.dict.kind()$OUTCOME && !(dict_version %in% ds_upload.globals$dictionaries_outcome)) {
    stop(
      "Version: [ ", dict_version, " ] is not available in published data dictionaries. Possible dictionaries are: ",
      paste(ds_upload.globals$dictionaries_outcome, collapse = ", ")
    )
  } else {
    if (dict_version == "" && dict_kind == du.enum.dict.kind()$CORE) {
      dict_version <- "2_1"
    } else if (dict_version == "" && dict_kind == du.enum.dict.kind()$OUTCOME) {
      dict_version <- "1_1"
    } else if (dict_version == "" && dict_kind == "") {
      stop("No dictionary version or kind is specified. Program is terminated.")
    }
  }
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
        du.populate(dict_version, cohort_id, data_version, database_name, dict_kind)
      }

      if (action == du.enum.action()$ALL | action == du.enum.action()$RESHAPE) {
        if (missing(data_input_path) & !non_interactive) {
          input_path <- readline("- Specify input path (for your data): ")
        } else if (missing(data_input_path) & non_interactive) {
          stop("No source file specified, Please specify your source file")
        }
        if (missing(data_input_format)) {
          data_input_format <- du.enum.input.format()$CSV
        }
        du.reshape(
          upload, data_version, data_input_format, dict_version,
          dict_kind, data_input_path, non_interactive
        )
      }
    },
    finally = {
      du.clean.temp.workdir(upload, workdirs)
    }
  )
}
