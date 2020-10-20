#' Read the input file from different sources
#'
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param input_path path for importfile
#'
#' @importFrom readr read_csv cols col_double
#' @importFrom haven read_dta read_sas read_spss
#'
#' @return dataframe with source data
#'
#' @keywords internal
du.read.source.file <- function(input_path, input_format) {
  du_data <- NULL

  if (input_format %in% du.enum.input.format()) {
    if (input_format == du.enum.input.format()$STATA) {
      data <- read_dta(input_path)
    } else if (input_format == du.enum.input.format()$SPSS) {
      data <- read_spss(input_path)
    } else if (input_format == du.enum.input.format()$SAS) {
      data <- read_sas(input_path)
    } else if (input_format == du.enum.input.format()$R) {
      data <- source(input_path)
    } else {
      data <- read_csv(input_path)
    }
  } else {
    stop(paste0(
      input_format, " is not a valid input format, Possible input formats are: ",
      paste(du.enum.input.format(), collapse = ", ")
    ))
  }

  return(data)
}

#' Uploading the generated data files
#'
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_name name of the data file
#'
#' @importFrom opalr opal.file_upload opal.file_mkdir opal.file_ls
#'
#' @keywords internal
du.reshape.upload <- function(dict_kind, file_name) {
  upload_directory <- paste0("/home/", ds_upload.globals$username)

  message(paste0("* Upload: [ ", file_name, ".csv ] to directory [ ", dict_kind, " ]"))
  dirs <- opal.file_ls(ds_upload.globals$opal, upload_directory)
  if (!(dict_kind %in% dirs$name)) {
    opal.file_mkdir(ds_upload.globals$opal, paste0(upload_directory, "/", dict_kind))
  }
  opal.file_upload(ds_upload.globals$opal, source = paste0(getwd(), "/", file_name, ".csv"), destination = paste0(upload_directory, "/", dict_kind))

  unlink(paste0(getwd(), "/", file_name, ".csv"))
}

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
#' @keywords internal
du.reshape.import <- local(function(file_prefix, dict_kind, file_version, file_name) {
  message("------------------------------------------------------")
  message("  Start importing data files")

  file_ext <- ".csv"

  projects <- opal.projects(ds_upload.globals$opal)
  project <- readline(paste("Which project you want to upload into: [ ", paste0(projects$name,
    collapse = ", "
  ), " ]: ", sep = ""))

  if (!(project %in% projects$name)) {
    stop(paste("Invalid projectname: [ ", project, " ]", sep = ""))
  }

  tables <- opal.tables(ds_upload.globals$opal, project)

  table_name <- ""
  if (file_name %in% tables$name) {
    table <- tables$name
  }

  data <- read_csv(paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version,
    "_", file_name, file_ext,
    sep = ""
  ))

  message(paste("* Import: ", paste(getwd(), "/", file_prefix, "_", dict_kind, "_",
    file_version, "_", file_name, file_ext,
    sep = ""
  ), sep = ""))
  opal.post(ds_upload.globals$opal, "datasource", ds_upload.globals$project, "table",
    table_name, "variables",
    body = toJSON(data), contentType = "application/x-protobuf+json"
  )

  unlink(paste(getwd(), "/", file_prefix, "_", dict_kind, "_", file_version, "_", file_name,
    file_ext,
    sep = ""
  ))

  message("  Succesfully imported the files")
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
#' @keywords internal
du.data.frame.remove.all.na.rows <- local(function(dataframe) {
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
#' @keywords internal
du.match.columns <- local(function(data_columns, dict_columns) {
  matched_columns <- character()

  matched_columns <- data_columns[data_columns %in% dict_columns]

  for (variable in dict_columns) {
    matched_columns <- c(matched_columns, data_columns %>% str_subset(pattern = paste0("^",
      variable, "\\d+",
      sep = ""
    )))
  }
  # Select the non-repeated measures from the full data set
  return(matched_columns)
})

#'
#' Check if there are columns not matching the dictionary.
#'
#' @param dict_kind specify which dictionary you want to check
#' @param data_columns the coiumns within the data
#' @param non_interactive if set to TRUE you will get no questions
#'
#' @return stops the program if someone terminates
#'
#' @keywords internal
du.check.variables <- local(function(dict_kind, data_columns, non_interactive) {
  variables <- du.retrieve.dictionaries(dict_kind = dict_kind)

  matched_columns <- du.match.columns(data_columns, variables$name)

  columns_not_matched <- data_columns[!(data_columns %in% matched_columns)]

  if (length(columns_not_matched) > 0) {
    message(paste0(
      "[WARNING] This is an unmatched column, it will be dropped : [ ",
      columns_not_matched, " ].\n"
    ))
    if (!non_interactive) {
      proceed <- readline("Do you want to proceed (y/n)")
    } else {
      proceed <- "y"
    }
  } else {
    proceed <- "y"
  }
  if (proceed == "n") {
    stop("Program is terminated. There are unmatched columns in your source data.")
  }
})

#' Generate the yearly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param upload do you want to upload to Opal (default = true)
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_name non-repeated, monthly-repeated or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>%
#' @importFrom readxl read_xlsx
#'
#' @keywords internal
du.reshape.generate.non.repeated <- local(function(data, upload, dict_kind, file_name) {
  message("* Generating: non-repeated measures")

  # Retrieve dictionary
  variables_non_repeated_dict <- du.retrieve.dictionaries(du.enum.table.types()$NONREP, dict_kind)

  # select the non-repeated measures from the full data set
  non_repeated <- c("child_id", variables_non_repeated_dict$name)
  non_repeated_measures <- data[, which(colnames(data) %in% non_repeated)]

  # strip the rows with na values
  non_repeated_measures <- non_repeated_measures[, colSums(is.na(non_repeated_measures)) <
    nrow(non_repeated_measures)]

  # add row_id again to preserve child_id
  non_repeated_measures <- data.frame(
    row_id = c(1:length(non_repeated_measures$child_id)),
    non_repeated_measures
  )

  # Write as csv
  write_csv(non_repeated_measures, paste0(getwd(), "/", file_name, ".csv"), na = "")

  if (upload) {
    du.reshape.upload(dict_kind, file_name)
  }
})

#' Generate the yearly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param upload do you want to upload to Opal (default = true)
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_name non-repeated, monthly-repeated, weekly, trimesterly or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast as.data.table %<>%
#' @importFrom tidyr gather
#'
#' @keywords internal
du.reshape.generate.yearly.repeated <- local(function(data, upload, dict_kind, file_name) {
  # workaround to avoid glpobal variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- value <- age_years <- . <- NULL

  message("* Generating: yearly-repeated measures")

  variables_yearly_repeated_dict <- du.retrieve.dictionaries(du.enum.table.types()$YEARLY, dict_kind)
  matched_columns <- du.match.columns(colnames(data), variables_yearly_repeated_dict$name)
  yearly_repeated_measures <- data[matched_columns]

  if (nrow(du.data.frame.remove.all.na.rows(yearly_repeated_measures)) <= 0) {
    message("* WARNING: No yearly-repeated measures found in this set")
    return()
  }

  long_1 <- yearly_repeated_measures %>% gather(orig_var, value, matched_columns[matched_columns !=
    "child_id"], na.rm = TRUE)

  # Create the age_years variable with the regular expression extraction of the year
  long_1$age_years <- as.numeric(du.num.extract(long_1$orig_var))

  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub("[[:digit:]]+$", "", long_1$orig_var)

  # Use the maditr package for spreading the data again, as tidyverse runs into memory
  # issues
  long_2 <- dcast(long_1, child_id + age_years ~ variable_trunc, value.var = "value")

  # As the data table is still too big for opal, remove those rows, that have only
  # missing values, but keep all rows at age_years=0, so no child_id get's lost:

  # Subset of data with age_years = 0
  zero_year <- long_2 %>% filter(age_years %in% 0)

  for (id in unique(yearly_repeated_measures$child_id)) {
    if (!(id %in% zero_year$child_id)) {
      zero_year %<>% summarise(child_id = id, age_years = 0) %>% bind_rows(
        zero_year,
      )
    }
  }

  # Subset of data with age_years > 0
  later_year <- long_2 %>% filter(age_years > 0)

  # Bind the 0 year and older data sets together
  long_2 <- rbind(zero_year, later_year)

  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))

  # Arrange the variable names based on the original order
  long_yearly <- long_2[, c("row_id", "child_id", "age_years", unique(long_1$variable_trunc))]

  write_csv(long_yearly, paste0(getwd(), "/", file_name, ".csv"), na = "")

  if (upload) {
    du.reshape.upload(dict_kind, file_name)
  }
})

#' Generate the monthly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param upload do you want to upload to Opal (default = true)
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_name non-repeated, monthly-repeated, weekly, trimesterly or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast as.data.table %<>%
#' @importFrom tidyr gather
#'
#' @keywords internal
du.reshape.generate.monthly.repeated <- local(function(data, upload, dict_kind, file_name) {
  # workaround to avoid glpobal variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- value <- age_months <- . <- NULL

  message("* Generating: monthly-repeated measures")

  variables_monthly_repeated_dict <- du.retrieve.dictionaries(du.enum.table.types()$MONTHLY, dict_kind)
  matched_columns <- du.match.columns(colnames(data), variables_monthly_repeated_dict$name)
  monthly_repeated_measures <- data[, matched_columns]

  if (nrow(du.data.frame.remove.all.na.rows(monthly_repeated_measures)) <= 0) {
    message("* WARNING: No monthly-repeated measures found in this set")
    return()
  }

  long_1 <- monthly_repeated_measures %>% gather(orig_var, value, matched_columns[matched_columns !=
    "child_id"], na.rm = TRUE)

  # Create the age_years and age_months variables with the regular expression
  # extraction of the year
  long_1$age_years <- as.integer(as.numeric(du.num.extract(long_1$orig_var)) / 12)
  long_1$age_months <- as.numeric(du.num.extract(long_1$orig_var))

  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub("[[:digit:]]+$", "", long_1$orig_var)

  # Use the maditr package for spreading the data again, as tidyverse ruins into memory
  # issues
  long_2 <- dcast(long_1, child_id + age_years + age_months ~ variable_trunc, value.var = "value")

  # As the data table is still too big for opal, remove those rows, that have only
  # missing values, but keep all rows at age_years=0, so no child_id get's lost:

  # Subset of data with age_months = 0
  zero_monthly <- long_2 %>% filter(age_months %in% 0)

  for (id in unique(monthly_repeated_measures$child_id)) {
    if (!(id %in% zero_monthly$child_id)) {
      zero_monthly %<>% summarise(child_id = id, age_months = 0) %>% bind_rows(
        zero_monthly,
      )
    }
  }

  # Subset of data with age_months > 0
  later_monthly <- long_2 %>% filter(age_months > 0)

  # Bind the 0 year and older data sets together
  long_2 <- rbind(zero_monthly, later_monthly)

  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))

  # Arrange the variable names based on the original order
  long_monthly <- long_2[, c("row_id", "child_id", "age_years", "age_months", unique(long_1$variable_trunc))]


  write_csv(long_monthly, paste0(getwd(), "/", file_name, ".csv"), na = "")

  if (upload) {
    du.reshape.upload(dict_kind, file_name)
  }
})

#' Generate the weekly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param upload do you want to upload to Opal (default = true)
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_name non-repeated, monthly-repeated, weekly, trimesterly or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast as.data.table %<>%
#' @importFrom tidyr gather
#'
#' @keywords internal
du.reshape.generate.weekly.repeated <- local(function(data, upload, dict_kind, file_name) {
  # workaround to avoid glpobal variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- value <- age_weeks <- . <- NULL # Gestational age in weeks

  message("* Generating: weekly-repeated measures")

  variables_weekly_repeated_dict <- du.retrieve.dictionaries(du.enum.table.types()$WEEKLY, dict_kind)
  matched_columns <- du.match.columns(colnames(data), variables_weekly_repeated_dict$name)
  weekly_repeated_measures <- data[, matched_columns]

  if (nrow(du.data.frame.remove.all.na.rows(weekly_repeated_measures)) <= 0) {
    message("* WARNING: No weekly-repeated measures found in this set")
    return()
  }

  long_1 <- weekly_repeated_measures %>% gather(orig_var, value, matched_columns[matched_columns !=
    "child_id"], na.rm = TRUE)

  # Create the age_years and age_months variables with the regular expression
  # extraction of the year NB - these weekly dta are pregnancy related so child is NOT
  # BORN YET ---
  long_1$age_years <- as.integer(as.numeric(du.num.extract(long_1$orig_var)) / 52)
  long_1$age_weeks <- as.integer(du.num.extract(long_1$orig_var))

  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub("[[:digit:]]+$", "", long_1$orig_var)

  # Use the maditr package for spreading the data again, as tidyverse ruins into memory
  # issues
  long_2 <- dcast(long_1, child_id + age_years + age_weeks ~ variable_trunc, value.var = "value")

  # As the data table is still too big for opal, remove those rows, that have only
  # missing values, but keep all rows at age_years=0, so no child_id get's lost:

  # Subset of data with age_months = 0
  zero_weekly <- long_2 %>% filter(age_weeks %in% 0)

  for (id in unique(weekly_repeated_measures$child_id)) {
    if (!(id %in% zero_weekly$child_id)) {
      zero_weekly %<>% summarise(child_id = id, age_weeks = 0) %>% bind_rows(
        zero_weekly,
      )
    }
  }

  # Subset of data with age_months > 0
  later_weekly <- long_2 %>% filter(age_weeks > 0)

  # Bind the 0 year and older data sets together
  long_2 <- rbind(zero_weekly, later_weekly)

  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))

  # Arrange the variable names based on the original order
  long_weekly <- long_2[, c("row_id", "child_id", "age_years", "age_weeks", unique(long_1$variable_trunc))]

  write_csv(long_weekly, paste0(getwd(), "/", file_name, ".csv"), na = "")

  if (upload) {
    du.reshape.upload(dict_kind, file_name)
  }
})


#' Generate the trimesterly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param upload do you want to upload to Opal (default = true)
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_name non-repeated, monthly-repeated, weekly, trimesterly or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast as.data.table %<>%
#' @importFrom tidyr gather
#'
#' @keywords internal
du.reshape.generate.trimesterly.repeated <- local(function(data, upload, dict_kind, file_name) {
  # workaround to avoid glpobal variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- value <- age_trimester <- . <- NULL

  message("* Generating: trimesterly-repeated measures")

  variables_trimesterly_repeated_dict <- du.retrieve.dictionaries(
    du.enum.table.types()$TRIMESTER,
    dict_kind
  )
  matched_columns <- du.match.columns(colnames(data), variables_trimesterly_repeated_dict$name)
  trimesterly_repeated_measures <- data[, matched_columns]

  if (nrow(du.data.frame.remove.all.na.rows(trimesterly_repeated_measures)) <= 0) {
    message("* WARNING: No trimesterly-repeated measures found in this set")
    return()
  }

  long_1 <- trimesterly_repeated_measures %>% gather(orig_var, value, matched_columns[matched_columns !=
    "child_id"], na.rm = TRUE)

  # Create the age_years and age_months variables with the regular expression
  # extraction of the year
  long_1$age_trimester <- as.numeric(du.num.extract(long_1$orig_var))

  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub("[[:digit:]]+$", "", long_1$orig_var)

  # Use the maditr package for spreading the data again, as tidyverse ruins into memory
  # issues
  long_2 <- dcast(long_1, child_id + age_trimester ~ variable_trunc, value.var = "value")

  # As the data table is still too big for opal, remove those rows, that have only
  # missing values, but keep all rows at age_years=0, so no child_id get's lost:

  # Subset of data with age_months = 0
  one_trimesterly <- long_2 %>% filter(age_trimester %in% 1)

  for (id in unique(trimesterly_repeated_measures$child_id)) {
    if (!(id %in% one_trimesterly$child_id)) {
      one_trimesterly %<>% summarise(child_id = id, age_trimester = 1) %>% bind_rows(
        one_trimesterly,
        .
      )
    }
  }

  # Subset of data with age_months > 0
  later_trimesterly <- long_2 %>% filter(age_trimester > 1)

  long_2 <- rbind(one_trimesterly, later_trimesterly)

  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))

  # Arrange the variable names based on the original order
  long_trimesterly <- long_2[, c("row_id", "child_id", "age_trimester", unique(long_1$variable_trunc))]

  write_csv(long_trimesterly, paste0(getwd(), "/", file_name, ".csv"), na = "")

  if (upload) {
    du.reshape.upload(dict_kind, file_name)
  }
})
