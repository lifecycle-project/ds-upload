# install the following packages or skip if you already did so
install.packages('opalr')
# load dsUpload if you did not already
library(dsUpload)

# Create a data.frame object 'login_data' that holds the information about the 
# opal server
login_data <- data.frame(
  server = "https://opal-demo.obiba.org/", 
  user = "administrator", 
  password = "password",
  driver = "OpalDriver"
)
# login to the Opal server
du.login(login_data = login_data)
# If everything went as planned you should see the message:
# Login to: "https://opal-demo.obiba.org/"
# Logged on to: "https://opal-demo.obiba.org/"

# upload the data
# these are the outcome_ath variables
# Note the argument database_name = "mongodb" (check your Opal, might be mysqldb instead)
du.upload(
  cohort_id = "inma",
  dict_version = "1_0",
  dict_kind = "outcome_ath",
  data_version = "1_0",
  database_name = "mongodb",
  data_input_format = "CSV",
  data_input_path = "<PATH_TO_FILE>/demo-athlete-outcome.csv",
  action = "all",
  run_mode = "NORMAL"
)

# You see a warning message:
# [WARNING] Variable dropped because completely missing: [ child_id ] 
# Ignore this and enter y to proceed
#
# Hopefully you see this message:
# * Upload: [ YYYY-MM-DD_HH-MM-SS_1_0_trimester_repeated_measures.csv ] to directory [ outcome_ath ]    
# * Upload: [ YYYY-MM-DD_HH-MM-SS_1_0_non_repeated_measures.csv ] to directory [ outcome_ath ]
# ######################################################
# Converting and import successfully finished         
# ######################################################
# Enter n to skip the quality control
#
# Your data has been uploaded to Opal, you need to import the data.
# Login to your Opal server (https://opal-demo.obiba.org/)
# - In your Dashboard click on 'Explore Data'
# - Select your project, in this example 'lc_inma_outcome_ath_1_0'
# - Click on the 'tables' icon (left hand side)
# - Click on 'Import'
# - Select Data Format 'CSV' and click Next
# - Click browse for Data File
# - Select the folder 'outcome_ath' (dict_kind)
# - Select the uploaded file YYYY-MM-DD_HH-MM-SS_1_0_non_repeated_measures.csv press 'Select'
# - Remove the text in Destination Table and fill in the target table '1_0_non_rep'
# - Press Next
# - In Configure data import leave the settings as is (unchecked) and press Next
# - Review and select the data dictionaries that you wish to import and press Next
# - Review the data that will be imported and press Finish
#
# - Repeat the import process for the trimester data
# - Click on 'Import'
# - Select Data Format 'CSV' and click Next
# - Click browse for Data File
# - Select the folder 'outcome_ath' (dict_kind)
# - Select the uploaded file YYYY-MM-DD_HH-MM-SS_1_0_trimester_repeated_measures.csv press 'Select'
# - Remove the text in Destination Table and fill in the target table '1_0_trimester_rep'
# - Press Next
# - In Configure data import leave the settings as is (unchecked) and press Next
# - Review and select the data dictionaries that you wish to import and press Next
# - Review the data that will be imported and press Finish

