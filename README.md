[![Build status](https://travis-ci.com/lifecycle-project/ds-upload.svg?branch=master)](https://travis-ci.com/lifecycle-project/ds-upload?branch=master) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# DataSHIELD upload tools
This is a collections of tools used to upload data into DataSHIELD backends. It aids data mangers in the initial stages of uploading data to DataSHIELD backends.

## Usage
Please check [uploading to DataSHIELD guide](https://lifecycle-project.github.io/ds-upload)

For detailled function descrptions, please check: [references](https://lifecycle-project.github.io/ds-upload/reference/index.html) and  above.

## Troubleshooting
Please check the [troubleshooting guide](https://github.com/lifecycle-project/ds-upload/blob/master/TROUBLESHOOTING.md).

## Adding new variables
Please check: [adding new variables](https://github.com/lifecycle-project/ds-dictionaries/blob/master/README.md)

## Armadillo 3
`dsUpload` Version 5.x.x is compatible with Armadillo 3. You should be able to install [dsUpload](https://lifecycle-project.github.io/ds-upload/articles/dsUpload.html) without specifying any additional versions. To install dsUpload, you have to install devtools first:
``` r
install.packages("devtools")
```
Then you will be able to install the newest version of dsUpload:
``` r 
library(devtools)
devtools::install_github("lifecycle-project/ds-upload")
```

## Armadillo 2
`dsUpload` Version 4.7.x is compatible with Armadillo 2. When installing this version of dsUpload, the `install.packages` command might install the newest version (incompatible) of `MolgenisArmadillo`.
Run these commands (Rstudio) to install the correct version of MolgenisArmadillo:

Install devtools:

``` r
install.packages("devtools")
```

Load devtools and install ds-upload 4.7.1

``` r
library(devtools)
devtools::install_github("lifecycle-project/ds-upload@4.7.1")
```
You might get the following error message:

`namespace ‘MolgenisArmadillo’ 2.0.0 is being loaded, but == 1.1.3 is required`

To fix this you need to remove the incompatible version of `MolgenisArmadillo`:

``` r
unloadNamespace("MolgenisArmadillo")
remove.packages("MolgenisArmadillo")
```

You might have to install these additional packages:

``` r
install.packages(c("aws.iam", "aws.s3"))
```

Next we install a previous version of `MolgenisArmadillo` 1.1.3:

``` r
packageurl <- "https://cran.r-project.org/src/contrib/Archive/MolgenisArmadillo/MolgenisArmadillo_1.1.3.tar.gz"
install.packages(packageurl, repos=NULL, type="source")
```

Now we (again) install dsUpload 4.7.1:

``` r
devtools::install_github("lifecycle-project/ds-upload@4.7.1")
```

Make sure you do **NOT** update MolgenisArmadillo to another version then 1.1.3, if prompted, select option **3**

```
Downloading GitHub repo lifecycle-project/ds-upload@4.7.1
These packages have more recent versions available.
It is recommended to update all of them.
Which would you like to update?

1: All                                 
2: CRAN packages only                  
3: None                                
4: MolgenisA... (1.1.3 -> 2.0.0) [CRAN]

Enter one or more numbers, or an empty line to skip updates: 3
```

After that you should be able to load `dsUpload` without any problems.

``` r
library(dsUpload)
```

If you are asked to update `MolgenisArmadillo` to version 2.0.x please skip,
this in order for dsUpload 4.7.x to work with Armadillo 2.