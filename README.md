# LifeCycle Analysis Protocols
These provide researchers with a list of standard functions for data manipulations and analyses in DataSHIELD; these can be adapted to each specific research question. The protocols are currently fairly simple, but will become more extensive as our experience of DataSHIELD develops.

## Protocols
We are trying to build a meta package for the LifeCycle project to aid data mangers and researchers in the initial stages of uploading data to Opal and assigning data in R/DataSHIELD.

### Usage
The current functions available to data managers and researchers are:

- ```lc.login``` login to your Opal instance
- ```lc.populate.core``` populates the data dictionaries for LifeCycle
- ```lc.populate.outcome``` populates the data dictionaries for LifeCycle
- ```lc.reshape.core``` separates non-repeated and repeated measure varables; reshapes repeated measures to long format (WP1)
- ```lc.reshape.outcome``` separates non-repeated and repeated measure varables; reshapes repeated measures to long format (WP4,5 and 6)

For further detail check: https://github.com/lifecycle-project/analysis-protocols/wiki/LifeCycle-variables

### Installation
> For Opal reference documentation check: http://opaldoc.obiba.org/en/latest/r-user-guide/datashield.html

You can install the package by executing the following command:

```R
install.packages("lifecycleProject", repos='https://registry.molgenis.org/repository/R/', dependencies = TRUE)
```

## Analysis guidelines
Please check: [analysis guidelines](ANALYSIS_GUIDELINES.md)

## Adding new variables
When you need to add new variables you need to perform 2 steps:
- Adding the new variables to the dictionaries
- Reshaping your data to Opal format

### Adding new dictionaries (data schemes)
When you add new dictionaries you need to place them in ```R/data/dictionaries/x_x```.

For WP1 and 3 these 3 tables are namespaces this way:
- 1_0_non_repeated.xslx
- 1_0_yearly_repeated.xslx
- 1_0_monthly_repeated.xslx

For WP4, 5 and 6 these tables are created:
- 1_0_outcome_non_repeated.xslx
- 1_0_outcome_yearly_repeated.xslx
- 1_0_outcome_monthly_repeated.xslx
- 1_0_outcome_weekly_repeated.xslx

You need to place them into ```R/data/dictionaries/x_x``` as well. 

Then you need to amend ```R/utils.R``` and add your version.

```
lifecycle.globals$dictionaries_core <- c('1_0', 'x_x')

# or for outcome

lifecycle.globals$dictionaries_outcome <- c('1_0', 'x_x')
```

Finally you need to amend the changelogs.

- WP1 and 3: CORE_DICTIONARY_CHANGELOG.md
- WP4, 5 and 6: OUTCOME_DICTIONARY_CHANGELOG.md

### Reshaping your data to Opal format
When you are done with the dictionaries you need to amend the variables in the ```variablesCore.R``` for the WP1 and 3 variables and ```variablesOutcome.R``` for the WP4,5 qnd 6 variables.

Both files are devided in three functions:

- yearly repeated
- monthly repeated
- non repeated

You can amend the variables where they need to be placed regarding the harmonisation manual.

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

Also create a git-tag and push this to the remote, based upon the lifecycleProject DESCRIPTION-file.

```
git tag x.x.x
git push origin x.x.x
```

This is used to download the data dictionaries, so do not forget to do this!
