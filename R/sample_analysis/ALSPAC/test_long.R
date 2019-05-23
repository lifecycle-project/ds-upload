library(opal)
library(dsBaseClient)
library(dsStatsClient)
library(dsGraphicsClient)
library(dsModellingClient)
library(dsBetaTestClient)
sessionInfo()

server <- c("dnbc", "alspac") 
url <- c("https://opal-dnbc.test.molgenis.org", "https://opal-alspac.test.molgenis.org") 
table <- c("lifecycle_dnbc.1_0_yearly_repeated_measures", "lifecycle_dnbc.1_0_non_repeated_measures", "lifecycle_alspac.1_0_non_repeated_measures", "lifecycle_alspac.1_0_yearly_repeated_measures") 

datashield.logout(opals)
#log in
logindata <- data.frame(server,url,user="administrator",password="admin",table=table)

# login and assign specific variables
myvar_g <- list("row_id", "child_id", "edu_m_", "ga_bj", "height_", "weight_")
opals <- datashield.login(logins=logindata, assign=FALSE)

myvar_s <- list("child_id", "ga_bj", "sex")
datashield.assign(opals, "DSsin", "test.singlemeasures", variables=myvar_s)
myvar_r <- list("child_id", "lifecycle_dnbc.1_0_yearly_repeated_measures", "age_years")
datashield.assign(opals, "DSrep", "test.repeated_measures_long", variables = myvar_r)

ds.ls()
ds.dim('DSgr')
ds.colnames('DSgr')
ds.dim('DSsin')
ds.colnames('DSsin')
ds.dim('DSrep')
ds.colnames('DSrep')

#
# You have to enable the DANGER methods
#
Rgr <- ds.DANGERdfEXTRACT("DSgr")[[1]][[1]]
dim(Rgr)
head(Rgr, n=10)
Rsin <- ds.DANGERdfEXTRACT("DSsin")[[1]][[1]]
dim(Rsin)
Rrep <- ds.DANGERdfEXTRACT("DSrep")[[1]][[1]]
dim(Rrep)
head(Rrep, n=10)


ds.colnames('DSrep')
ds.reShape.o(data.name='DSrep',timevar.name = 'age_years',idvar.name = 'child_id',v.names=c('edu_m_'),direction = 'wide', newobj = "DSrep_wide")
ds.ls()
ds.dim('DSrep_wide')
ds.colnames('DSrep_wide')

ds.class('DSrep_wide$child_id')

#
# You have to enable the DANGER methods
#
Rrep_wide <- ds.DANGERdfEXTRACT("DSrep_wide")[[1]][[1]]
head(Rrep_wide,n=10)

ds.ls()
ds.summary('DSgr')
ds.summary('DSrep_wide$edu_m_.0')


ds.colnames('DSgr')
ds.reShape.o(data.name='DSgr',timevar.name = 'age_months', idvar.name = 'child_id', v.names=c('age_years','height_', 'weight_'),direction = 'wide', newobj = 'DSgr_wide')


ds.ls()
ds.dim('DSgr_wide')
ds.colnames('DSgr_wide')
Rgr_wide <- ds.DANGERdfEXTRACT("DSgr_wide")[[1]][[1]]
head(Rgr_wide,n=10)

ds.merge.o(x.name = 'DSrep_wide', y.name = 'DSgr_wide', by.x.names = 'child_id', by.y.names = 'child_id', newobj = 'DSmerged_rep_gr')

ds.dim('DSmerged_rep_gr')
ds.colnames('DSmerged_rep_gr')
