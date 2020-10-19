#' Reshape Script for R: LifeCycle Harmonized Data
#'
#' @param upload do you want automatically upload the files to your opal (default = true)
#' @param data_version version of the data you are going to upload into Opal
#' @param dict_name version of the dictionary
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param data_input_path path for import file
#' @param non_interactive if set to TRUE you will get no questions
#'
#' @importFrom readxl read_xlsx
#'
#' @keywords internal
du.reshape.beta <- function(upload, data_version, input_format, dict_name, input_path, non_interactive) {
  message("######################################################")
  message("  Start reshaping data                                ")
  message("######################################################")
  message("* Setup: load data and set output directory")
  message("------------------------------------------------------")

  data <- du.read.source.file(input_path, input_format)

  du.check.variables(du.enum.dict.kind()$BETA, colnames(data), non_interactive)
  
  data_file_name <- paste0(format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), "_", dict_name)

  if (grepl(du.enum.table.types()$NONREP, dict_name, fixed=TRUE)) {
    du.reshape.generate.non.repeated(
      data, upload, du.enum.dict.kind()$BETA, data_file_name
    )
  }
  if (grepl(du.enum.table.types()$MONTHLY, dict_name, fixed=TRUE)) {
    du.reshape.generate.monthly.repeated(
      data, upload, du.enum.dict.kind()$BETA, data_file_name
    )
  }
  if (grepl(du.enum.table.types()$YEARLY, dict_name, fixed=TRUE)) {
    du.reshape.generate.yearly.repeated(
      data, upload, du.enum.dict.kind()$BETA, data_file_name
    )
  }
  if (grepl(du.enum.table.types()$WEEKLY, dict_name, fixed=TRUE)) {
    du.reshape.generate.weekly.repeated(
      data, upload, du.enum.dict.kind()$BETA, data_file_name
    )
  }
  if (grepl(du.enum.table.types()$TRIMESTER, dict_name, fixed=TRUE)) {
    du.reshape.generate.trimesterly.repeated(
      data, upload, du.enum.dict.kind()$BETA, data_file_name
    )
  }

  message("######################################################")
  message("  Reshaping successfully finished                     ")
  message("######################################################")
}
