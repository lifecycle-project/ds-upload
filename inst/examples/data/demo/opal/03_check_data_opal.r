# install the following packages or skip if you already did so
install.packages("DSI")
install.packages("dsBaseClient", repos = c("http://cran.datashield.org", "https://cloud.r-project.org/"), dependencies = TRUE)
install.packages("DSOpal")
# Load these libraries
library(dsBaseClient)
library(DSOpal)

# build the login dataframe
builder <- DSI::newDSLoginBuilder()
builder$append(
  server = "opal-demo",
  url = "https://opal-demo.obiba.org/",
  user = "administrator",
  password = "password"
)

# create loginframe
login_data <- builder$build()

# login into server
conns <- DSI::datashield.login(logins = login_data)

DSI::datashield.assign.table(
  conns = conns,
  symbol = "outcome_ath_nonrep",
  table = "lc_inma_outcome_ath_1_0.1_0_non_rep"
)

# summary of server-side object
dsBaseClient::ds.summary("outcome_ath_nonrep")
# calculate the mean
ds.mean("outcome_ath_nonrep$CRL_t1", datasources = conns)
ds.mean("outcome_ath_nonrep$row_id", datasources = conns)
# Create histogram (should fail)
ds.histogram(x = "outcome_ath_nonrep$CRL_t1", datasources = conns)
# See why it fails
DSI::datashield.errors()
