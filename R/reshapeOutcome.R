#' Reshape Script for R: LifeCycle Harmonized Data
#'
#' @param upload_to_opal do you want automatically upload the files to your opal (default = true)
#' @param data_version version of the data you are going to upload into Opal
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param input_path path for importfile
#' @param output_path path to output directory (default = your working directory)
#' 
#' @examples 
#' lc.reshape.outcome(
#'   upload_to_opal = FALSE, 
#'   data_version = '1_0', 
#'   input_format = 'SPSS', 
#'   input_path = 'C:\MyDocuments\source_file.sav', 
#'   output_path = 'C:\MyDocuments\output_file.csv')
#'
#' @export
lc.reshape.outcome <- local(
  function(upload_to_opal = TRUE, 
           data_version, 
           input_format = 'CSV', 
           input_path, 
           output_path = getwd()
           ) 
    {
  
  message('######################################################')
  message('  Start reshaping data                                ')
  message('######################################################')
  message("* Setup: load data and set output directory")
  message('------------------------------------------------------')
  
  if (upload_to_opal) {
    if(!exists('hostname', envir = lifecycle.globals)) stop('You need to login first, please run lc.login')
    if(!exists('username', envir = lifecycle.globals)) stop('You need to login first, please run lc.login')
  }
  
  lc_data <- lc.read.source.file(input_path, input_format)
  
  file_prefix <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
  if(missing(data_version)) {
    data_version <- readline('- Specify version of cohort data upload (e.g. 1_0): ')
  }
  if(checkVersion(data_version)) {
    file_version <- data_version
  } else {
    stop("The data version does not match syntax: 'number_number'! Program is terminated.", call. = FALSE)
  }
  
  # Check which variables are missing in the study as compared to the full variable list 
  # (if character(0), continue, otherwise
  # check the list of variables in the original harmonized data)
  lc_variables <- c(
    lc.variables.primary.keys(), 
    lc.variables.outcome.non.repeated(), 
    lc.variables.outcome.yearly.repeated(), 
    lc.variables.outcome.monthly.repeated(),
    lc.variables.outcome.weekly.repeated()
    )
  
  missing <- setdiff(lc_variables, names(lc_data))
  
  # Ammend the data with columns
  lc_data[missing] <- NA
  
  lc.reshape.outcome.generate.non.repeated(
    lc_data, 
    upload_to_opal, 
    output_path, 
    file_prefix, 
    file_version, 
    'non_repeated_measures'
    )
  
  lc.reshape.outcome.generate.yearly.repeated(
    lc_data, 
    upload_to_opal, 
    output_path, 
    file_prefix, 
    file_version, 
    'yearly_repeated_measures'
    )
  
  lc.reshape.outcome.generate.monthly.repeated(
    lc_data, 
    upload_to_opal, 
    output_path, 
    file_prefix, 
    file_version, 
    'monthly_repeated_measures'
    )
  
  lc.reshape.outcome.generate.weekly.repeated(
    lc_data, 
    upload_to_opal, 
    output_path, 
    file_prefix, 
    file_version, 
    'weekly_repeated_measures'
  )
  
  message('######################################################')
  message('  Reshaping successfully finished                     ')
  message('######################################################')
  
})

#' Generate the non repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>%
#'   
lc.reshape.outcome.generate.non.repeated <- local(
  function(
    lc_data, 
    upload_to_opal, 
    output_path, 
    file_prefix, 
    file_version, 
    file_name
    ) {
  message("* Generating: non-repeated measures")
  
  # select the non-repeated measures from the full data set
  non_repeated <- c(
    lc.variables.primary.keys(), 
    lc.variables.outcome.non.repeated()
    )
  
  non_repeated_measures <- lc_data[,non_repeated]
  
  non_repeated_measures <- non_repeated_measures[,colSums(
    is.na(non_repeated_measures))<nrow(non_repeated_measures)
    ]
  
  # add row_id again to preserve child_id
  non_repeated_measures <- data.frame(
    row_id = c(1:length(non_repeated_measures$child_id)), 
    non_repeated_measures
    )
  
  # Write as csv   
  write_csv(
    non_repeated_measures, 
    paste(
      output_path, '/', 
      file_prefix, '_', 
      file_version, '_', 
      file_name, '.csv', 
      sep=""), na = ""
    )
  
  if(upload_to_opal) {
    lc.reshape.outcome.upload(
      file_prefix, 
      file_version, 
      file_name
      )
  }
  
})    

#' Generate the yearly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter
#' @importFrom data.table dcast
#' @importFrom tidyr gather spread
#' 
lc.reshape.outcome.generate.yearly.repeated <- local(
  function(
    lc_data, 
    upload_to_opal, 
    output_path, 
    file_prefix, 
    file_version, 
    file_name
    ) {
    
  # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- whe_ <- age_years <- NULL # ???
  
  message("* Generating: yearly-repeated measures")
  
  file_name <- 'yearly_repeated_measures'
  
  # Select the yearly-repeated measures from the full data set
  yearly_repeated <- c(lc.variables.primary.keys(), lc.variables.outcome.yearly.repeated())
  yearly_repeated_measures <- lc_data[,yearly_repeated]
  
  # First re-arrange the whole data set to long format, unspecific for variable
  long_1 <- yearly_repeated_measures %>% 
    gather(orig_var, whe_, lc.variables.outcome.monthly.repeated(), na.rm=FALSE)
  
  # Create the age_years variable with the regular expression extraction of the year
  long_1$age_years <- as.numeric(numextract(long_1$orig_var))
  
  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub('[[:digit:]]+$', '', long_1$orig_var)
  
  # Use the data.table package for spreading the data again, as tidyverse runs into memory issues 
  long_2 <- dcast(long_1, child_id + age_years ~ variable_trunc, value.var = "cohab_")
  
  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))
  
  # Arrange the variable names based on the original order
  long_yearly <- long_2[
    ,c("row_id", "child_id", "age_years", 
       unique(long_1$variable_trunc))
    ]
  
  # As the data table is still too big for opal, remove those
  # rows, that have only missing values, but keep all rows at age_years=0, so
  # no child_id get's lost:
  
  # Subset of data with age_years = 0 
  zero_year <- long_yearly %>% filter(age_years %in% 0)
  
  # Subset of data with age_years > 0
  later_year <- long_yearly %>% filter(age_years > 0)
  
  # Remove all the rows that are missing only
  later_year <- later_year[
    rowSums(is.na(later_year[,unique(long_1$variable_trunc)])) < 
      length(later_year[,unique(long_1$variable_trunc)]),
    ]
  
  # Bind the 0 year and older data sets together 
  long_yearly <- rbind(zero_year,later_year)
  
  # strip fully na columns
  long_yearly <- long_yearly[
    ,colSums(is.na(long_yearly))<
      nrow(long_yearly)
    ]
  
  write_csv(
    long_yearly, 
    paste(
      output_path, '/', 
      file_prefix, '_', 
      file_version, '_', 
      file_name, '.csv', 
      sep=""), na = ""
    )
  
  if(upload_to_opal) {
    lc.reshape.outcome.upload(
      file_prefix, 
      file_version, 
      file_name
      )
  }
})

#' Generate the monthly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter
#' @importFrom data.table dcast
#' @importFrom tidyr gather spread
#' 
lc.reshape.outcome.generate.monthly.repeated <- local(
  function(
    lc_data, 
    upload_to_opal, 
    output_path, 
    file_prefix, 
    file_version, 
    file_name
    ) {
  # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- heightmes_ <- age_months <- NULL # ???
  
  message('* Generating: monthly-repeated measures')
  
  # Select the monthly repeated measures from the full data set
  monthly_repeated <- c(
    lc.variables.primary.keys(), 
    lc.variables.outcome.monthly.repeated()
    )
  
  monthly_repeated_measures <- lc_data[,monthly_repeated]
  
  # First re-arrange the whole data set to long format, unspecific for variable
  long_1 <- monthly_repeated_measures %>% gather(
    orig_var, heightmes_, lc.variables.outcome.monthly.repeated(), na.rm=FALSE
    )
  
  # Create the age_years and age_months variables with the regular expression extraction of the year
  long_1$age_years  <- as.integer(as.numeric(numextract(long_1$orig_var))/12)
  long_1$age_months <- as.numeric(numextract(long_1$orig_var))
  
  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub('[[:digit:]]+$', '', long_1$orig_var)
  
  # Use the data.table package for spreading the data again, as tidyverse ruins into memory issues 
  long_2 <- dcast(long_1, child_id + age_years + age_months ~ variable_trunc, value.var = "height_")
  
  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))
  
  # Arrange the variable names based on the original order
  long_monthly <- long_2[,c("row_id", "child_id", "age_years", "age_months", unique(long_1$variable_trunc))]
  
  # As the data table is still too big for opal, remove those
  # rows, that have only missing values, but keep all rows at age_years=0, so
  # no child_id get's lost:
  
  # Subset of data with age_months = 0
  zero_monthly <- long_monthly %>%
    filter(age_months %in% 0)
  
  # Subset of data with age_months > 0
  later_monthly <- long_monthly %>%
    filter(age_months > 0)
  
  # Remove all the rows that are missing only: rowSums and is.na combined indicate if 0 or all columns are NA (4), and
  # remove the rows with rowSum values of 4
  later_monthly <- later_monthly[
    rowSums(is.na(later_monthly[,unique(long_1$variable_trunc)])) < 
      length(later_monthly[,unique(long_1$variable_trunc)]),
    ]
  
  # Bind the 0 year and older data sets together 
  long_monthly <- rbind(zero_monthly,later_monthly)
  
  # strip completely missing columns
  long_monthly <- long_monthly[,colSums(is.na(long_monthly))<nrow(long_monthly)]
  
  write_csv(
    long_monthly, 
    paste(output_path, '/', 
          file_prefix, '_', 
          file_version, '_', 
          file_name, '.csv', 
          sep=""), na = ""
    )
  
  if(upload_to_opal) {
    lc.reshape.outcome.upload(
      file_prefix, 
      file_version, 
      file_name
      )
  }
})

#' Generate the weekly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter
#' @importFrom data.table dcast
#' @importFrom tidyr gather spread
#' 
lc.reshape.outcome.generate.weekly.repeated <- local(
  function(
    lc_data, 
    upload_to_opal, 
    output_path, 
    file_prefix, 
    file_version, 
    file_name
  ) {
    # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
    orig_var <- m_sbp_ <- g_age_weeks <- NULL # Gestational age in weeks
    
    message('* Generating: weekly-repeated measures')
    
    # Select the weekly repeated measures from the full data set
    weekly_repeated <- c(
      lc.variables.primary.keys(), 
      lc.variables.outcome.weekly.repeated()
    )
    
    weekly_repeated_measures <- lc_data[,weekly_repeated]
    
    # First re-arrange the whole data set to long format, unspecific for variable
    long_1 <- weekly_repeated_measures %>% gather(
      orig_var, m_sbp_, lc.variables.outcome.weekly.repeated(), na.rm=FALSE
    )
    
    # Create the age_years and age_months variables with the regular expression extraction of the year
    # NB - these weekly dta are pregnancy related so child is NOT BORN YET ---
    #    long_1$age_years  <- as.integer(as.numeric(numextract(long_1$orig_var))/12)
    #    long_1$age_months <- as.numeric(numextract(long_1$orig_var))
    
    # Here we remove the year indicator from the original variable name
    #    long_1$variable_trunc <- gsub('[[:digit:]]+$', '', long_1$orig_var)
    
    # Use the data.table package for spreading the data again, as tidyverse ruins into memory issues 
    #    long_2 <- dcast(long_1, child_id + age_years + age_months ~ variable_trunc, value.var = "height_")
    
    # Create a row_id so there is a unique identifier for the rows
    #    long_2$row_id <- c(1:length(long_2$child_id))
    
    # Arrange the variable names based on the original order
    #    long_monthly <- long_2[,c("row_id", "child_id", "age_years", "age_months", unique(long_1$variable_trunc))]
    
    # As the data table is still too big for opal, remove those
    # rows, that have only missing values, but keep all rows at age_years=0, so
    # no child_id get's lost:
    
    # Subset of data with age_months = 0
    #    zero_monthly <- long_monthly %>%
    #      filter(age_months %in% 0)
    
    # Subset of data with age_months > 0
    #    later_monthly <- long_monthly %>%
    #      filter(age_months > 0)
    
    # Remove all the rows that are missing only: rowSums and is.na combined indicate if 0 or all columns are NA (4), and
    # remove the rows with rowSum values of 4
    #    later_monthly <- later_monthly[
    #      rowSums(is.na(later_monthly[,unique(long_1$variable_trunc)])) < 
    #        length(later_monthly[,unique(long_1$variable_trunc)]),
    #      ]
    
    # Bind the 0 year and older data sets together 
    #    long_weeky <- rbind(zero_monthly,later_monthly)
    
    # strip completely missing columns
    #    long_weeky <- long_weeky[,colSums(is.na(long_weeky))<nrow(long_weeky)]
    
    write_csv(
      long_weeky, 
      paste(output_path, '/', 
            file_prefix, '_', 
            file_version, '_', 
            file_name, '.csv', 
            sep=""), na = ""
    )
    
    if(upload_to_opal) {
      lc.reshape.outcome.upload(
        file_prefix, 
        file_version, 
        file_name
      )
    }
  })

#' Uploading the generated data files
#' 
#' @param file_prefix a date to prefix the file with
#' @param file_version the data release version
#' @param file_name name of the data file
#' 
#' @importFrom opalr opal.file_upload
#' 
lc.reshape.outcome.upload <- local(function(file_prefix, file_version, file_name) {
  upload_directory <- paste('/home/', lifecycle.globals$username, sep = '')
  file_ext <- '.csv'
  
  message(paste('* Upload: ', paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''), sep = ''))
  opal.file_upload(opal = lifecycle.globals$opal, source = paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''), destination = upload_directory)
  
  unlink(paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''))
})

#' Importing generated data files
#' 
#' @param file_prefix a date to prefix the file with
#' @param file_version the data release version
#' @param file_name name of the data file
#' 
#' @importFrom readr read_csv
#' @importFrom opalr opal.post
#' @importFrom opalr opal.projects
#' @importFrom opalr opal.tables
#' @importFrom jsonlite toJSON
#' 
lc.reshape.outcome.import <- local(function(file_prefix, file_version, file_name) {
  
  message('------------------------------------------------------')
  message('  Start importing data files')
  
  file_ext <- '.csv'
  
  projects <- opal.projects(lifecycle.globals$opal)
  project <- readline(paste('Which project you want to upload into: [ ', paste0(projects$name, collapse = ', '), ' ]: ', sep = ''))
  
  if(!(project %in% projects$name)) {
    stop(paste('Invalid projectname: [ ', project,' ]', sep = ''))
  }
  
  tables <- opal.tables(lifecycle.globals$opal, project)
  
  table_name <- ''
  if(file_name %in% tables$name) {
    table = tables$name 
  } 
  
  data <- read_csv(paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''))
  
  message(paste('* Import: ', paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''), sep = ''))
  opal.post(lifecycle.globals$opal, 'datasource', lifecycle.globals$project, 'table', table_name, 'variables', body=toJSON(data), contentType = 'application/x-protobuf+json')  
  
  unlink(paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''))
  
  message('  Succesfully imported the files')
})