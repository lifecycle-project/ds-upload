[![Build status](https://travis-ci.com/lifecycle-project/ds-upload.svg?branch=master)](https://travis-ci.com/lifecycle-project/ds-upload?branch=master) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# DataSHIELD upload tools
This is a collections of tools used to upload data into DataSHIELD backends. It aids data mangers in the initial stages of uploading data to DataSHIELD backends.

## Usage
Please check [uploading to DataSHIELD guide](https://lifecycle-project.github.io/ds-upload

For detailled function descrptions, please check: [references](https://lifecycle-project.github.io/ds-upload/reference/index.html) and  above.

## Troubleshooting
Please check the [troubleshooting guide](https://github.com/lifecycle-project/ds-upload/blob/master/TROUBLESHOOTING.md).

## Adding new variables
Please check: [adding new variables](https://github.com/lifecycle-project/ds-dictionaries/blob/master/README.md)

## Armadillo 2
dsUpload Version 1.4.x is compatible with Armadillo 2. When installing this version of dsUpload, the `install.packages` command might install the newest version (incompatible) of `MolgenisArmadillo`.
Run these commands to install the correct version of MolgenisArmadillo:
``` r
unloadNamespace("MolgenisArmadillo")
remove.packages("MolgenisArmadillo")
packageurl <- "https://cran.r-project.org/src/contrib/Archive/MolgenisArmadillo/MolgenisArmadillo_1.1.3.tar.gz"
install.packages(packageurl, repos=NULL, type="source")
```
After that you should be able to load `dsUpload` without any problems. 
