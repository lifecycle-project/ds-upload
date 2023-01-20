# Install devtools, you can skip this step if devtools is already installed
install.packages("devtools")
# After you installed devtools you should be able to load the package by running
# the command 'library(devtools)'
library(devtools)
# Note the red text in the console:
# 'Loading required package: usethis'
# This is a notification but in some cases it will be an error.
# After executing each line make sure you do not have any errors, if so fix 
# these issues first before continuing.
#
# Install/update dsUpload, skip this step if you already installed dsUpload
devtools::install_github("lifecycle-project/ds-upload")
# load dsUpload
library(dsUpload)
# use devtools session_info() to check the version of installed packages
# For dsUpload you can find the latest version here: https://github.com/lifecycle-project/ds-upload/releases
# If you find that you are using an older version please update by running the 
# command 'devtools::install_github("lifecycle-project/ds-upload")'
# If you run into issues you could send the result of session_info() to get better support
devtools::session_info()
