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
#' @noRd
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
      data <- read_csv(input_path, col_types = cols(.default = col_double()))
    }
  } else {
    stop(paste0(
      input_format, " is not a valid input format, Possible input formats are: ",
      paste(du.enum.input.format(), collapse = ", ")
    ))
  }

  return(data)
}

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
#' @noRd
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
#' @noRd
du.match.columns <- function(data_columns, dict_columns) {
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
}

#'
#' Check if there are columns not matching the dictionary.
#'
#' @param dict_kind specify which dictionary you want to check
#' @param data_columns the coiumns within the data
#' @param run_mode default = NORMAL, can be TEST and NON_INTERACTIIVE
#'
#' @return stops the program if someone terminates
#'
#' @noRd
du.check.variables <- local(function(dict_kind, data_columns, run_mode) {
  variables <- du.retrieve.dictionaries(dict_kind = dict_kind)

  matched_columns <- du.match.columns(data_columns, variables$name)

  columns_not_matched <- data_columns[!(data_columns %in% matched_columns)]

  if (length(columns_not_matched) > 0) {
    message(paste0(
      "[WARNING] This is an unmatched column, it will be dropped : [ ",
      columns_not_matched, " ].\n"
    ))
    if (run_mode != du.enum.run.mode()$NON_INTERACTIVE) {
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

#' Match subset the data and convert to the right the column types according to the dictionary
#' 
#' @param data the imported data
#' @param dict_kind are the variables core or outcome
#' @param table_type is it repeated or non-repeated
#' 
#' @importFrom dplyr %>% filter
#' @importFrom purrr map pmap
#' 
#' @noRd
du.match.column.types <- function(data, dict_kind, table_type) {
  name <- orig_var <- value <- dictionary <- NULL
  
  matched_dictionary <- du.retrieve.dictionaries(table_type, dict_kind)
  matched_dictionary <- c("child_id", matched_dictionary$name)
  if(table_type != du.enum.table.types()$NON_REP) {
    matched_columns <- du.match.columns(colnames(data), matched_dictionary$name)
  }
  data <- data[, matched_columns]
  
  if (nrow(du.data.frame.remove.all.na.rows(data)) <= 0) {
    message("* WARNING: No monthly-repeated measures found in this set")
    return()
  }
  
  matched_data <- colnames(data) %>%
    map(function(column) {
      dictionary %>%
        filter(name == gsub('([0-9]+).*$', '', column)) %>%
        pmap(function(name, valueType, cats, ...) {
          print(paste0("matching: ", name, " and ", column))
          if(valueType == "integer" & ncol(cats) > 0) {
            new_column <- lapply(data[column], factor, levels = cats$value, labels = cats$label)
          } else if (valueType == "integer") {
            new_column <- lapply(data[column], as.integer)
          } else if (valueType == "decimal" &  ncol(cats) > 0) {
            new_column <- lapply(data[column], factor, levels = cats$value, labels = cats$label)
          } else if (valueType == "decimal") {
            new_column <- lapply(data[column], as.double)
          } else {
            new_column <- lapply(data[column], as.character)
          }
          return(as.data.frame(new_column))
        })
    }) %>%
    unlist(recursive = FALSE) %>%
    cbind.data.frame()
  
    if(table_type != du.enum.table.types()$NON_REP) {
      matched_data <- matched_data %>% gather(orig_var, value, matched_columns[matched_columns !=
                                                                       "child_id"], na.rm = TRUE)
    }
  
    return(matched_data)
}

#' Generate the yearly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param dict_kind can be 'core' or 'outcome'
#'
#' @importFrom stringr str_detect
#' @importFrom dplyr %>%
#' @importFrom purrr pmap map
#'
#' @noRd
du.reshape.generate.non.repeated <- function(data, dict_kind) {
  message("* Generating: non-repeated measures")
  
  matched_data <- du.match.column.types(data, du.enum.table.types()$NON_REP, dict_kind)
  
  # strip the rows with na values
  matched_data <- matched_data[, colSums(is.na(matched_data)) <
    nrow(matched_data)]

  # add row_id again to preserve child_id
  matched_data <- data.frame(
    row_id = c(1:length(matched_data$child_id)),
    matched_data
  )

  return(matched_data)
}

#' Generate the yearly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param dict_kind can be 'core' or 'outcome'
#'
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast %<>%
#' @importFrom tidyr gather
#'
#' @noRd
du.reshape.generate.yearly.repeated <- function(data, dict_kind) {
  # workaround to avoid glpobal variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  age_years <- . <- NULL

  message("* Generating: yearly-repeated measures")

<<<<<<< HEAD
  variables_yearly_repeated_dict <- du.retrieve.dictionaries(du.enum.table.types()$YEARLY, dict_kind)
  matched_columns <- du.match.columns(colnames(data), variables_yearly_repeated_dict$name)
  yearly_repeated_measures <- data[matched_columns]

  if (nrow(du.data.frame.remove.all.na.rows(yearly_repeated_measures)) <= 0) {
    message("[WARNING] No yearly-repeated measures found in this set")
    return()
  }

  long_1 <- yearly_repeated_measures %>% gather(orig_var, value, matched_columns[matched_columns !=
    "child_id"], na.rm = TRUE)
=======
  matched_data <- du.match.column.types(data, du.enum.table.types()$YEARLY, dict_kind)
>>>>>>> 84c64df... feat: embed column type matching in dsUpload

  # Create the age_years variable with the regular expression extraction of the year
  matched_data$age_years <- as.numeric(du.num.extract(matched_data$orig_var))

  # Here we remove the year indicator from the original variable name
  matched_data$variable_trunc <- gsub("[[:digit:]]+$", "", matched_data$orig_var)

  # Use the maditr package for spreading the data again, as tidyverse runs into memory
  # issues
  long_2 <- dcast(matched_data, child_id + age_years ~ variable_trunc, value.var = "value")

  # As the data table is still too big for opal, remove those rows, that have only
  # missing values, but keep all rows at age_years=0, so no child_id get's lost:

  # Subset of data with age_years = 0
  zero_year <- long_2 %>% filter(age_years %in% 0)

  for (id in unique(matched_data$child_id)) {
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
  long_yearly <- long_2[, c("row_id", "child_id", "age_years", unique(matched_data$variable_trunc))]

  return(long_yearly)
}

#' Generate the monthly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param dict_kind can be 'core' or 'outcome'
#'
#' @importFrom dplyr %>% filter summarise
#' @importFrom maditr dcast %<>%
#' @importFrom tidyr gather
#'
#' @noRd
du.reshape.generate.monthly.repeated <- function(data, dict_kind) {
  # workaround to avoid glpobal variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- value <- age_months <- . <- NULL

  message("* Generating: monthly-repeated measures")

  matched_data <- du.match.column.types(data, du.enum.table.types()$MONTHLY, dict_kind)

  # Create the age_years and age_months variables with the regular expression
  # extraction of the year
  matched_data$age_years <- as.integer(as.numeric(du.num.extract(matched_data$orig_var)) / 12)
  matched_data$age_months <- as.numeric(du.num.extract(matched_data$orig_var))

  # Here we remove the year indicator from the original variable name
  matched_data$variable_trunc <- gsub("[[:digit:]]+$", "", matched_data$orig_var)

  # Use the maditr package for spreading the data again, as tidyverse ruins into memory
  # issues
  long_2 <- dcast(matched_data, child_id + age_years + age_months ~ variable_trunc, value.var = "value")

  # As the data table is still too big for opal, remove those rows, that have only
  # missing values, but keep all rows at age_years=0, so no child_id get's lost:

  # Subset of data with age_months = 0
  zero_monthly <- long_2 %>% filter(age_months %in% 0)

  for (id in unique(matched_data$child_id)) {
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
  long_monthly <- long_2[, c("row_id", "child_id", "age_years", "age_months", unique(matched_data$variable_trunc))]

  return(long_monthly)
}

#' Generate the weekly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param dict_kind can be 'core' or 'outcome'
#'
#' @importFrom dplyr %>% summarise bind_rows
#' @importFrom maditr dcast %<>%
#' @importFrom tidyr gather
#'
#' @noRd
du.reshape.generate.weekly.repeated <- function(data, dict_kind) {
  # workaround to avoid glpobal variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- value <- age_weeks <- . <- NULL # Gestational age in weeks

  message("* Generating: weekly-repeated measures")

  matched_data <- du.match.column.types(data, du.enum.table.types()$WEEKLY, dict_kind)

  # Create the age_years and age_months variables with the regular expression
  # extraction of the year NB - these weekly dta are pregnancy related so child is NOT
  # BORN YET ---
  matched_data$age_years <- as.integer(as.numeric(du.num.extract(matched_data$orig_var)) / 52)
  matched_data$age_weeks <- as.integer(du.num.extract(matched_data$orig_var))

  # Here we remove the year indicator from the original variable name
  matched_data$variable_trunc <- gsub("[[:digit:]]+$", "", matched_data$orig_var)

  # Use the maditr package for spreading the data again, as tidyverse ruins into memory
  # issues
  long_2 <- dcast(matched_data, child_id + age_years + age_weeks ~ variable_trunc, value.var = "value")

  # As the data table is still too big for opal, remove those rows, that have only
  # missing values, but keep all rows at age_years=0, so no child_id get's lost:

  # Subset of data with age_months = 0
  zero_weekly <- long_2 %>% filter(age_weeks %in% 0)

  for (id in unique(matched_data$child_id)) {
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
  long_weekly <- long_2[, c("row_id", "child_id", "age_years", "age_weeks", unique(matched_data$variable_trunc))]

  return(long_weekly)
}


#' Generate the trimesterly repeated measures file and write it to your local workspace
#'
#' @param data data frame with all the data based upon the CSV file
#' @param dict_kind can be 'core' or 'outcome'
#'
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast %<>% 
#' @importFrom tidyr gather
#'
#' @noRd
du.reshape.generate.trimesterly.repeated <- function(data, dict_kind) {
  # workaround to avoid glpobal variable warnings, check:
  # https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  age_trimester <- . <- NULL

  message("* Generating: trimesterly-repeated measures")

  matched_data <- du.match.column.types(data, du.enum.table.types()$TRIMSTER, dict_kind)

  # Create the age_years and age_months variables with the regular expression
  # extraction of the year
  matched_data$age_trimester <- as.numeric(du.num.extract(matched_data$orig_var))
  matched_data$variable_trunc <- gsub("[[:digit:]]+$", "", matched_data$orig_var)

  # Use the maditr package for spreading the data again, as tidyverse ruins into memory
  # issues
  long_2 <- dcast(matched_data, child_id + age_trimester ~ variable_trunc, value.var = "value")

  # As the data table is still too big for opal, remove those rows, that have only
  # missing values, but keep all rows at age_years=0, so no child_id get's lost:

  # Subset of data with age_months = 0
  one_trimesterly <- long_2 %>% filter(age_trimester %in% 1)

  for (id in unique(matched_data$child_id)) {
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
  long_trimesterly <- long_2[, c("row_id", "child_id", "age_trimester", unique(matched_data))]

  return(long_trimesterly)
}
