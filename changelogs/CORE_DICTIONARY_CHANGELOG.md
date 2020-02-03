# Versions of data dictionaries (core = wp1 and wp3)
We define here in what versions of the data dictionaries contains which tables.

## 2.0
**lifecycleProject R-package version >= 1.1.0**

Additional variables from WP3 and changes in the lifecycle variables.

### Content

**General changes**
* Create a seperate table for the trimester variables.

**Workpackage 3**
- EUSILC variables (task 3.1.1)
- Migration variables (task 3.1.2)
- (task 3.1.3)
- (task 3.1.4)

**Workpackage 1**
* Changing the child_id's columntype to character to overcome the maximum integer problem

### Tables
- 1_1_core_cohort-id_x_x_non_repeated_measures
- 1_1_core_cohort-id_x_x_quaterly_measures
- 1_1_core_cohort-id_x_x_yearly_measures

## 1.0
**lifecycleProject R-package version >= 1.0.4**

### Content

**Workpackage 1**
Includes all lifecycle variables harmonised by all cohorts

* art --> variable_id changed from **art** to **mar**
>**be adviced**: all harmonisations of all cohorts need te upload this variable again with the new name

* preg_plan --> values updated from ( 0 = No (not planned) / 1 = Yes (Planned, partly planned)) to ( 1 = Yes (Planned, partly planned) / 2 = No (not planned))

* cob_p --> changed values
  * 0) Born in country of cohort
  * 1) Born in EU country (outside cohort country)
  * 2) Born in other country

### Tables
- 1_0_cohort-id_x_x_non_repeated_measures
- 1_0_cohort-id_x_x_monthly_repeated_measures
- 1_0_cohort-id_x_x_yearly_repeated_measures
