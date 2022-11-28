#' Reshape: harmonized data
#'
#' @param upload do you want automatically upload the files to your opal (default = true)
#' @param data_version version of the data you are going to upload into Opal
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param dict_version version of the dictionary
#' @param dict_kind kind of data to reshape (default = core)
#' @param input_path path for import file
#' @param run_mode default = NORMAL, can be TEST and NON_INTERACTIIVE
#'
#' @importFrom readxl read_xlsx
#'
#' @noRd
du.reshape <- function(upload = TRUE, project, data_version, input_format, dict_version, dict_kind, input_path, run_mode) {
  message("######################################################")
  message("  Start converting and uploading data                 ")
  message("######################################################")
  message("* Setup: load data and set output directory")
  message("------------------------------------------------------")
  
  data <- du.read.source.file(input_path, input_format)
  du.check.variables(dict_kind, colnames(data), run_mode)
  reshaped_data <- du.reshape.data(data, dict_kind)
  driver <- ds_upload.globals$login_data$driver
  
  if (upload && driver == du.enum.backends()$ARMADILLO) {
    for (table_type in names(reshaped_data)) {
      du.upload.to.armadillo(project = project, 
                             data = reshaped_data[[table_type]], 
                             dict_kind = dict_kind, 
                             dict_version = dict_version, 
                             data_version = data_version, 
                             table_type = table_type)
    }
  } else if (upload && driver == du.enum.backends()$OPAL) {
    file_names <- du.create.file.names(data_version)
    for (table_type in names(reshaped_data)) {
      du.upload.to.opal(data = reshaped_data[[table_type]], 
                        file_name = file_names[table_type], 
                        dict_kind = dict_kind)
    }
  } else if (!upload) {
    file_names <- du.create.file.names(data_version)
    for (table_type in names(reshaped_data)) {
      du.save.as.Rdata(reshaped_data[[table_type]], file_names[table_type])
    }
  } else {
    stop("Unsupported backend: ", driver)
  }

  message("######################################################")
  message("  Converting and import successfully finished         ")
  message("######################################################")
}


#' @noRd
du.reshape.data <- function(data, dict_kind) {
  reshaped_data <- list(
    du.reshape.generate.non.repeated(data, dict_kind),
    du.reshape.generate.weekly.repeated(data, dict_kind),
    du.reshape.generate.monthly.repeated(data, dict_kind),
    du.reshape.generate.trimesterly.repeated(data, dict_kind),
    du.reshape.generate.yearly.repeated(data, dict_kind)
  )
  names(reshaped_data) <- du.enum.table.types()
  
  reshaped_data
}


#' @noRd
du.create.file.names <- function(data_version) {
  prefix <- paste0(format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), "_", data_version, "_")
  
  file_names <- c(
    paste0(prefix, "non_repeated_measures"),
    paste0(prefix, "weekly_repeated_measures"),
    paste0(prefix, "monthly_repeated_measures"),
    paste0(prefix, "trimesterly_repeated_measures"),
    paste0(prefix, "yearly_repeated_measures")
  )
  names(file_names) <- du.enum.table.types()
  
  file_names
}


#' @noRd
du.upload.to.armadillo <- function(project, data, dict_kind, dict_version, data_version, table_type) {
  if (is.null(data)) return()
  
  metadata <- du.retrieve.full.dict(table_type, dict_kind)
  enriched_data <- du.add.metadata(data, metadata)
  du.armadillo.import(project = project, data = enriched_data, dict_version, dict_kind, data_version, table_type)
}


#' @noRd
du.upload.to.opal <- function(data, file_name, dict_kind) {
  if (is.null(data)) return()
  
  write_csv(data, paste0(getwd(), "/", file_name, ".csv"), na = "")
  du.opal.upload(dict_kind, file_name)
}


#' @noRd
du.save.as.Rdata <- function(data, file_name) {
  if (is.null(data)) return()
  save(nonrep_data, file = paste0(getwd(), "/", file_name_nonrep, ".RData"))
}
