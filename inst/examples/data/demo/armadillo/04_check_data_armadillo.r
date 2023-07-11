# install the following packages or skip if you already did so
install.packages("DSI")
install.packages("DSMolgenisArmadillo")
install.packages('dsBaseClient', repos=c(getOption('repos'), 'http://cran.obiba.org'), dependencies=TRUE)
# Load these libraries
library(dsBaseClient)
library(DSMolgenisArmadillo)

# specify server url
armadillo_url <- "https://armadillo-demo.molgenis.net"

# get token from central authentication server
token <- DSMolgenisArmadillo::armadillo.get_token(armadillo_url)

# build the login dataframe
builder <- DSI::newDSLoginBuilder()
builder$append(
  server = "armadillo-test-molgenis",
  url = armadillo_url,
  token = token,
  table = "inma/1_0_outcome_ath_1_0/trimester_rep",
  driver = "ArmadilloDriver"
)

# create loginframe
login_data <- builder$build()

# login into server
conns <- DSI::datashield.login(
  logins = login_data, 
  symbol = "outcome_ath_trimester", 
  variables = c("row_id","child_id", "age_trimester","ga_us_t"), 
  assign = TRUE
)

# summary of server-side object
full_summary <- dsBaseClient::ds.summary("outcome_ath_trimester")
# calculate the mean
full_mean_v1 <- ds.mean("outcome_ath_trimester$ga_us_t", datasources = conns)
full_mean_v2 <- ds.mean("outcome_ath_trimester$row_id", datasources = conns)

# repeat the same with the subset made in 03_subset_data_armadillo.r

# specify server url
armadillo_url <- "https://armadillo-demo.molgenis.net"

# get token from central authentication server
token <- DSMolgenisArmadillo::armadillo.get_token(armadillo_url)

# build the login dataframe
builder <- DSI::newDSLoginBuilder()
builder$append(
  server = "armadillo-test-molgenis-subset",
  url = armadillo_url,
  token = token,
  table = "inmasubset2/1_0_outcome_ath_1_0/trimester_rep",
  driver = "ArmadilloDriver"
)

# create loginframe
login_data <- builder$build()

# login into server
conns <- DSI::datashield.login(
  logins = login_data, 
  symbol = "outcome_ath_trimester", 
  variables = c("child_id","ga_us_t"), 
  assign = TRUE
)

# summary of server-side object
subset_summary <- dsBaseClient::ds.summary("outcome_ath_trimester")
# calculate the mean
subset_mean_v1 <- ds.mean("outcome_ath_trimester$ga_us_t", datasources = conns)
subset_mean_v2 <- ds.mean("outcome_ath_trimester$row_id", datasources = conns)

# compare summary
full_summary
subset_summary

# compare 1st mean calculation
full_mean_v1
subset_mean_v2

# Optional: delete project
library(MolgenisArmadillo)
# steps needed to delete project inma
MolgenisArmadillo::armadillo.list_projects()
MolgenisArmadillo::armadillo.list_tables("inma")
MolgenisArmadillo::armadillo.delete_table("inma","1_0_outcome_ath_1_0","non_rep")
MolgenisArmadillo::armadillo.delete_table("inma","1_0_outcome_ath_1_0","trimester_rep")
MolgenisArmadillo::armadillo.delete_project("inma")

# steps needed to delete project 
MolgenisArmadillo::armadillo.list_projects()
MolgenisArmadillo::armadillo.list_tables("inmasubset2")
MolgenisArmadillo::armadillo.delete_table("inmasubset2","1_0_outcome_ath_1_0","non_rep")
MolgenisArmadillo::armadillo.delete_table("inmasubset2","1_0_outcome_ath_1_0","trimester_rep")
MolgenisArmadillo::armadillo.delete_project("inmasubset2")