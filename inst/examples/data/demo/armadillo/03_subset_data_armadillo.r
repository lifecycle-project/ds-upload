# install the following packages or skip if you already did so
install.packages("MolgenisArmadillo")
install.packages("dplyr")
# Load these libraries
library(MolgenisArmadillo)
library(dplyr)
# First we need to login to the minio (data) server
?MolgenisArmadillo::armadillo.login

MolgenisArmadillo::armadillo.login(
  armadillo = "https://armadillo2-demo.molgenis.net",
  minio = "https://armadillo2-demo-storage.molgenis.net",)

# List the project you have access to
MolgenisArmadillo::armadillo.list_projects()

# List the tables within a certain project
MolgenisArmadillo::armadillo.list_tables("inma")

# We want to create a subset of "1_0_outcome_ath_1_0/non_rep" and "1_0_outcome_ath_1_0/trimester"
# First we need to create a new project where we will save the subset data
subset_name = "inmasubset2"
MolgenisArmadillo::armadillo.create_project(subset_name)
# Check if project is created
MolgenisArmadillo::armadillo.list_projects()

# In order to create a subset we need to download the original data first
non_rep <- MolgenisArmadillo::armadillo.load_table("inma","1_0_outcome_ath_1_0","non_rep")
tri_rep <- MolgenisArmadillo::armadillo.load_table("inma","1_0_outcome_ath_1_0","trimester")
# list column names of the downloaded data
colnames(non_rep)
colnames(tri_rep)

# use dplyr to subset data (https://dplyr.tidyverse.org/)
subset_non_rep <- non_rep %>% select(child_id, CRL_t1)
subset_tri_rep <- tri_rep %>% filter(age_trimester == 1) %>% select(child_id, ga_us_t)

# upload the subsets to the new (subset) project
MolgenisArmadillo::armadillo.upload_table(subset_name,"1_0_outcome_ath_1_0",subset_non_rep,"non_rep")
MolgenisArmadillo::armadillo.upload_table(subset_name,"1_0_outcome_ath_1_0",subset_tri_rep,"trimester")

