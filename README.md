# LifeCycle Analysis Protocols
These provide researchers with a list of standard functions for data manipulations and analyses in DataSHIELD; these can be adapted to each specific research question. The protocols are currently fairly simple, but will become more extensive as our experience of DataSHIELD develops.

## Protocols
We are trying to build a meta package for the LifeCycle project to ease the administration within scripts to setup the connections and assigning the data.

### Usage

**Prerequisites**
You need these packages to can make use of the LifeCycle R-package.

* opal,
* metafor
* tidyr
* dplyr
* readr
* data.table
* foreign
* maditr

> For Opal reference documentation check: http://opaldoc.obiba.org/en/latest/r-user-guide/datashield.html

**For Windows**

Install the Opal package. By installing ```RCurl, rjson``` first.
```R 
install.packages(c('RCurl', 'rjson'), repos=c('https://cloud.r-project.org/', 'https://www.stats.ox.ac.uk/pub/RWin/'))
```

Then execute: 
```R 
install.packages('opal', repos='https://cran.obiba.org', type='source')
```

Install remaining packages by executing:
```R 
install.packages(c('metafor', 'tidyr', 'dplyr', 'readr', 'data.table', 'foreign', 'maditr'), repos=c('https://cloud.r-project.org/', 'https://www.stats.ox.ac.uk/pub/RWin/'))
```

**For Mac**

Install Opal by executing:
```R 
install.packages('opal', repos=c('https://cloud.r-project.org/', 'https://cran.obiba.org'), dependencies=TRUE)
```

Install remaing packages by executing:
```R 
install.packages(c('metafor', 'tidyr', 'dplyr', 'readr', 'data.table', 'foreign', 'maditr', 'tidyverse', 'gmodels', 'plotly'), repos=c('https://cloud.r-project.org/'))
```

**LifeCycle R-package installation**

You can install the package by executing the following command:

```R
install.packages("lifecycleProject", repos='https://registry.molgenis.org/repository/R/', dependencies = TRUE)
library(lifecycleProject)
```

At this moment the implemented functions at this moment are:

- ```lc.reshape``` performing the reshape of the data dictionaries for LifeCycle
- ```lc.populate``` populate the datadictionaries for LifeCycle

### Releases
Releasing the artifact can be done by curling to the following address:

```bash
curl -v --user 'user:password' --upload-file lifecycleProject_0.2.0.tar.gz https://registry.molgenis.org/repository/r-hosted/src/contrib/lifecycleProject_0.2.0.tar.gz 
```

## Analysis guidelines
Please check: [analysis guidelines](ANALYSIS_GUIDELINES.md)