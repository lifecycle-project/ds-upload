#' Reshape Script for R: LifeCycle Harmonized Data
#'
#' @param upload do you want automatically upload the files to your opal (default = true)
#' @param data_version version of the data you are going to upload into Opal
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param dict_name version of the dictionary
#' @param input_path path for import file
#' @param non_interactive if set to TRUE you will get no questions
#'
#' @importFrom readxl read_xlsx
#'
#' @keywords internal
du.reshape.beta <- local(function(upload = TRUE, data_version, input_format, dict_name, input_path, non_interactive) {
  message("######################################################")
  message("  Start reshaping data                                ")
  message("######################################################")
  message("* Setup: load data and set output directory")
  message("------------------------------------------------------")

  data <- du.read.source.file(input_path, input_format)

  du.check.variables(dict_kind, colnames(data), non_interactive)

  file_prefix <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")

  if (du.enum.table.types()$NONREP %in% dict_name) {
    du.reshape.generate.non.repeated(
      data, upload, du.enum.dict.kind()$BETA, dict_name
    )
  }
  if (du.enum.table.types()$MONTHLY %in% dict_name) {
    du.reshape.generate.monthly.repeated(
      data, upload, du.enum.dict.kind()$BETA, dict_name
    )
  }
  if (du.enum.table.types()$YEARLY %in% dict_name) {
    du.reshape.generate.yearly.repeated(
      data, upload, du.enum.dict.kind()$BETA, dict_name
    )
  }
  if (du.enum.table.types()$WEEKLY %in% dict_name) {
    du.reshape.generate.weekly.repeated(
      data, upload, du.enum.dict.kind()$BETA, dict_name
    )
  }
  if (du.enum.table.types()$TRIMESTER %in% dict_name) {
    du.reshape.generate.trimesterly.repeated(
      data, upload, du.enum.dict.kind()$BETA, dict_name
    )
  }

  message("######################################################")
  message("  Reshaping successfully finished                     ")
  message("######################################################")
})
