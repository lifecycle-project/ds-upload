#' Read the input file from different sources
#'
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param input_path path for importfile
#'
#' @importFrom readr read_csv cols col_double
#' @importFrom haven read_dta read_sas read_spss
#'
#' @return dataframe with source data
lc.read.source.file <- local(function(input_path, input_format) {
  lc_data <- NULL

  if (input_format %in% lifecycle.globals$input_formats) {
    if (input_format == "STATA") {
      lc_data <- read_dta(input_path)
    } else if (input_format == "SPSS") {
      lc_data <- read_spss(input_path)
    } else if (input_format == "SAS") {
      lc_data <- read_sas(input_path)
    } else {
      lc_data <- read_csv(input_path, col_types = cols(.default = col_double()))
    }
  } else {
    stop(paste(input_format, " is not a valid input format, Possible input formats are: ", lifecycle.globals$input_formats, sep = ","))
  }

  return(lc_data)
})

#' Uploading the generated data files
#'
#' @param file_prefix a date to prefix the file with
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version the data release version
#' @param file_name name of the data file
#'
#' @importFrom opalr opal.file_upload
#'
lc.reshape.upload <- local(function(file_prefix, dict_kind, file_version, file_name) {
  upload_directory <- paste("/home/", lifecycle.globals$username, sep = "")
  file_ext <- ".csv"

  message(paste("* Upload: ", paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version, "_", file_name, file_ext, sep = ""), sep = ""))
  opal.file_upload(opal = lifecycle.globals$opal, source = paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version, "_", file_name, file_ext, sep = ""), destination = upload_directory)

  unlink(paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version, "_", file_name, file_ext, sep = ""))
})

#' Importing generated data files
#'
#' @param file_prefix a date to prefix the file with
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version the data release version
#' @param file_name name of the data file
#'
#' @importFrom readr read_csv
#' @importFrom opalr opal.post
#' @importFrom opalr opal.projects
#' @importFrom opalr opal.tables
#' @importFrom jsonlite toJSON
#'
lc.reshape.import <- local(function(file_prefix, dict_kind, file_version, file_name) {
  message("------------------------------------------------------")
  message("  Start importing data files")

  file_ext <- ".csv"

  projects <- opal.projects(lifecycle.globals$opal)
  project <- readline(paste("Which project you want to upload into: [ ", paste0(projects$name, collapse = ", "), " ]: ", sep = ""))

  if (!(project %in% projects$name)) {
    stop(paste("Invalid projectname: [ ", project, " ]", sep = ""))
  }

  tables <- opal.tables(lifecycle.globals$opal, project)

  table_name <- ""
  if (file_name %in% tables$name) {
    table <- tables$name
  }

  data <- read_csv(paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version, "_", file_name, file_ext, sep = ""))

  message(paste("* Import: ", paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version, "_", file_name, file_ext, sep = ""), sep = ""))
  opal.post(lifecycle.globals$opal, "datasource", lifecycle.globals$project, "table", table_name, "variables", body = toJSON(data), contentType = "application/x-protobuf+json")

  unlink(paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version, "_", file_name, file_ext, sep = ""))

  message("  Succesfully imported the files")
})

#'
#' Retrieve the right file from download directory
#'
#' @param dict_table which table do you want to return
#' @param dict_kind can be 'core' or 'outcome'
#' @param retrieve_all_by_kind do you want to retrieve all dictionaries in a certain version
#'
#' @importFrom readxl read_xlsx
#'
#' @return a raw version of the dictionary
#'
lc.retrieve.dictionaries <- local(function(dict_table, dict_kind, retrieve_all_by_kind = FALSE) {
  dict_file_list <- list.files(paste(getwd(), '/', dict_kind, sep = ''))

  if (retrieve_all_by_kind == FALSE) {
    dict_file_list <- dict_file_list[grep(dict_table, dict_file_list)]  
  }
  
  raw_dict <- list()
  for (file_name in dict_file_list) {
    raw_dict <- rbind(raw_dict, read_xlsx(path = paste(dict_kind, '/', file_name, sep = ''), sheet = 1))
  }
  return(as.data.frame(raw_dict))
})

#' Get the table without rows containing only NA's.
#'
#' We have to remove the first column (child_id), that is generated always.
#'
#' @param dataframe dataframe to check
#'
#' @importFrom dplyr %>%
#'
#' @return dataframe without the na values
#'
lc.data.frame.remove.all.na.rows <- local(function(dataframe) {
  df <- dataframe[-c(1)]

  naLines <- df %>%
    is.na() %>%
    apply(MARGIN = 1, FUN = all)

  return(df[!naLines, ])
})
#'
#' Matched the columns in the source data.
#' You can then match the found column against the dictionary.
#'
#' @param data_columns columns obtained from raw data
#' @param dict_columns columns matched in the dictionary
#'
#' @importFrom stringr str_subset
#'
#' @return matched_columns in source data
#'
lc.match.columns <- local(function(data_columns, dict_columns) {
  matched_columns <- character()

  matched_columns <- data_columns[data_columns %in% dict_columns]
  
  for (variable in dict_columns) {
    matched_columns <- c(matched_columns, data_columns %>% str_subset(pattern = paste0("^", variable, "\\d+", sep = "")))
  }
  # Select the non-repeated measures from the full data set
  return(matched_columns)
})

#'
#' Check if there are columns not matching the dictionary.
#' 
#' @param dict_kind specify which dictionary you want to check
#' @param lc_data_columns the coiumns within the data
#' 
#' @return stops the program if someone terminates 
#'
checkVariables <- local(function(dict_kind, lc_data_columns) {
  
  lc_variables <- lc.retrieve.dictionaries("", dict_kind, retrieve_all_by_kind = TRUE)
  
  matched_columns <-
    lc.match.columns(lc_data_columns,
                     lc_variables$name)
  
  columns_not_matched <- lc_data_columns[!(lc_data_columns %in% matched_columns)]
  
  if (length(columns_not_matched) > 0) {
    message(paste0("[WARNING] This is an unmatched column, it will be dropped : [ ", columns_not_matched ," ].\n"))
    proceed <- readline("Do you want to proceed (y/n)")
  }
  if(proceed == "n") {
    stop("Program is terminated. There are unmatched columns in your source data.")
  }
  
})
