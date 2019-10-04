# LifeCycle Analysis Protocols
These provide researchers with a list of standard functions for data manipulations and analyses in DataSHIELD; these can be adapted to each specific research question. The protocols are currently fairly simple, but will become more extensive as our experience of DataSHIELD develops.

## Protocols
We are trying to build a meta package for the LifeCycle project to ease the administration within scripts to setup the connections and assigning the data.

### Usage
At this moment the implemented functions at this moment are:

- ```lc.login``` login to your Opal instance
- ```lc.populate.core``` populate the data dictionaries for LifeCycle
- ```lc.reshape.core``` performing the reshape of the data dictionaries for LifeCycle (only core variables)

For further detail check: https://github.com/lifecycle-project/analysis-protocols/wiki/LifeCycle-variables

### Installation

You can install the package by executing the following command:

```R
install.packages("lifecycleProject", repos='https://registry.molgenis.org/repository/R/', dependencies = TRUE)
```

## Analysis guidelines
Please check: [analysis guidelines](ANALYSIS_GUIDELINES.md)

## Adding new dictionaries (data schemes)
When you add new dictionaries you need to place them in ```R/data/dictionaries/x_x```.

For WP1 these 3 tables are namespaces this way:
- 1_0_non_repeated.xslx
- 1_0_yearly_repeated.xslx
- 1_0_monthly_repeated.xslx

For WP3 variables are placed within the same tables.

For WP4, 5 and 6 these tables are created:
- 1_0_outcome_non_repeated.xslx
- 1_0_outcome_yearly_repeated.xslx
- 1_0_outcome_monthly_repeated.xslx

You need to place them into ```R/data/dictionaries/x_x``` as well. 

Finally you need to amend ```R/utils.R``` and add your version.

```
lifecycle.globals$dictionaries <- c('1_0', 'x_x')
```

## Releases
Releasing the artifact can be done by curling to the following address:

**For source packages**

```bash
curl -v --user 'user:password' --upload-file lifecycleProject_1.0.0.tar.gz https://registry.molgenis.org/repository/r-hosted/src/contrib/lifecycleProject_1.0.0.tar.gz 
```

> So just to be short: https://registry.molgenis.org/repository/r-hosted/src/contrib/*package_version*.tar.gz 

**For binary packages**

First upload the source package to https://win-builder.r-project.org/
Then download the zip-file build bij win-builder. Then upload it into the registry by executing this command:

```bash
curl -v --user 'user:password' --upload-file lifecycleProject_1.0.0.zip https://registry.molgenis.org/repository/r-hosted/bin/windows/contrib/3.6/lifecycleProject_1.0.0.zip
```

>So just to be short: https://registry.molgenis.org/repository/r-hosted/bin/windows/contrib/*r-version*/*package_version*.zip