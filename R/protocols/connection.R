# Specific DataSHIELD packages
library(opal)
library(dsBaseClient)
library(dsStatsClient)
library(dsGraphicsClient)
library(dsModellingClient)

# connect to opal instances
server <- c("opal-instance1", "opal-instance1")
url <- c("https://opal1.domain.org", "https://opal2.domain.org")
username <- c("usr1", "usr2")
password <- c("pw1", "pw2")
table <- c("Porject1.table1", "Project2.table2")
logindata <- data.frame(server,url,username,password,table)
datashield.logout(opals)
opals <- datashield.login(logins=logindata,assign=TRUE)

# log out
datashield.logout(opals)

# log in
opals <- datashield.login(logins=logindata1,assign=TRUE)