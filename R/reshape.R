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

  file_prefix <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")

  file_name_nonrep <- paste0(file_prefix, "_", data_version, "_", "non_repeated_measures")
  file_name_monthly <- paste0(file_prefix, "_", data_version, "_", "monthly_repeated_measures")
  file_name_yearly <- paste0(file_prefix, "_", data_version, "_", "yearly_repeated_measures")

  nonrep_data <- du.reshape.generate.non.repeated(
    data, dict_kind
  )
  #if (!is.null(nonrep_data)) {write_csv(nonrep_data, paste0(getwd(), "/", file_name_nonrep, ".csv"), na = "")} 
  if (!is.null(nonrep_data)) write_csv(nonrep_data, paste0(getwd(), "/", file_name_nonrep, ".csv"), na = "")
  yearlyrep_data <- du.reshape.generate.yearly.repeated(
   data, dict_kind
  )
  if (!is.null(yearlyrep_data)) write_csv(yearlyrep_data, paste0(getwd(), "/", file_name_yearly, ".csv"), na = "")
  #monthlyrep_data <- du.reshape.generate.monthly.repeated(
  # data, dict_kind
  #)
  #if (!is.null(monthlyrep_data)) write_csv(monthlyrep_data, paste0(getwd(), "/", file_name_monthly, ".csv"), na = "")
  if (exists('monthlyrep_data')) {
    write_csv(monthlyrep_data, paste0(getwd(), "/", file_name_monthly, ".csv"), na = "")
  }

  if (dict_kind == du.enum.dict.kind()$OUTCOME) {
    file_name_weekly <- paste0(file_prefix, "_", data_version, "_", "weekly_repeated_measures")
    weeklyrep_data <- du.reshape.generate.weekly.repeated(
      data, dict_kind
    )
    if (!is.null(weeklyrep_data)) {
      write_csv(weeklyrep_data, paste0(getwd(), "/", file_name_weekly, ".csv"), na = "")
      weeklyrep_metadata <- du.retrieve.full.dict(du.enum.table.types()$WEEKLY, dict_kind)
      weeklyrep_data <- du.add.metadata(weeklyrep_data, weeklyrep_metadata)
      if (upload) {
        if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
          du.armadillo.import(project, weeklyrep_data, dict_version, dict_kind, data_version, du.enum.table.types()$WEEKLY)
        }
        if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL & !is.null(weeklyrep_data)) {
          du.opal.upload(dict_kind, file_name_weekly)
        }
      }
    } else {
      save(weeklyrep_data, file = paste0(getwd(), "/", file_name_weekly, ".RData"))
    }
  }

  if ((dict_kind == du.enum.dict.kind()$CORE & dict_version != "1_0") | (dict_kind == du.enum.dict.kind()$CHEMICALS)) {
    file_name_trimester <- paste0(file_prefix, "_", data_version, "_", "trimester_repeated_measures")
    trimester_data <- du.reshape.generate.trimesterly.repeated(
      data, dict_kind
    )
    if (!is.null(trimester_data)) {
      write_csv(trimester_data, paste0(getwd(), "/", file_name_trimester, ".csv"), na = "")
      trimester_metadata <- du.retrieve.full.dict(du.enum.table.types()$TRIMESTER, dict_kind)
      trimester_data <- du.add.metadata(trimester_data, trimester_metadata)
      if (upload) {
        if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
          du.armadillo.import(project, trimester_data, dict_version, dict_kind, data_version, du.enum.table.types()$TRIMESTER)
        }
        if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL) {
          du.opal.upload(dict_kind, file_name_trimester)
        }
      } else {
        save(trimester_data, file = paste0(getwd(), "/", file_name_trimester, ".RData"))
      }
    }
  }

  if (upload) {
    if (ds_upload.globals$login_data$driver == du.enum.backends()$OPAL) {
      if (!is.null(nonrep_data)) du.opal.upload(dict_kind, file_name_nonrep)
      if (!is.null(yearlyrep_data)) du.opal.upload(dict_kind, file_name_yearly)
      if (exists('monthlyrep_data')){ du.opal.upload(dict_kind, file_name_monthly) }
    }
    if (ds_upload.globals$login_data$driver == du.enum.backends()$ARMADILLO) {
      if (!is.null(nonrep_data)) { 
        nonrep_metadata <- du.retrieve.full.dict(du.enum.table.types()$NONREP, dict_kind)
        nonrep_data <- du.add.metadata(nonrep_data, nonrep_metadata)
        du.armadillo.import(project = project, data = nonrep_data, dict_version, dict_kind, data_version, du.enum.table.types()$NONREP)
      }
      if (!is.null(yearlyrep_data)) {
        yearlyrep_metadata <- du.retrieve.full.dict(du.enum.table.types()$YEARLY, dict_kind)
        yearlyrep_data <- du.add.metadata(yearlyrep_data, yearlyrep_metadata)
        du.armadillo.import(project = project, data = yearlyrep_data, dict_version, dict_kind, data_version, du.enum.table.types()$YEARLY)
      }
      if (!is.null(monthlyrep_data)) {
        monthlyrep_metadata <- du.retrieve.full.dict(du.enum.table.types()$MONTHLY, dict_kind)
        monthlyrep_data <- du.add.metadata(monthlyrep_data, monthlyrep_metadata)
        du.armadillo.import(project = project, data = monthlyrep_data, dict_version, dict_kind, data_version, du.enum.table.types()$MONTHLY)
      }
    }
  } else {
    if (!is.null(nonrep_data)) save(nonrep_data, file = paste0(getwd(), "/", file_name_nonrep, ".RData"))
    if (!is.null(yearlyrep_data)) save(yearlyrep_data, file = paste0(getwd(), "/", file_name_yearly, ".RData"))
    if (!is.null(monthlyrep_data)) save(monthlyrep_data, file = paste0(getwd(), "/", file_name_monthly, ".RData"))
  }

  message("######################################################")
  message("  Converting and import successfully finished         ")
  message("######################################################")
}
