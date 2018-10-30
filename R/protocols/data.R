
#' The "combine" comand allows us to identify the total number of observations and variables pooled across
#' all studies:
#'
#' @return combinedSet a comnbined set across all studies
#'
#' @importFrom opal datashield
#'
#' @export
lc.get-all-data <- local(function() {
  ds.dim(x='D')
  ds.dim('D', type='combine')
  return D
}


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