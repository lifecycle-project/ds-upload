# load dsUpload if you did not already
library(dsUpload)
# Create a data.frame object 'login_data' that holds the information about the 
# armadillo server and armadillo minio server (on the latter the data is saved)
login_data <- data.frame(
  server = "https://armadillo-demo.molgenis.net",
  driver = "ArmadilloDriver"
)
# login to the Armadillo server
#
# IMPORTANT
#
# Follow this link: https://lifecycle-auth.molgenis.org/ and register an account 
# at Life Science RI (LS) with your institutional account to be able to log on 
# to our Armadillo server. Note that you will not be able to log on directly, 
# but when you click the link and register at LS login, we 
# (molgenis-support@umcg.nl) will make sure that you have the rights to log on.

du.login(login_data = login_data)
# you should see a message in your terminal and a browser window will open
#
#   Login to: "https://armadillo-demo.molgenis.org"
#[1] "We're opening a browser so you can log in with code XXXXXX"
#Logged on to: "https://armadillo-demo.molgenis.org"
#
# The log in code in the terminal should be the same as in the browser,
# please click on the button 'LS LOGIN' and login using your institution credentials
# 
# If everything went as planned you should see the message:
# 'Device login, Successfully connected device'

# upload the data
# these are the outcome_ath variables
#
# See which dictionaries are available:
# https://github.com/lifecycle-project/ds-dictionaries
du.upload(
  cohort_id = "inma",
  dict_version = "1_0",
  dict_kind = "outcome_ath",
  data_version = "1_0",
  data_input_format = "CSV",
  data_input_path = "<PATH_TO_FILE>/demo-athlete-outcome.csv",
  action = "all",
  run_mode = "NORMAL",
  upload = TRUE
)

# You see a warning message:
# [WARNING] Variable dropped because completely missing: [ child_id ] 
# Ignore this and enter y to proceed

# Hopefully you see this message:
# ######################################################
# Converting and import successfully finished         
# ######################################################
# Enter n to skip the quality control
#
# Your data has been uploaded, you can check it out on:
# https://armadillo2-demo-storage-console.molgenis.net
#
# Next you can create subsets for specific projects or research questions:
# 03_subset_data_armadillo.r