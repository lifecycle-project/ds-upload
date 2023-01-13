# install the following packages or skip if you already did so
install.packages("DSI")
install.packages("DSMolgenisArmadillo")
install.packages("dsBaseClient", repos = c("http://cran.datashield.org", "https://cloud.r-project.org/"), dependencies = TRUE)
# Load these libraries
library(dsBaseClient)
library(DSMolgenisArmadillo)

# specify server url
armadillo_url <- "https://armadillo.test.molgenis.org"

# get token from central authentication server
token <- DSMolgenisArmadillo::armadillo.get_token(armadillo_url)

# build the login dataframe
builder <- DSI::newDSLoginBuilder()
builder$append(
  server = "armadillo-test-molgenis",
  url = armadillo_url,
  token = token,
  table = "inma/1_0_outcome_ath_1_0/trimester",
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
dsBaseClient::ds.summary("outcome_ath_trimester")
# calculate the mean
ds.mean("outcome_ath_trimester$ga_us_t", datasources = conns)
ds.mean("outcome_ath_trimester$row_id", datasources = conns)

# repeat the same with the subset made in 04_subset_data_armadillo.r

# specify server url
armadillo_url <- "https://armadillo.test.molgenis.org"

# get token from central authentication server
token <- DSMolgenisArmadillo::armadillo.get_token(armadillo_url)

# build the login dataframe
builder <- DSI::newDSLoginBuilder()
builder$append(
  server = "armadillo-test-molgenis-subset",
  url = armadillo_url,
  token = token,
  table = "inmasubset1/1_0_outcome_ath_1_0/trimester",
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
dsBaseClient::ds.summary("outcome_ath_trimester")
# calculate the mean
ds.mean("outcome_ath_trimester$ga_us_t", datasources = conns)
ds.mean("outcome_ath_trimester$row_id", datasources = conns)
