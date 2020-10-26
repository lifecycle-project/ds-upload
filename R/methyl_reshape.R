#' Reshape Script for R: LifeCycle Harmonized Data
#'
#' @param upload do you want automatically upload the files to your opal (default = true)
#' @param data_version version of the data you are going to upload into Opal
#' @param dict_name version of the dictionary
#' @param data methylation data
#' @param non_interactive if set to TRUE you will get no questions
#'
#' @keywords internal
du.reshape.methyl.clocks <- function(upload, data_version, dict_name, data, non_interactive) {
  message("######################################################")
  message("  Start reshaping data                                ")
  message("######################################################")
  message("* Setup: load data and set output directory")
  message("------------------------------------------------------")

  du.check.variables(du.enum.dict.kind()$METHYL, colnames(data), non_interactive)
  
  tables <- du.dict.retrieve.tables(ds_upload.globals$api_dict_beta_url, dict_name)
  
  tables %>%
    map(function(table) {
      
      data_file_name <- paste0(format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), "_", table$table)
      
      if (grepl(du.enum.table.types()$NONREP, table$table)) {
        du.reshape.generate.non.repeated(
          data, upload, du.enum.dict.kind()$BETA, data_file_name
        )
      }
    })

  message("######################################################")
  message("  Reshaping successfully finished                     ")
  message("######################################################")
}
