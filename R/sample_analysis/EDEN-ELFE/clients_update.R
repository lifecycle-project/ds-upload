## Install the necassary libraries

install.packages("devtools", "opaladmin")

# load the packages

library("opaladmin")

library("devtools")

# Install clientside package:

install_github("datashield/dsBetaTestClient", ref = "0.2.0")

# setup credential object
server <- c("opal")
url <- c("https://opal.test.molgenis.org")
username <- c("administrator")
password <- c("?01LifeCycle!")
table <- c("MAXIME_TEST.practicalexperiment3")
logindata <- data.frame(server,url,username,password,table)
#logout just in case
datashield.logout(opals)
#log in
opals <- datashield.login(logins=logindata,assign=TRUE)

# install serverside package
dsadmin.install_package(opals, 'dsBetaTest', githubusername='datashield', ref = '0.2.0')

library("dsBetaTestClient")