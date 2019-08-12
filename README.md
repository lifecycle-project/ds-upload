# LifeCycle Analysis Protocols
These provide researchers with a list of standard functions for data manipulations and analyses in DataSHIELD; these can be adapted to each specific research question. The protocols are currently fairly simple, but will become more extensive as our experience of DataSHIELD develops.

## Protocols
We are trying to build a meta package for the LifeCycle project to ease the administration within scripts to setup the connections and assigning the data.

### Usage
You can make use of the functions by including the package through the following code snippet|

```R
library(lifecycle)
```

At this moment the implemented functions at this moment are:

- ```lc.login``` login from LifeCycle cohorts through DataSHIELD
- ```lc.logout``` logout in LifeCycle cohorts through DataSHIELD

## Sample analysis
The output of our R-group sessions are available here. Under ```R/sample_analysis/#cohort#``` you can find the scripts and under ```R/sample_analysis/#cohort#/data``` you can find the corresponding data. sets. Sometimes there is a dictionaries folder as well under data, which contains the dictionary.