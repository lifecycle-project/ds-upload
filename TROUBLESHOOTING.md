# TROUBLESHOOTING
All kinds of stuff can go wrong. This a collection of scenario's where you might run into. 

## Install R
You need to have R installed on your system. This differs per operating system. 
> **IMPORTANT:** install R where you have write access also for other files. Within a contained environment this is for example your network drive.

### For Windows

Get R from: https://cran.r-project.org/bin/windows/base/. More specifically: https://cran.r-project.org/bin/windows/base/R-3.6.1-win.exe.

You can install the package with the default settings. 

### For Mac

Get R from: https://cran.r-project.org/bin/macosx/. More specifically: https://cran.r-project.org/bin/macosx/R-3.6.1.pkg.

You can install the package with the default settings. 

**RStudio**

RStudio is nice to have but not a necessity. You can download it here: https://www.rstudio.com/products/rstudio/download/#download.

## Update your R version in RStudio
Sometimes you run an old version of R. You need to upgrade whenever that happens to the latest version. This will be different for Windows and Mac.

### For Windows

Goto *Start* --> *Type 'R' within the Run field*. 
Click on *R x.x.x* to get to the commandline interface

```R
install.packages("installr") 
library(installr)

updateR()
```

You will get a wizard, please choose all the defaults and proceed with the installation.

### For Mac

You can use ```updateR```. Install it via the following commands:

```
install.packages('devtools') #assuming it is not already installed
library(devtools)
install_github('andreacirilloac/updateR')
library(updateR)
updateR(admin_password = 'Admin user password')
```

>**reference**: for more information check: http://www.andreacirillo.com/2018/03/10/updater-package-update-r-version-with-a-function-on-mac-osx/

# Package won't install

## Prerequisites
You need these packages to can make use of the dsUpload R-package.

* opalr (>= 1.2.0),
* dplyr,
* tidyr,
* httr,
* jsonlite,
* stringr,
* data.table,
* readr,
* readxl,
* haven,
* plotly,
* gmodels,
* ggplot2

> For Opal reference documentation check: http://opaldoc.obiba.org/en/latest/r-user-guide/datashield.html

### For Windows
Install the Opal package by installing ```RCurl, rjson``` first.
```{r, eval = FALSE}
install.packages(c('httr', 'rjson'), repos=c('https://cloud.r-project.org/', 'https://www.stats.ox.ac.uk/pub/RWin/'))
```

Then execute: 
```{r, eval = FALSE}
install.packages('opalr', repos=c('https://cloud.r-project.org', 'https://www.stats.ox.ac.uk/pub/RWin/'))
```

Install remaining packages by executing:
```{r, eval = FALSE}
install.packages(c('metafor', 'tidyr', 'dplyr', 'readr', 'stringr', 'readxl', 'data.table', 'haven', 'gmodels', 'ggplot2', 'plotly', 'openxslx', 'jsonlite'), repos=c('https://cloud.r-project.org/', 'https://www.stats.ox.ac.uk/pub/RWin/'))
```

This may take a while

### For Mac
Install Opal by executing:
```{r, eval = FALSE}
install.packages('opalr', repos=c('https://cloud.r-project.org/', 'https://cran.obiba.org'), dependencies=TRUE)
```

Install remaing packages by executing:
```{r, eval = FALSE}
install.packages(c('metafor', 'tidyr', 'dplyr', 'readr', 'stringr', 'readxl', 'data.table', 'haven', 'gmodels', 'ggplot2', 'plotly', 'httr', 'openxslx', 'jsonlite'), repos=c('https://cloud.r-project.org/'))
```

## Error's when running the program
Error's can occur during the method calls in the lifecycleProject package.

#### attributes are not identical across measure variables; they will be dropped
When this message occurs it means the the types of the vectors concerning the yearly or monthly repeated measures are different. The reshape function will resolve this, but it is wise to check your dataset for these differences.

For instance:

```
weight_01 == integer
...
wieght_04 == decimal
```

#### Packages won't register within the R-environment

##### For Windows
Sometimes the installed packages can not be registered in the R-environment because of the missing package ``pkgconfig``

```{r, eval = FALSE}
install.packages("pkgconfig")
```

## Error's importing the tables

#### Tablenames too large
When Opal returns something like this and you have a SQL like backend (MariaDB or MySQL)

```
Identifier name 'idx_lifecycle_1_0_20191119_172835_1_0_monthly_repeated_measures_created' is too long
```

You need to run this on the mysql-client:

```
SET @@global.innodb_large_prefix = 1;
```

This options is persisted in the database and allows you to create larger indexes on the SQL server.
