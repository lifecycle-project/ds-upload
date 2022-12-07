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
  table = "inma/1_0_outcome_ath_1_0/non_rep",
  driver = "ArmadilloDriver"
)

# create loginframe
login_data <- builder$build()

# login into server
conns <- DSI::datashield.login(
  logins = login_data, 
  symbol = "outcome_ath_nonrep", 
  variables = c("row_id","mother_id","child_id", "cohort_id","CRL_t1"), 
  assign = TRUE
)

# summary of server-side object
dsBaseClient::ds.summary("outcome_ath_nonrep")
# calculate the mean
ds.mean("outcome_ath_nonrep$CRL_t1", datasources = conns)
ds.mean("outcome_ath_nonrep$row_id", datasources = conns)
# Create histogram (should fail)
ds.histogram(x = "outcome_ath_nonrep$CRL_t1", datasources = conns)
