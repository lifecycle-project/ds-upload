# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

#' Upload beta dictionaries to your Opal instance
#'
#' @param upload do we need to upload the DataSHIELD backend
#' @param dict_name name of the dictionary located on Github usually something like this: diabetes/test_vars_01
#' @param action action to be performed, can be 'reshape', 'populate' or 'all'
#' @param data_input_path path to the to-be-reshaped data
#' @param data_input_format format of the database to be reshaped. Can be 'CSV', 'STATA', or 'SAS'
#'
#' @export
du.upload.beta <- local(function(upload = TRUE, dict_name = "", action = "all", data_input_path = "", data_input_format = "CSV") {
  du.check.package.version()
  du.check.session(upload)

  tryCatch(
    {
      dict_kind <- "beta"
      du.dict.download(dict_version, dict_kind)
      du.check.action(action)
      workdirs <- du.create.temp.workdir(upload, dict_kind)

      if (action == "all" | action == "populate") {
        du.populate.beta(dict_version, cohort_id, data_version, database_name, dict_kind)
      }

      if (action == "all" | action == "reshape") {
        if (missing(data_input_path)) {
          input_path <- readline("- Specify input path (for your data): ")
        } else if (missing(data_input_path)) {
          stop("No source file specified, Please specify your source file")
        }
        if (missing(data_input_format)) {
          data_input_format <- "CSV"
        }
        du.reshape.beta(
          upload_to_opal, data_version, data_input_format, dict_version,
          dict_kind, data_input_path
        )
      }
    },
    finally = {
      du.clean.temp.workdir(upload, workdirs)
    }
  )
})
