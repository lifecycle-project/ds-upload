#' Reshape Script for R: LifeCycle Harmonized Data
#'
#' @param upload_to_opal do you want automatically upload the files to your opal (default = true)
#' @param data_version version of the data you are going to upload into Opal
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param input_path path for importfile
#' @param output_path path to output directory (default = your working directory)
#' @param dict_kind kind of data to reshape (default = core)
#' @param cohort_id Id of the cohort
#' 
#' @examples 
#' lc.reshape(
#'   upload_to_opal = FALSE, 
#'   data_version = '1_0', 
#'   input_format = 'SPSS', 
#'   input_path = 'C:\MyDocuments\source_file.sav', 
#'   output_path = 'C:\MyDocuments\output_file.csv')
#'
#' @importFrom readxl read_xlsx
#' @export
lc.reshape <- local(function(upload_to_opal = TRUE, data_version, input_format = 'CSV', dict_kind = 'core', input_path, cohort_id, output_path) {
  
  message('######################################################')
  message('  Start reshaping data                                ')
  message('######################################################')
  message("* Setup: load data and set output directory")
  message('------------------------------------------------------')
  
  lc_data <- lc.read.source.file(input_path, input_format)
  
  file_prefix <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
  
  
  # Check which variables are missing in the study as compared to the full variable list (if character(0), continue, otherwise
  # check the list of variables in the original harmonized data)
  # lc_variables <- c(lc.variables.primary.keys(), lc.variables.core.non.repeated(), lc.variables.core.yearly.repeated(), lc.variables.core.monthly.repeated())
  # missing <- setdiff(lc_variables, names(lc_data))
  # Ammend the data with columns
  # lc_data[missing] <- NA
  
  lc.reshape.generate.non.repeated(lc_data, upload_to_opal, output_path, file_prefix, dict_kind, file_version, 'non_repeated_measures', cohort_id)
  lc.reshape.generate.yearly.repeated(lc_data, upload_to_opal, output_path, file_prefix, dict_kind, file_version, 'yearly_repeated_measures', cohort_id)
  lc.reshape.generate.monthly.repeated(lc_data, upload_to_opal, output_path, file_prefix, dict_kind, file_version, 'monthly_repeated_measures', cohort_id)
  
  if(dict_kind == "outcome"){
    lc.reshape.generate.weekly.repeated(lc_data, upload_to_opal, output_path, file_prefix, dict_kind, file_version, 'weekly_repeated_measures', cohort_id)
  }
  
  if(dict_kind == 'core' & data_version != "1_0"){
    lc.reshape.generate.trimesterly.repeated(lc_data, upload_to_opal, output_path, file_prefix, dict_kind, file_version, 'trimesterly_repeated_measures', cohort_id)
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
#' @param cohort_id ID of the cohort
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>%
#' @importFrom readxl read_xlsx
#'   
lc.reshape.generate.non.repeated <- local(function(lc_data, upload_to_opal, output_path, file_prefix, dict_kind, file_version, file_name, cohort_id) {
  message("* Generating: non-repeated measures")
  
  # Retrieve dictionnary 
  
  dict_names <- paste('.+', cohort_id, '+', '.+repeated\\.xlsx', sep = '')
  dict_file_list <- list.files('.', pattern = dict_names)
  
  dict_table_non_repeated <- dict_file_list[grep("non_repeated", dict_file_list)]
  
  lc_variables_non_repeated_dict <- read_xlsx(path = dict_table_non_repeated, sheet = 1)
  
  lc_variables_non_repeated_dict <- as.data.frame(lc_variables_non_repeated_dict)
  
  ## Generate the variable list:
  
  lc_variables_non_repeated <- lc_variables_non_repeated_dict$name
  
  # select the non-repeated measures from the full data set
  non_repeated <- c(lc.variables.primary.keys(), lc_variables_non_repeated)
  non_repeated_measures <- lc_data[, which(colnames(lc_data) %in% non_repeated)]
  
  # strip the rows with na values
  non_repeated_measures <- non_repeated_measures[,colSums(is.na(non_repeated_measures))<nrow(non_repeated_measures)]
  
  # add row_id again to preserve child_id
  non_repeated_measures <- data.frame(row_id = c(1:length(non_repeated_measures$child_id)), non_repeated_measures)
  
  # Write as csv   
  write_csv(non_repeated_measures, paste(output_path, '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, '.csv', sep=""), na = "")
  
  if(upload_to_opal) {
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
#' @param cohort_id ID of the cohort
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter select_if
#' @importFrom data.table dcast
#' @importFrom tidyr gather spread
#' @importFrom readxl read_xls
#' 
lc.reshape.generate.yearly.repeated <- local(function(lc_data, upload_to_opal, output_path, file_prefix, dict_kind, file_version, file_name, cohort_id) {
  # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- cohab_ <- age_years <- NULL
  
  message("* Generating: yearly-repeated measures")
  
  file_name <- 'yearly_repeated_measures'
  
  # Retrieve dictionnary 
  
  dict_names <- paste('.+', cohort_id, '+', '.+repeated\\.xlsx', sep = '')
  dict_file_list <- list.files('.', pattern = dict_names)
  
  dict_table_yearly_repeated <- dict_file_list[grep("yearly_repeated", dict_file_list)]
  
  lc_variables_yearly_repeated_dict <- read_xlsx(path = dict_table_yearly_repeated, sheet = 1)
  
  lc_variables_yearly_repeated_dict <- as.data.frame(lc_variables_yearly_repeated_dict)
  
  ## Get the number of repetition
  
  for (i in lc_variables_yearly_repeated_dict$name){
    
    lc_variables_yearly_repeated_dict[lc_variables_yearly_repeated_dict$name == i,'n'] <- length(grep(paste(i, '[[:digit:]]', sep = ''), colnames(lc_data)))
    
    lc_variables_yearly_repeated_dict[lc_variables_yearly_repeated_dict$name == i & lc_variables_yearly_repeated_dict$n != 0,'n'] <-
      lc_variables_yearly_repeated_dict[lc_variables_yearly_repeated_dict$name == i & lc_variables_yearly_repeated_dict$n != 0,'n'] - 1
    
  }
  
  ## Generate the variable list:
  
  lc_variables_yearly_repeated <- character()
  
  for (i in lc_variables_yearly_repeated_dict$name){
    
    if(lc_variables_yearly_repeated_dict[lc_variables_yearly_repeated_dict$name == i, 'n'] != 0){
      
      lc_variables_yearly_repeated <- append(lc_variables_yearly_repeated, c(paste(lc_variables_yearly_repeated_dict$name[lc_variables_yearly_repeated_dict$name == i],
                                                                             1:lc_variables_yearly_repeated_dict[lc_variables_yearly_repeated_dict$name == i, 'n'],
                                                                             sep = '')))
      
    }
  }
  
  # Select the non-repeated measures from the full data set
  yearly_repeated <- c(lc.variables.primary.keys(), lc_variables_yearly_repeated)
  yearly_repeated_measures <- lc_data[,which(colnames(lc_data) %in% yearly_repeated)]
  
  # First re-arrange the whole data set to long format, unspecific for variable
  long_1 <- yearly_repeated_measures %>% 
    gather(orig_var, cohab_, lc_variables_yearly_repeated, na.rm=TRUE)
  
  # Create the age_years variable with the regular expression extraction of the year
  long_1$age_years <- as.numeric(numextract(long_1$orig_var))
  
  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub('[[:digit:]]+$', '', long_1$orig_var)
  
  # Use the data.table package for spreading the data again, as tidyverse runs into memory issues 
  long_2 <- dcast(long_1, child_id + age_years ~ variable_trunc, value.var = "cohab_")
  
  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))
  
  # Arrange the variable names based on the original order
  long_yearly <- long_2[,c("row_id", "child_id", "age_years", unique(long_1$variable_trunc))]
  
  # As the data table is still too big for opal, remove those
  # rows, that have only missing values, but keep all rows at age_years=0, so
  # no child_id get's lost:
  
  # Subset of data with age_years = 0 
  zero_year <- long_yearly %>% filter(age_years %in% 0)
  
  # Subset of data with age_years > 0
  later_year <- long_yearly %>% filter(age_years > 0)
  
  # Bind the 0 year and older data sets together 
  long_yearly <- rbind(zero_year,later_year)
  
  write_csv(long_yearly, paste(output_path, '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, '.csv', sep=""), na = "")
  
  if(upload_to_opal) {
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
#' @param cohort_id ID of the cohort
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter
#' @importFrom data.table dcast
#' @importFrom tidyr gather spread
#' @importFrom readxl read_xlsx
#' 
lc.reshape.generate.monthly.repeated <- local(function(lc_data, upload_to_opal, output_path, file_prefix, dict_kind, file_version, file_name, cohort_id) {
  # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- height_ <- age_months <- NULL
  
  message('* Generating: monthly-repeated measures')
  
  # Retrieve dictionnary 
  
  dict_names <- paste('.+', cohort_id, '+', '.+repeated\\.xlsx', sep = '')
  dict_file_list <- list.files('.', pattern = dict_names)
  
  dict_table_monthly_repeated <- dict_file_list[grep("monthly_repeated", dict_file_list)]
  
  lc_variables_monthly_repeated_dict <- read_xlsx(path = dict_table_monthly_repeated, sheet = 1)
  
  lc_variables_monthly_repeated_dict <- as.data.frame(lc_variables_monthly_repeated_dict)
  
  ## Get the number of repetition
  
  for (i in lc_variables_monthly_repeated_dict$name){
    
    lc_variables_monthly_repeated_dict[lc_variables_monthly_repeated_dict$name == i,'n'] <- length(grep(paste(i, '[[:digit:]]', sep = ''), colnames(lc_data)))
    
    lc_variables_monthly_repeated_dict[lc_variables_monthly_repeated_dict$name == i & lc_variables_monthly_repeated_dict$n != 0,'n'] <-
      lc_variables_monthly_repeated_dict[lc_variables_monthly_repeated_dict$name == i & lc_variables_monthly_repeated_dict$n != 0,'n'] - 1
    
  }
  
  ## Generate the variable list:
  
  lc_variables_monthly_repeated <- character()
  
  for (i in lc_variables_monthly_repeated_dict$name){
    
    if(lc_variables_monthly_repeated_dict[lc_variables_monthly_repeated_dict$name == i, 'n'] != 0){
      
      lc_variables_monthly_repeated <- append(lc_variables_monthly_repeated, c(paste(lc_variables_monthly_repeated_dict$name[lc_variables_monthly_repeated_dict$name == i],
                                                                             1:lc_variables_monthly_repeated_dict[lc_variables_monthly_repeated_dict$name == i, 'n'],
                                                                             sep = '')))
      
    }
  }
  
  # Select the non-repeated measures from the full data set
  monthly_repeated <- c(lc.variables.primary.keys(), lc_variables_monthly_repeated)
  monthly_repeated_measures <- lc_data[, which(colnames(lc_data) %in% monthly_repeated)]
  
  # First re-arrange the whole data set to long format, unspecific for variable
  long_1 <- monthly_repeated_measures %>% 
    gather(orig_var, height_, lc_variables_monthly_repeated, na.rm=TRUE)
  
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
  later_monthly <- later_monthly[rowSums(is.na(later_monthly[,unique(long_1$variable_trunc)])) < 
                                   length(later_monthly[,unique(long_1$variable_trunc)]),]
  
  # Bind the 0 year and older data sets together 
  long_monthly <- rbind(zero_monthly,later_monthly)
  
  write_csv(long_monthly, paste(output_path, '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, '.csv', sep=""), na = "")
  
  if(upload_to_opal) {
    lc.reshape.upload(file_prefix, dict_kind, file_version, file_name)
  }
})

#' Generate the weekly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated, weekly, trimesterly or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter
#' @importFrom data.table dcast
#' @importFrom tidyr gather spread
#' @importFrom readxl read_xlsx
#' 
lc.reshape.outcome.generate.weekly.repeated <- local(
  function(
    lc_data, 
    upload_to_opal, 
    output_path, 
    file_prefix, 
    dict_kind,
    file_version, 
    file_name
  ) {
    
    # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
    orig_var <- m_sbp_ <- g_age_weeks <- NULL # Gestational age in weeks
    
    message('* Generating: weekly-repeated measures')
    
    # Retrieve dictionnary 
    
    dict_names <- paste('.+', cohort_id, '+', '.+repeated\\.xlsx', sep = '')
    dict_file_list <- list.files('.', pattern = dict_names)
    
    dict_table_weekly_repeated <- dict_file_list[grep("weekly_repeated", dict_file_list)]
    
    lc_variables_weekly_repeated_dict <- read_xlsx(path = dict_table_weekly_repeated, sheet = 1)
    
    lc_variables_weekly_repeated_dict <- as.data.frame(lc_variables_weekly_repeated_dict)
    
    ## Get the number of repetition
    
    for (i in lc_variables_weekly_repeated_dict$name){
      
      lc_variables_weekly_repeated_dict[lc_variables_weekly_repeated_dict$name == i,'n'] <- length(grep(paste(i, '[[:digit:]]', sep = ''), colnames(lc_data)))
      
      lc_variables_weekly_repeated_dict[lc_variables_weekly_repeated_dict$name == i & lc_variables_weekly_repeated_dict$n != 0,'n'] <-
        lc_variables_weekly_repeated_dict[lc_variables_weekly_repeated_dict$name == i & lc_variables_weekly_repeated_dict$n != 0,'n'] - 1
      
    }
    
    ## Generate the variable list:
    
    lc_variables_weekly_repeated <- character()
    
    for (i in lc_variables_weekly_repeated_dict$name){
      
      if(lc_variables_weekly_repeated_dict[lc_variables_weekly_repeated_dict$name == i, 'n'] != 0){
        
        lc_variables_weekly_repeated <- append(lc_variables_weekly_repeated, c(paste(lc_variables_weekly_repeated_dict$name[lc_variables_weekly_repeated_dict$name == i],
                                                                                       1:lc_variables_weekly_repeated_dict[lc_variables_weekly_repeated_dict$name == i, 'n'],
                                                                                       sep = '')))
        
      }
    }
    
    # Select the weekly-repeated measures from the full data set
    weekly_repeated <- c(lc.variables.primary.keys(), lc_variables_weekly_repeated)
    weekly_repeated_measures <- lc_data[, which(colnames(lc_data) %in% weekly_repeated)]
    
    # First re-arrange the whole data set to long format, unspecific for variable
    long_1 <- weekly_repeated_measures %>% gather(
      orig_var, m_sbp_, lc_variables_weekly_repeated, na.rm=FALSE
    )
    
    # Create the age_years and age_months variables with the regular expression extraction of the year
    # NB - these weekly dta are pregnancy related so child is NOT BORN YET ---
    long_1$age_years  <- as.integer(as.numeric(numextract(long_1$orig_var))/52)
    long_1$age_weeks  <- as.integer(numextract(long_1$orig_var))
    
    # Here we remove the year indicator from the original variable name
    long_1$variable_trunc <- gsub('[[:digit:]]+$', '', long_1$orig_var)
    
    # Use the data.table package for spreading the data again, as tidyverse ruins into memory issues 
    long_2 <- dcast(long_1, child_id + age_years + age_weeks ~ variable_trunc, value.var = "m_sbp_")
    
    # Create a row_id so there is a unique identifier for the rows
    long_2$row_id <- c(1:length(long_2$child_id))
    
    # Arrange the variable names based on the original order
    long_weekly <- long_2[,c("row_id", "child_id", "age_years", "age_weeks", unique(long_1$variable_trunc))]
    
    # As the data table is still too big for opal, remove those
    # rows, that have only missing values, but keep all rows at age_years=0, so
    # no child_id get's lost:
    
    # Subset of data with age_months = 0
    zero_weekly <- long_weekly %>%
      filter(age_weeks %in% 0)
    
    # Subset of data with age_months > 0
    later_weekly <- long_weekly %>%
      filter(age_weeks > 0)
    
    # Remove all the rows that are missing only: rowSums and is.na combined indicate if 0 or all columns are NA (4), and
    # remove the rows with rowSum values of 4
    later_weekly <- later_weekly[
      rowSums(is.na(later_weekly[,unique(long_1$variable_trunc)])) < 
        length(later_weekly[,unique(long_1$variable_trunc)]),
      ]
    
    # Bind the 0 year and older data sets together 
    long_weekly <- rbind(zero_weekly,later_weekly)
    
    # strip completely missing columns
    long_weekly <- long_weekly[,colSums(is.na(long_weekly))<nrow(long_weekly)]
    
    write_csv(
      long_weekly, 
      paste(output_path, '/', 
            file_prefix, '_', 
            dict_kind, '_', 
            file_version, '_', 
            file_name, '.csv', 
            sep=""), na = ""
    )
    
    if(upload_to_opal) {
      lc.reshape.upload(
        file_prefix, 
        dict_kind,
        file_version, 
        file_name
      )
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
#' @importFrom dplyr %>% filter
#' @importFrom data.table dcast
#' @importFrom tidyr gather spread
#' @importFrom readxl read_xlsx
#' 

lc.reshape.core.generate.trimesterly.repeated <- local(function(lc_data, upload_to_opal, output_path, file_prefix, dict_kind, file_version, file_name) {
  # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- smk_t <- age_trimesters <- NULL
  
  message('* Generating: trimesterly-repeated measures')
  
  # Retrieve dictionnary 
  
  dict_names <- paste('.+', cohort_id, '+', '.+repeated\\.xlsx', sep = '')
  dict_file_list <- list.files('.', pattern = dict_names)
  
  dict_table_trimesterly_repeated <- dict_file_list[grep("trimesterly_repeated", dict_file_list)]
  
  lc_variables_trimesterly_repeated_dict <- read_xlsx(path = dict_table_trimesterly_repeated, sheet = 1)
  
  lc_variables_trimesterly_repeated_dict <- as.data.frame(lc_variables_trimesterly_repeated_dict)
  
  ## Get the number of repetition
  
  for (i in lc_variables_trimesterly_repeated_dict$name){
    
    lc_variables_trimesterly_repeated_dict[lc_variables_trimesterly_repeated_dict$name == i,'n'] <- length(grep(paste(i, '[[:digit:]]', sep = ''), colnames(lc_data)))
    
    lc_variables_trimesterly_repeated_dict[lc_variables_trimesterly_repeated_dict$name == i & lc_variables_trimesterly_repeated_dict$n != 0,'n'] <-
      lc_variables_trimesterly_repeated_dict[lc_variables_trimesterly_repeated_dict$name == i & lc_variables_trimesterly_repeated_dict$n != 0,'n'] - 1
    
  }
  
  ## Generate the variable list:
  
  lc_variables_trimesterly_repeated <- character()
  
  for (i in lc_variables_trimesterly_repeated_dict$name){
    
    if(lc_variables_trimesterly_repeated_dict[lc_variables_trimesterly_repeated_dict$name == i, 'n'] != 0) {
      lc_variables_trimesterly_repeated <- append(lc_variables_trimesterly_repeated, c(paste(lc_variables_trimesterly_repeated_dict$name[lc_variables_trimesterly_repeated_dict$name == i],
                                                                                   1:lc_variables_trimesterly_repeated_dict[lc_variables_trimesterly_repeated_dict$name == i, 'n'],
                                                                                   sep = '')))
      
    }
  }
  
  # Select the trimesterly repeated measures from the full data set
  trimesterly_repeated <- c(lc.variables.primary.keys(), lc_variables_trimesterly_repeated)
  trimesterly_repeated_measures <- lc_data[, which(colnames(lc_data) %in% trimesterly_repeated)]
  
  if(nrow(lc.data.frame.remove.all.na.rows(trimesterly_repeated_measures)) <= 0) {
    message('* WARNING: No trimesterly-repeated measures found in this set')
    return()
  } 
  
  # First re-arrange the whole data set to long format, unspecific for variable
  long_1 <- trimesterly_repeated_measures %>% 
    gather(orig_var, smk_t, lc_variables_trimesterly_repeated, na.rm=TRUE)
  
  # Create the age_years and age_months variables with the regular expression extraction of the year
  long_1$age_years  <- as.integer(as.numeric(numextract(long_1$orig_var))/4)
  long_1$age_trimesters <- as.numeric(numextract(long_1$orig_var))
  
  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub('[[:digit:]]+$', '', long_1$orig_var)
  
  # Use the data.table package for spreading the data again, as tidyverse ruins into memory issues 
  long_2 <- dcast(long_1, child_id + age_years + age_trimesters ~ variable_trunc, value.var = "smk_t")
  
  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))
  
  # Arrange the variable names based on the original order
  long_trimesterly <- long_2[,c("row_id", "child_id", "age_years", "age_trimesters", unique(long_1$variable_trunc))]
  
  # As the data table is still too big for opal, remove those
  # rows, that have only missing values, but keep all rows at age_years=0, so
  # no child_id get's lost:
  
  # Subset of data with age_months = 0
  zero_trimesterly <- long_trimesterly %>%
    filter(age_trimesters %in% 0)
  
  # Subset of data with age_months > 0
  long_trimesterly <- long_trimesterly %>%
    filter(age_trimesters > 0)
  
  write_csv(long_trimesterly, paste(output_path, '/', file_prefix, '_', dict_kind, '_', file_version, '_', file_name, '.csv', sep=""), na = "")
  
  if(upload_to_opal) {
    lc.reshape.upload(
      file_prefix, 
      dict_kind,
      file_version, 
      file_name
    )
  }
})