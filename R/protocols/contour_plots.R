# Contour plots or heat map plots are used in place of scatter plots 
# (which cannot be used as they are potentially disclosive)
# in DataSHIELD to visualize correlation patterns 

#
## Include login.R
#
source("login.R")

#
## (optional) Include summaries.R
#
# source("summaries.R")

# For e.g.:
ds.contourPlot(x='D4$ga_bj', y='D4$agebirth_m_d')
ds.heatmapPlot(x='D4$ga_bj', y='D4$agebirth_m_d')

#
## Mean centre maternal age:
#
mean_cen = ds.mean(x='D4$agebirth_m_d')
my_str = paste0('D4$agebirth_m_d-', mean_cen)
ds.assign(toAssign=my_str, newobj='agebirth_m_d_c')
ds.histogram('agebirth_m_d_c')
ds.cbind(x=c('D4', 'agebirth_m_d_c'), newobj = 'D6', datasources = opals)

#
## Fit the model. This is fitting one model to both datasets as if they were pooled together
#
ds.glm(formula = 'D6$ga_bj~D6$preg_smk+D6$agebirth_m_d_c+D6$edu_m_0+D6$cohort', data = 'D6', family = 'gaussian')