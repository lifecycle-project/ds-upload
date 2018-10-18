# Show summaries of what is in the different Opal servers

#
## Include the "login" module to login the Opal servers here
#
source("login.R")

#
## What is there?
#
ds.ls()

#
## Detail of table
#
ds.summary('D')

#
## Describe the studies:
#
ds.dim(x='D')