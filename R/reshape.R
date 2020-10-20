#' Reshape Script for R: LifeCycle Harmonized Data
#'
#' @param upload do you want automatically upload the files to your opal (default = true)
#' @param data_version version of the data you are going to upload into Opal
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param dict_version version of the dictionary
#' @param dict_kind kind of data to reshape (default = core)
#' @param input_path path for import file
#' @param non_interactive if set to TRUE you will get no questions
#'
#' @importFrom readxl read_xlsx
#'
#' @keywords internal
du.reshape <- function(upload = TRUE, data_version, input_format, dict_version, dict_kind, input_path, non_interactive) {
  message("######################################################")
  message("  Start reshaping data                                ")
  message("######################################################")
  message("* Setup: load data and set output directory")
  message("------------------------------------------------------")

  data <- du.read.source.file(input_path, input_format)

  du.check.variables(dict_kind, colnames(data), non_interactive)

  file_prefix <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")

  file_name_nonrep <- paste0(file_prefix, "_", data_version, "_", "non_repeated_measures")
  file_name_monthly <- paste0(file_prefix, "_", data_version, "_", "monthly_repeated_measures")
  file_name_yearly <- paste0(file_prefix, "_", data_version, "_", "yearly_repeated_measures")

  du.reshape.generate.non.repeated(
    data, upload,
    dict_kind, file_name_nonrep
  )
  du.reshape.generate.yearly.repeated(
    data, upload, dict_kind, file_name_yearly
  )
  du.reshape.generate.monthly.repeated(
    data, upload, dict_kind, file_name_monthly
  )

  if (dict_kind == du.enum.dict.kind()$OUTCOME) {
    file_name_weekly <- paste0(file_prefix, "_", data_version, "_", "weekly_repeated_measures")
    du.reshape.generate.weekly.repeated(
      data, upload, dict_kind, file_name_weekly
    )
  }

  if (dict_kind == du.enum.dict.kind()$CORE & dict_version != "1_0") {
    file_name_trimester <- paste0(file_prefix, "_", data_version, "_", "trimester_repeated_measures")
    du.reshape.generate.trimesterly.repeated(
      data, upload, dict_kind, file_name_trimester
    )
  }

  message("######################################################")
  message("  Reshaping successfully finished                     ")
  message("######################################################")
}
