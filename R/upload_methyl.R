# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

#' Uploading methylation data to the DataSHIELD backends
#'
#' @param upload do we need to upload the DataSHIELD backend
#' @param dict_name name of the dictionary located on Github usually something like this: diabetes/test_vars_01
#' @param action action to be performed, can be 'populate' or 'all'
#' @param methyl_data_input_path path to the methylation data
#' @param covariate_data_input_path path to the covariate data to measure the age
#' @param data_version version of the raw data
#' @param data_format can be CSV or RData
#' @param database_name is the name of the data backend of DataSHIELD, default = opal_data
#'
#' @importFrom readr read_csv write_csv
#'
#' @examples
#'
#' \dontrun{
#' du.upload.methyl.clocks(
#'   dict_name = "methylation_clocks",
#'   methyl_data_input_path = "~/path-to-file",
#'   covariate_data_input_path = "~/path-to-file",
#'   data_version = "1_0"
#' )
#' }
#'
#' @export
du.upload.methyl.clocks <- function(upload = TRUE, dict_name = "", action = du.enum.action()$ALL, methyl_data_input_path = "", covariate_data_input_path = "", data_version = "1_0", data_format = du.enum.input.format()$CSV, database_name = "opal_data") {
  du.check.package.version()
  du.check.session(upload)

  message("######################################################")
  message("  Start upload BETA data into DataSHIELD backend")
  message("------------------------------------------------------")

  tryCatch(
    {
      workdirs <- du.create.temp.workdir()
      du.check.action(action)
      du.dict.download(dict_name = dict_name, dict_kind = du.enum.dict.kind()$BETA)

      if (action == du.enum.action()$ALL | action == du.enum.action()$POPULATE) {
        project <- du.populate.beta(dict_name, database_name)
      }
      
      if (action == du.enum.action()$ALL) {
        if (missing(methyl_data_input_path)) {
          input_path <- readline("- Specify input path (for your methylation data): ")
        } else if (missing(methyl_data_input_path)) {
          stop("No source file for methylation data specified, please specify your source for methylation data file")
        }
        if (missing(covariate_data_input_path)) {
          input_path <- readline("- Specify input path (for your covoriate data): ")
        } else if (missing(covariate_data_input_path)) {
          stop("No source file for covariate data specified, please specify your source for covariate data file")
        }
        data_input_format <- du.enum.input.format()$CSV

        data <- du.generate.methyl.data(data_format, methyl_data_input_path, covariate_data_input_path)

        file_name <- paste0(format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), "_", dict_name, "_", data_version)
        write_csv(data, paste0(getwd(), "/", file_name, ".csv"), na = "")

        if (upload) {
          if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL) {
            du.opal.upload(du.enum.dict.kind()$BETA, file_name)
          }
          if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
            du.armadillo.import(project = project, data = data, dict_kind = du.enum.dict.kind()$BETA, table_type = data_version)
          }
        }
      }
    },
    finally = {
      du.clean.temp.workdir(upload, workdirs)
    }
  )
}

#' Generate the actual clocks.
#' 
#' Make sure you have an "Age" columns in the covariate data. It needs to be spelled exactly like that.
#' 
#' @param data_format can be CSV or Rdata
#' @param methyl_data_input_path input path of the raw methylation data
#' @param covariate_data_input_path input path of the covariate data (this can be used to determine the ages of the methylation clocks)
#'
#' @importFrom readr read_csv
#' @importFrom tibble add_column
#' @importFrom RCurl url.exists
#'
#' @return the generated clocks with converted columns for child_id and the age_measured attached
#'
#' @noRd
du.generate.methyl.data <- function(data_format, methyl_data_input_path, covariate_data_input_path) {
  requireNamespace("methylclock")
  
  if(data_format == du.enum.input.format()$CSV) {
    if(url.exists(methyl_data_input_path) & url.exists(covariate_data_input_path)) {
      methyl_data <- read_csv(url(methyl_data_input_path))
      covariate_data <- read_csv(url(covariate_data_input_path))
    } else {
      methyl_data <- read_csv(methyl_data_input_path)
      covariate_data <- read_csv(covariate_data_input_path)
    }
  } else {
    methyl_data <- load(methyl_data_input_path)
    covariate_data <- load(covariate_data_input_path) 
  }

  data <- methylclock::DNAmAge(methyl_data, age = covariate_data$Age, cell.count = FALSE)

  colnames(data)[colnames(data) == "id"] <- "child_id"

  row_id = seq.int(nrow(data))
  data <- add_column(data, row_id, before = 1)

  return(data)
}
