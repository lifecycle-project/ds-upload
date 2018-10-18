# Preprocess the data to use in DataSHIELD

#
## Include the "login" module to login the Opal servers here
#
source("connection.R")

#
## Describe the studies:
#
ds.dim(x='D')

# The "combine" comand allows us to identify the total number of observations and variables pooled across 
# all studies:
ds.dim('D', type='combine')

#
## First step - limit to singleton pregnancies and live births
#
ds.subset(x = 'D', subset = 'D2', logicalOperator = 'plurality==', threshold = 1)
ds.subset(x = 'D2', subset = 'D3', logicalOperator = 'outcome==', threshold = 1)

#
## Create a cohort variable
#
ds.assign(toAssign = "(D3$cohort_id/D3$cohort_id)", newobj = 'cohort', datasources = opals['test-opal1'])
ds.assign(toAssign = "((D3$cohort_id/D3$cohort_id)+1)", newobj = 'cohort', datasources = opals['test-opal2'])

ds.cbind(x=c('D3', 'cohort'), newobj = 'D4', datasources = opals)