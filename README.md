# LifeCycle Analysis Protocols
These provide researchers with a list of standard functions for data manipulations and analyses in DataSHIELD; these can be adapted to each specific research question. The protocols are currently fairly simple, but will become more extensive as our experience of DataSHIELD develops.

## Protocols
We are trying to build a meta package for the LifeCycle project to ease the administration within scripts to setup the connections and assigning the data.

### Usage

> note: prerequisites are R-packages Opal, MetaFor and Dplyr.
  You can install Opal by executing: ```install.packages('opal', repos=c('https://cloud.r-project.org/', 'https://cran.obiba.org'), dependencies=TRUE)```
  You can install these by ```install.packages(c('metafor','dplyr'))```
  
> note: if you are installing Opal on Windows please execute: ```install.packages(c('RCurl', 'rjson'), repos=c('https://cloud.r-project.org/', 'https://www.stats.ox.ac.uk/pub/RWin/'))```
  and then execute: ```install.packages('opal', repos='https://cran.obiba.org', type='source')```.
  Check for more information: http://opaldoc.obiba.org/en/latest/r-user-guide/datashield.html

You can install the package

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

## Sample analysis
The output of our R-group sessions are available here. Under ```R/sample_analysis/#cohort#``` you can find the scripts and under ```R/sample_analysis/#cohort#/data``` you can find the corresponding data. sets. Sometimes there is a dictionaries folder as well under data, which contains the dictionary.