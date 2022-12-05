# load dsUpload if you did not already
library(dsUpload)
# Create a data.frame object 'login_data' that holds the information about the 
# armadillo server and armadillo minio server (on the latter the data is saved)
login_data <- data.frame(
  server = "https://armadillo.test.molgenis.org",
  storage = "https://armadillo-minio.test.molgenis.org",
  driver = "ArmadilloDriver"
)
# login to the Armadillo server
du.login(login_data = login_data)
# you should see a message in your terminal and a browser window will open
#
#   Login to: "https://armadillo.test.molgenis.org"
#[1] "We're opening a browser so you can log in with code XXXXXX"
#Logged on to: "https://armadillo.test.molgenis.org"
#
# The log in code in the terminal should be the same as in the browser,
# please click on the button 'LS LOGIN' and login using your institution credentials
# 
# If everything went as planned you should see the message:
# 'Device login, Successfully connected device'

du.upload(
  cohort_id = "inma",
  dict_version = "1_0",
  dict_kind = "outcome_ath",
  data_version = "1_0",
  data_input_format = "CSV",
  data_input_path = "/home/gcc/Documents/git/ds-upload/inst/examples/data/demo/demo-athlete-outcome.csv",
  action = "all",
  run_mode = "NORMAL",
  upload = TRUE,
  #database_name = "mysqldb/mongodb"
)
