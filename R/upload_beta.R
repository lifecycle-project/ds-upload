# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

#' Upload beta dictionaries to your Opal instance
#'
#' @param upload do we need to upload the DataSHIELD backend
#' @param dict_name name of the dictionary located on Github usually something like this: diabetes/test_vars_01
#' @param action action to be performed, can be 'reshape', 'populate' or 'all'
#' @param data_input_path path to the to-be-reshaped data
#' @param data_input_format format of the database to be reshaped. Can be 'CSV', 'STATA', or 'SAS'
#' @param database_name is the name of the data backend of DataSHIELD, default = opal_data
#'
#' @export
du.upload.beta <- function(upload = TRUE, dict_name = "", action = du.enum.action()$ALL, data_input_path = "", data_input_format = du.enum.input.format()$CSV, database_name = "opal_data") {
  du.check.package.version()
  du.check.session(upload)

  tryCatch(
    {
      workdirs <- du.create.temp.workdir()
      du.check.action(action)
      du.dict.download(dict_name = dict_name, dict_kind = du.enum.dict.kind()$BETA)

      if (action == du.enum.action()$ALL | action == du.enum.action()$POPULATE) {
        du.populate.beta(dict_name, database_name)
      }

      if (action == du.enum.action()$ALL | action == du.enum.action()$RESHAPE) {
        if (missing(data_input_path)) {
          input_path <- readline("- Specify input path (for your data): ")
        } else if (missing(data_input_path)) {
          stop("No source file specified, Please specify your source file")
        }
        if (missing(data_input_format)) {
          data_input_format <- du.enum.input.format()$CSV
        }
        du.reshape.beta(
          upload = upload, input_format = data_input_format, dict_name = dict_name, input_path = data_input_path
        )
      }
    },
    finally = {
      du.clean.temp.workdir(upload, workdirs)
    }
  )
}
