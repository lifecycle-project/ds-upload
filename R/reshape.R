#' Reshape Script for R: LifeCycle Harmonized Data
#'
#' @param upload_to_opal do you want automatically upload the files to your opal (default = true)
#' @param data_version version of the data you are going to upload into Opal
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param dict_version version of the dictionary
#' @param dict_kind kind of data to reshape (default = core)
#' @param input_path path for importfile
#' @param output_path path to output directory (default = your working directory)
#'
#' @importFrom readxl read_xlsx
lc.reshape <-
  local(function(upload_to_opal = TRUE,
                 data_version,
                 input_format,
                 dict_version,
                 dict_kind,
                 input_path,
                 output_path) {
    message('######################################################')
    message('  Start reshaping data                                ')
    message('######################################################')
    message("* Setup: load data and set output directory")
    message('------------------------------------------------------')
    
    lc_data <- lc.read.source.file(input_path, input_format)
    
    checkVariables(dict_kind, colnames(lc_data))
    
    file_prefix <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
    
    lc.reshape.generate.non.repeated(
      lc_data,
      upload_to_opal,
      output_path,
      file_prefix,
      dict_kind,
      data_version,
      'non_repeated_measures'
    )
    lc.reshape.generate.yearly.repeated(
      lc_data,
      upload_to_opal,
      output_path,
      file_prefix,
      dict_kind,
      data_version,
      'yearly_repeated_measures'
    )
    lc.reshape.generate.monthly.repeated(
      lc_data,
      upload_to_opal,
      output_path,
      file_prefix,
      dict_kind,
      data_version,
      'monthly_repeated_measures'
    )
    
    if (dict_kind == "outcome") {
      lc.reshape.generate.weekly.repeated(
        lc_data,
        upload_to_opal,
        output_path,
        file_prefix,
        dict_kind,
        data_version,
        'weekly_repeated_measures'
      )
    }
    
    if (dict_kind == 'core' & dict_version != "1_0") {
      lc.reshape.generate.trimesterly.repeated(
        lc_data,
        upload_to_opal,
        output_path,
        file_prefix,
        dict_kind,
        data_version,
        'trimester_repeated_measures'
      )
    }
    
    message('######################################################')
    message('  Reshaping successfully finished                     ')
    message('######################################################')
    
  })

#' Generate the yearly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>%
#' @importFrom readxl read_xlsx
#'
lc.reshape.generate.non.repeated <-
  local(function(lc_data,
                 upload_to_opal,
                 output_path,
                 file_prefix,
                 dict_kind,
                 file_version,
                 file_name) {
    message("* Generating: non-repeated measures")
    
    # Retrieve dictionnary
    lc_variables_non_repeated_dict <-
      lc.retrieve.dictionaries("non_rep", dict_kind)
    
    # select the non-repeated measures from the full data set
    non_repeated <-
      c("child_id", lc_variables_non_repeated_dict$name)
    non_repeated_measures <-
      lc_data[, which(colnames(lc_data) %in% non_repeated)]
    
    # strip the rows with na values
    non_repeated_measures <-
      non_repeated_measures[, colSums(is.na(non_repeated_measures)) < nrow(non_repeated_measures)]
    
    # add row_id again to preserve child_id
    non_repeated_measures <-
      data.frame(row_id = c(1:length(non_repeated_measures$child_id)), non_repeated_measures)
    
    # Write as csv
    write_csv(
      non_repeated_measures,
      paste(
        output_path,
        '/',
        file_prefix,
        '_',
        dict_kind,
        '_',
        file_version,
        '_',
        file_name,
        '.csv',
        sep = ""
      ),
      na = ""
    )
    
    if (upload_to_opal) {
      lc.reshape.upload(file_prefix, dict_kind, file_version, file_name)
    }
  })

#' Generate the yearly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated, weekly, trimesterly or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast as.data.table %<>%
#' @importFrom tidyr gather
#'
lc.reshape.generate.yearly.repeated <-
  local(function(lc_data,
                 upload_to_opal,
                 output_path,
                 file_prefix,
                 dict_kind,
                 file_version,
                 file_name) {
    # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
    orig_var <- value <- age_years <- . <- NULL
    
    message("* Generating: yearly-repeated measures")
    
    lc_variables_yearly_repeated_dict <-
      lc.retrieve.dictionaries("yearly_rep", dict_kind)
    matched_columns <-
      lc.match.columns(colnames(lc_data), lc_variables_yearly_repeated_dict$name)
    yearly_repeated_measures <-
      lc_data[matched_columns]
    
    if (nrow(lc.data.frame.remove.all.na.rows(yearly_repeated_measures)) <= 0) {
      message('* WARNING: No yearly-repeated measures found in this set')
      return()
    }
    
    long_1 <- yearly_repeated_measures %>%
      gather(orig_var, value, matched_columns[matched_columns != "child_id"], na.rm = TRUE)
    
    # Create the age_years variable with the regular expression extraction of the year
    long_1$age_years <- as.numeric(numextract(long_1$orig_var))
    
    # Here we remove the year indicator from the original variable name
    long_1$variable_trunc <-
      gsub("[[:digit:]]+$", "", long_1$orig_var)
    
    # Use the maditr package for spreading the data again, as tidyverse runs into memory issues
    long_2 <- dcast(long_1, child_id + age_years ~ variable_trunc, value.var = "value")
    
    # As the data table is still too big for opal, remove those
    # rows, that have only missing values, but keep all rows at age_years=0, so
    # no child_id get's lost:
    
    # Subset of data with age_years = 0
    zero_year <- long_2 %>% filter(age_years %in% 0)
    
    for(id in unique(yearly_repeated_measures$child_id)) {
      if(!(id %in% zero_year$child_id)) {
        zero_year %<>%
          summarise(child_id = id,
                    age_years = 0) %>%
          bind_rows(zero_year, .)
      }
    }
    
    # Subset of data with age_years > 0
    later_year <- long_2 %>% filter(age_years > 0)
    
    # Bind the 0 year and older data sets together
    long_2 <- rbind(zero_year, later_year)
    
    # Create a row_id so there is a unique identifier for the rows
    long_2$row_id <- c(1:length(long_2$child_id))
    
    # Arrange the variable names based on the original order
    long_yearly <-
      long_2[, c("row_id",
                 "child_id",
                 "age_years",
                 unique(long_1$variable_trunc))]
    
    write_csv(
      long_yearly,
      paste(
        output_path,
        '/',
        file_prefix,
        '_',
        dict_kind,
        '_',
        file_version,
        '_',
        file_name,
        '.csv',
        sep = ""
      ),
      na = ""
    )
    
    if (upload_to_opal) {
      lc.reshape.upload(file_prefix, dict_kind, file_version, file_name)
    }
  })

#' Generate the monthly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated, weekly, trimesterly or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast as.data.table %<>%
#' @importFrom tidyr gather
#'
lc.reshape.generate.monthly.repeated <-
  local(function(lc_data,
                 upload_to_opal,
                 output_path,
                 file_prefix,
                 dict_kind,
                 file_version,
                 file_name) {
    # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
    orig_var <- value <- age_months <- . <- NULL
    
    message('* Generating: monthly-repeated measures')
    
    lc_variables_monthly_repeated_dict <-
      lc.retrieve.dictionaries("monthly_rep", dict_kind)
    matched_columns <-
      lc.match.columns(colnames(lc_data),
                       lc_variables_monthly_repeated_dict$name)
    monthly_repeated_measures <-
      lc_data[, matched_columns]
    
    if (nrow(lc.data.frame.remove.all.na.rows(monthly_repeated_measures)) <= 0) {
      message('* WARNING: No monthly-repeated measures found in this set')
      return()
    }
    
    long_1 <- monthly_repeated_measures %>%
      gather(orig_var, value, matched_columns[matched_columns != "child_id"], na.rm = TRUE)
    
    # Create the age_years and age_months variables with the regular expression extraction of the year
    long_1$age_years  <-
      as.integer(as.numeric(numextract(long_1$orig_var)) / 12)
    long_1$age_months <- as.numeric(numextract(long_1$orig_var))
    
    # Here we remove the year indicator from the original variable name
    long_1$variable_trunc <-
      gsub('[[:digit:]]+$', '', long_1$orig_var)
    
    # Use the maditr package for spreading the data again, as tidyverse ruins into memory issues
    long_2 <-
      dcast(long_1,
            child_id + age_years + age_months ~ variable_trunc,
            value.var = "value")
    
    # As the data table is still too big for opal, remove those
    # rows, that have only missing values, but keep all rows at age_years=0, so
    # no child_id get's lost:
    
    # Subset of data with age_months = 0
    zero_monthly <- long_2 %>%
      filter(age_months %in% 0)
    
    for(id in unique(monthly_repeated_measures$child_id)) {
      if(!(id %in% zero_monthly$child_id)) {
        zero_monthly %<>%
          summarise(child_id = id,
                    age_months = 0) %>%
          bind_rows(zero_monthly, .)
      }
    }
    
    # Subset of data with age_months > 0
    later_monthly <- long_2 %>%
      filter(age_months > 0)
    
    # Bind the 0 year and older data sets together
    long_2 <- rbind(zero_monthly, later_monthly)
    
    # Create a row_id so there is a unique identifier for the rows
    long_2$row_id <- c(1:length(long_2$child_id))
    
    # Arrange the variable names based on the original order
    long_monthly <-
      long_2[, c("row_id",
                 "child_id",
                 "age_years",
                 "age_months",
                 unique(long_1$variable_trunc))]
    
    
    write_csv(
      long_monthly,
      paste(
        output_path,
        '/',
        file_prefix,
        '_',
        dict_kind,
        '_',
        file_version,
        '_',
        file_name,
        '.csv',
        sep = ""
      ),
      na = ""
    )
    
    if (upload_to_opal) {
      lc.reshape.upload(file_prefix, dict_kind, file_version, file_name)
    }
  })

#' Generate the weekly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated, weekly, trimesterly or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast as.data.table %<>%
#' @importFrom tidyr gather
#'
lc.reshape.generate.weekly.repeated <- local(function(lc_data,
                                                      upload_to_opal,
                                                      output_path,
                                                      file_prefix,
                                                      dict_kind,
                                                      file_version,
                                                      file_name) {
  # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <-
    value <- age_weeks <- . <- NULL # Gestational age in weeks
  
  message('* Generating: weekly-repeated measures')
  
  lc_variables_weekly_repeated_dict <-
    lc.retrieve.dictionaries("weekly_rep", dict_kind)
  matched_columns <-
    lc.match.columns(colnames(lc_data), lc_variables_weekly_repeated_dict$name)
  weekly_repeated_measures <-
    lc_data[, matched_columns]
  
  if (nrow(lc.data.frame.remove.all.na.rows(weekly_repeated_measures)) <= 0) {
    message('* WARNING: No weekly-repeated measures found in this set')
    return()
  }
  
  long_1 <- weekly_repeated_measures %>%
    gather(orig_var, value, matched_columns[matched_columns != "child_id"], na.rm = TRUE)
  
  # Create the age_years and age_months variables with the regular expression extraction of the year
  # NB - these weekly dta are pregnancy related so child is NOT BORN YET ---
  long_1$age_years  <-
    as.integer(as.numeric(numextract(long_1$orig_var)) / 52)
  long_1$age_weeks  <- as.integer(numextract(long_1$orig_var))
  
  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <-
    gsub('[[:digit:]]+$', '', long_1$orig_var)
  
  # Use the maditr package for spreading the data again, as tidyverse ruins into memory issues
  long_2 <-
    dcast(long_1,
          child_id + age_years + age_weeks ~ variable_trunc,
          value.var = "value")
  
  # As the data table is still too big for opal, remove those
  # rows, that have only missing values, but keep all rows at age_years=0, so
  # no child_id get's lost:
  
  # Subset of data with age_months = 0
  zero_weekly <- long_2 %>%
    filter(age_weeks %in% 0)
  
  for(id in unique(weekly_repeated_measures$child_id)) {
    if(!(id %in% zero_weekly$child_id)) {
      zero_weekly %<>%
        summarise(child_id = id,
                  age_weeks = 0) %>%
        bind_rows(zero_weekly, .)
    }
  }
  
  # Subset of data with age_months > 0
  later_weekly <- long_2 %>%
    filter(age_weeks > 0)
  
  # Bind the 0 year and older data sets together
  long_2 <- rbind(zero_weekly, later_weekly)
  
  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))
  
  # Arrange the variable names based on the original order
  long_weekly <-
    long_2[, c("row_id",
               "child_id",
               "age_years",
               "age_weeks",
               unique(long_1$variable_trunc))]
  
  write_csv(
    long_weekly,
    paste(
      output_path,
      '/',
      file_prefix,
      '_',
      dict_kind,
      '_',
      file_version,
      '_',
      file_name,
      '.csv',
      sep = ""
    ),
    na = ""
  )
  
  if (upload_to_opal) {
    lc.reshape.upload(file_prefix,
                      dict_kind,
                      file_version,
                      file_name)
  }
})


#' Generate the trimesterly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param dict_kind can be 'core' or 'outcome'
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated, weekly, trimesterly or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter summarise bind_rows
#' @importFrom maditr dcast as.data.table %<>%
#' @importFrom tidyr gather
#'
lc.reshape.generate.trimesterly.repeated <-
  local(function(lc_data,
                 upload_to_opal,
                 output_path,
                 file_prefix,
                 dict_kind,
                 file_version,
                 file_name) {
    # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
    orig_var <- value <- age_trimester <- . <- NULL
    
    message('* Generating: trimesterly-repeated measures')
    
    lc_variables_trimesterly_repeated_dict <-
      lc.retrieve.dictionaries("trimester_rep", dict_kind)
    matched_columns <-
      lc.match.columns(colnames(lc_data),
                       lc_variables_trimesterly_repeated_dict$name)
    trimesterly_repeated_measures <-
      lc_data[, matched_columns]
    
    if (nrow(lc.data.frame.remove.all.na.rows(trimesterly_repeated_measures)) <= 0) {
      message('* WARNING: No trimesterly-repeated measures found in this set')
      return()
    }
    
    long_1 <- trimesterly_repeated_measures %>%
      gather(orig_var, value, matched_columns[matched_columns != "child_id"], na.rm = TRUE)
    
    # Create the age_years and age_months variables with the regular expression extraction of the year
    long_1$age_trimester <- as.numeric(numextract(long_1$orig_var))
    
    # Here we remove the year indicator from the original variable name
    long_1$variable_trunc <-
      gsub('[[:digit:]]+$', '', long_1$orig_var)
    
    # Use the maditr package for spreading the data again, as tidyverse ruins into memory issues
    long_2 <-
      dcast(long_1,
            child_id + age_trimester ~ variable_trunc,
            value.var = "value")
    
    # As the data table is still too big for opal, remove those
    # rows, that have only missing values, but keep all rows at age_years=0, so
    # no child_id get's lost:
    
    # Subset of data with age_months = 0
    one_trimesterly <- long_2 %>%
      filter(age_trimester %in% 1)
    
    for(id in unique(trimesterly_repeated_measures$child_id)) {
      if(!(id %in% one_trimesterly$child_id)) {
        one_trimesterly %<>%
          summarise(child_id = id,
                    age_trimester = 1) %>%
          bind_rows(one_trimesterly, .)
      }
    }
    
    # Subset of data with age_months > 0
    later_trimesterly <- long_2 %>%
      filter(age_trimester > 1)
    
    long_2 <- rbind(one_trimesterly, later_trimesterly)
    
    # Create a row_id so there is a unique identifier for the rows
    long_2$row_id <- c(1:length(long_2$child_id))
    
    # Arrange the variable names based on the original order
    long_trimesterly <-
      long_2[, c(
        "row_id",
        "child_id",
        "age_trimester",
        unique(long_1$variable_trunc)
      )]
    
    write_csv(
      long_trimesterly,
      paste(
        output_path,
        '/',
        file_prefix,
        '_',
        dict_kind,
        '_',
        file_version,
        '_',
        file_name,
        '.csv',
        sep = ""
      ),
      na = ""
    )
    
    if (upload_to_opal) {
      lc.reshape.upload(file_prefix,
                        dict_kind,
                        file_version,
                        file_name)
    }
  })