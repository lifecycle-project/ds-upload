# LifeCycle Analysis Protocols
These provide researchers with a list of standard functions for data manipulations and analyses in DataSHIELD; these can be adapted to each specific research question. The protocols are currently fairly simple, but will become more extensive as our experience of DataSHIELD develops.

## Protocols
There are two groups of protocols: *project setup* and *methods*.

### Project setup
These set of files are containing functions that provide a layer over DataSHIELD that allows researcheers to do their project setup very fast.

- [login to the opal instances](R/protocols/login.R)
- [logout of the opal instances](R/protocols/logout.R)
- [summarizing data](R/protocols/summaries.R)

### Methods
Coding for standard data analysis in DataSHIELD.

- [preprocessing data](R/protocols/data.R)
- [comparing two means](R/protocols/means.R)
- [contour plots](R/protocols/plots.R)

## Usage
You can make use of the functions by including the package through the following code snippet|

```R
library(lifecycle)
```

At this moment the implemented functions at this moment are:

- ```lc.login``` login from LifeCycle cohorts through DataSHIELD
- ```lc.logout``` logout in LifeCycle cohorts through DataSHIELD