#' Generate clocks for uploading to Opal
#' 
#' @param upload do we need to upload the DataSHIELD backend
#' @param dict_name name of the dictionary located on Github usually something like this: diabetes/test_vars_01
#' @param action action to be performed, can be 'reshape', 'populate' or 'all'
#' @param data_input_path path to the methylation data
#' @param age_when_measured age of the child when the measurement took place (in months)
#' @param database_name is the name of the data backend of DataSHIELD, default = opal_data
#' 
#' @importFrom readr read_csv write_csv
#' 
#' @examples
#'  \dontrun{
#' du.upload.methyl.clocks(
#'   upload = TRUE,
#'   dict_name = "methylation",
#'   data_input_path = "https://github.com/isglobal-brge/methylclock/blob/master/inst/extdata/MethylationDataExample55.csv?raw=true",
#'   age_when_measured = 44
#' )
#' }
#' 
#' @export
du.upload.methyl.clocks <- function(upload = TRUE, dict_name = "", action = du.enum.action()$ALL, data_input_path = "", database_name = "opal_data") {
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
      
      if (action == du.enum.action()$ALL | action == du.enum.action()$RESHAPE) {
        if (missing(data_input_path)) {
          input_path <- readline("- Specify input path (for your data): ")
        } else if (missing(data_input_path)) {
          stop("No source file specified, Please specify your source file")
        }
        if (missing(data_input_format)) {
          data_input_format <- du.enum.input.format()$CSV
        }
        
        
        data <- du.generate.methyl_data(data_input_path)
        
        file_name <- paste0(format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), "_", dict_name)
        write_csv(data, paste0(getwd(), "/", file_name, ".csv"), na = "")
        
        if (upload) {
          if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL) {
            du.opal.upload(du.enum.dict.kind()$BETA, file_name)
          }
          if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
            du.armadillo.import(project = project, data = data, dict_kind = du.enum.dict.kind()$BETA, table_type = table_type)
          }
        }
      }
    },
    finally = {
      du.clean.temp.workdir(upload, workdirs)
    }
  
  return(output)
}

#' Generate the actual clocks
#'
#' @param data_input_path input path of the raw methylation data
#' 
#' @noRd
du.generate.methyl.data <- function(data_input_path) {
  requireNamespace("methylclock")
  
  methyl_data <- read_csv(data_input_path)
  
  output <- methylclock::DNAmAge(methylationData)
  
  colnames(output)[colnames(output) == 'id'] <- 'child_id'
  
  output <- cbind(row_id = seq.int(nrow(output)), output)
  
  return(output)
}


  
  
  
  