# Use environment to store some path variables to use in different functions
ds_upload.globals <- new.env()

#' Uploading methylation data to the DataSHIELD backends
#'
#' @param upload do we need to upload the DataSHIELD backend
#' @param cohort_id cohort name from the dictonary
#' @param action action to be performed, can be 'populate' or 'all'
#' @param methyl_data_input_path path to the methylation data
#' @param covariate_data_input_path path to the covariate data to measure the age
#' @param dict_version version of the dictionary
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
#'   cohort_id = 'gecko',
#'   methyl_data_input_path = "~/path-to-file",
#'   covariate_data_input_path = "~/path-to-file",
#'   dict_version = "2_2",
#'   data_version = "1_0"
#' )
#' }
#'
#' @export
du.upload.methyl.clocks <- function(upload = TRUE, cohort_id, action = du.enum.action()$ALL, methyl_data_input_path = "", covariate_data_input_path = "", dict_version = '2_2', data_version = "1_0", data_format = du.enum.input.format()$CSV, database_name = "opal_data") {
  du.check.package.version()
  du.check.session(upload)

  message("######################################################")
  message("  Start upload methylation data into DataSHIELD backend")
  message("------------------------------------------------------")

  tryCatch(
    {
      workdirs <- du.create.temp.workdir()
      du.check.action(action)
      du.dict.download(dict_version = dict_version, dict_kind = du.enum.dict.kind()$OUTCOME)

      if (action == du.enum.action()$ALL | action == du.enum.action()$POPULATE) {
        project <- du.populate(dict_version = dict_version, cohort_id = cohort_id, data_version = data_version, database_name, dict_kind = du.enum.dict.kind()$OUTCOME)
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
        data_input_format <- data_format

        methyl_yearly_rep <- du.generate.methyl.data(data_format, methyl_data_input_path, covariate_data_input_path)
        methyl_non_rep <- du.generate.methyl.data(data_format, methyl_data_input_path, covariate_data_input_path, type = 'nonrep')

        file_name_yearly <- paste0(format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), "_", "methyl_yearly_rep_", data_version)
        file_name_nonrep <- paste0(format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), "_", "methyl_non_rep_", data_version)
        write_csv(file_name_yearly, paste0(getwd(), "/", file_name_yearly, ".csv"), na = "")
        write_csv(file_name_nonrep, paste0(getwd(), "/", file_name_nonrep, ".csv"), na = "")

        if (upload) {
          if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL) {
            du.login(ds_upload.globals$login_data)
            du.opal.upload(du.enum.dict.kind()$OUTCOME, file_name_yearly)
            du.opal.upload(du.enum.dict.kind()$OUTCOME, file_name_nonrep)
          } else if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
            du.armadillo.import(project = project, data = methyl_yearly_rep, dict_kind = du.enum.dict.kind()$OUTCOME, table_type = data_version)
            du.armadillo.import(project = project, data = methyl_non_rep, dict_kind = du.enum.dict.kind()$OUTCOME, table_type = data_version)
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
#' @param type can be yearly repeated or non-repeated
#'
#' @importFrom readr read_csv
#' @importFrom tibble add_column
#' @importFrom RCurl url.exists
#'
#' @return the generated clocks with converted columns for child_id and the age_measured attached
#'
#' @noRd
du.generate.methyl.data <- function(data_format, methyl_data_input_path, covariate_data_input_path, type = 'yearly') {
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
  
  age <- covariate_data$Age

  if(type == 'yearly') {
    message("* Generate: DNA methylation age")
    data <- methylclock::DNAmAge(x = methyl_data, age = age)
  } else {
    message("* Generate: DNA methylation gestational age")
    data <- methylclock::DNAmGA(x = methyl_data, age = age)
  }

  colnames(data)[colnames(data) == "id"] <- "child_id"

  row_id = seq.int(nrow(data))
  data <- add_column(data, row_id, .before = 1)

  return(data)
}
