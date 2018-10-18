# Make a connection to the different Opal instances

#
## Load DataSHIELD libraries to use Opal and DataSHIELD functions in R
#
library(opal)
library(dsBaseClient)
library(dsStatsClient)
library(dsGraphicsClient)
library(dsModellingClient)

#
## Setup environment to connect to Opal instances
#
server <- c("opal-instance1", "opal-instance1")
url <- c("https://opal1.domain.org", "https://opal2.domain.org")
username <- c("usr1", "usr2")
password <- c("pw1", "pw2")
table <- c("Project1.table1", "Project2.table2")
logindata <- data.frame(server,url,username,password,table)

#
## Logout of any running instances of Opal (just in case)
#
datashield.logout(opals)

#
## Login to the defined Opal instances
#
opals <- datashield.login(logins=logindata,assign=TRUE)


