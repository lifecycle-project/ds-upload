# Versions of data dictionaries
We define here in what versions of the data dictionaries contains which tables.

## 1.1
**lifecycleProject R-package version >= 0.3.0**

Additional variables from WP3 and changes in the lifecycle variables.

### Content

**LifeCycle variables**
* art --> variable_id changed from **art** to **mar**
>**be adviced**: all harmonisations of all cohorts need te upload this variable again with the new name

* preg_plan --> values updated from ( 0 = No (not planned) / 1 = Yes (Planned, partly planned)) to ( 1 = Yes (Planned, partly planned) / 2 = No (not planned))

* cob_p --> changed values
  * 0) Born in country of cohort
  * 1) Born in EU country (outside cohort country)
  * 2) Born in other country

**EUSILC variables (task 3.1.1)**

| Variable               | Description                                                                  | Datatype    |
| ---------------------- | ---------------------------------------------------------------------------- | ----------- |
| eusilc_income          | Log-equivalised total disposable household income predicted                  | continuous  |
| eusilc_income_quintiles| Quintiles of the log-equivalised total disposable household income predicted | categorical |

**Migration variables (task 3.1.2)** 

| Variable     | Description                      | Datatype    |
| ------------ | -------------------------------- | ----------- |
| abroad_child | Child's born abroad	            | binary      |
| abroad_mo	   | Mother's born abroad	            | binary      |
| abroad_fa	   | Father's born abroad	            | binary      |
| miggen_child | Child's migrant status	          | categorical |
| region_mo	   | Mother’s world region of birth   | categorical |
| region_fa	   | Father’s world region of birth	  | categorical |
| reledu_mo	   | Mother’s educational selectivity | decimal     |
| reledu_fa    | Father’s educational selectivity | decimal     |



### Tables
- 1_1_non_repeated_measures

## 1.0
**lifecycleProject R-package version >= 0.1.0**

### Content
- Includes all lifecycle variables harmonised by all cohorts

### Tables
- 1_0_non_repeated_measures
- 1_0_monthly_repeated_measures
- 1_0_yearly_repeated_measures