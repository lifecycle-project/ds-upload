# LifeCycle Analysis Protocols
These provide researchers with a list of standard functions for data manipulations and analyses in DataSHIELD; these can be adapted to each specific research question. The protocols are currently fairly simple, but will become more extensive as our experience of DataSHIELD develops.

## Protocols
We are trying to build a meta package for the LifeCycle project to aid data mangers and researchers in the initial stages of uploading data to Opal and assigning data in R/DataSHIELD.

### Usage
The current functions available to data managers and researchers are:

- ```lc.populate.core``` populates the data dictionaries for LifeCycle
- ```lc.reshape.core``` separates non-repeated and repeated measure varables; reshapes repeated measures to long format (WP1)
- ```lc.quality.local.core.meta``` performs local quality checks on harmonised data

### Installation
**Prerequisites**
The following R packages are required to run the LifeCycle R-package:

* opalr (>= 1.2.0),
* dplyr,
* tidyr,
* httr,
* jsonlite,
* stringr,
* data.table,
* readr,
* sas7bdat,
* foreign,
* openxlsx,
* plotly,
* gmodels,
* ggplot2

> For Opal reference documentation check: http://opaldoc.obiba.org/en/latest/r-user-guide/datashield.html

**For Windows**

Install the Opal package. By installing ```RCurl, rjson``` first.
```R 
install.packages(c('httr', 'rjson'), repos=c('https://cloud.r-project.org/', 'https://www.stats.ox.ac.uk/pub/RWin/'))
```

Then execute: 
```R 
install.packages('opalr', repos=c('https://cloud.r-project.org', 'https://www.stats.ox.ac.uk/pub/RWin/'))
```

Install remaining packages by executing:
```R 
install.packages(c('metafor', 'tidyr', 'dplyr', 'readr', 'stringr', 'sas7bdat', 'data.table', 'foreign', 'tidyverse', 'gmodels', 'ggplot2', 'plotly', 'openxslx', 'jsonlite'), repos=c('https://cloud.r-project.org/', 'https://www.stats.ox.ac.uk/pub/RWin/'))
```

This may take a while

**For Mac**

Install Opal by executing:
```R 
install.packages('opalr', repos=c('https://cloud.r-project.org/', 'https://cran.obiba.org'), dependencies=TRUE)
```

Install remaing packages by executing:
```R 
install.packages(c('metafor', 'tidyr', 'dplyr', 'readr', 'stringr', 'sas7bdat', 'data.table', 'foreign', 'tidyverse', 'gmodels', 'ggplot2', 'plotly', 'httr', 'openxslx', 'jsonlite'), repos=c('https://cloud.r-project.org/'))
```

**Install LifeCycle package**

You can install the package by executing the following command:

```R
install.packages("lifecycleProject", repos='https://registry.molgenis.org/repository/R/', dependencies = TRUE)
library(lifecycleProject)
```

### Releases
Releasing the artifact can be done by curling to the following address:

```bash
curl -v --user 'user:password' --upload-file lifecycleProject_0.6.0.tar.gz https://registry.molgenis.org/repository/r-hosted/src/contrib/lifecycleProject_0.6.0.tar.gz 
```

## Analysis guidelines
Please check: [analysis guidelines](ANALYSIS_GUIDELINES.md)
