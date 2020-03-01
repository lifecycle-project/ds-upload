# Versions of data dictionaries (core = wp1 and wp3)
We define here in what versions of the data dictionaries contains which tables.

## 2.0
**lifecycleProject R-package version >= 2.1.0**

Additional variables from WP3 and changes in the lifecycle variables.

### Content

**General changes**
* Create a seperate table for the trimester variables
* Moved smk_t* and alc_t* to the trimester variables

**Eating diorder variables**

Contributed by: Maja Popovic (maja.popovic@unito.it)

*Non-repeated variables*

| Variable    | Type    | Description                                                    |
| ----------- | ------- | -------------------------------------------------------------- |
| prepreg_dep	| integer	| Maternal history of depressive disorders                       |
| prepreg_anx |	integer	| Maternal history of anxiety disorders                          |
| prepreg_ed  |	integer	| Maternal history of any eating disorder                        |
| preg_ed	    | integer	| Maternal any eating disorder active during the index pregnancy |
| prepreg_an  |	integer	| Maternal history of anorexia nervosa                           |
| preg_an	    | integer	| Maternal anorexia nervosa active during the index pregnancy    |
| prepreg_bn  |	integer	| Maternal history of bulimia nervosa                            |
| preg_bn     |	integer |	Maternal bulimia nervosa active during the index pregnancy     |

*Yearly-repeated measures*

| Variable    | Type    | Description                                                    |
| ----------- | ------- | -------------------------------------------------------------- |
| ed_m_	      | integer	| Maternal any eating disorder active after the index pregnancy  |
| an_m_       |	integer	| Maternal anorexia nervosa active after the index pregnancy     |
| bn_m_	      | integer |	Maternal bulimia nervosa active after the index pregnancy      |

**Workpackage 3**
- EUSILC variables (task 3.1.1)
- Migration variables (task 3.1.2)
- (task 3.1.3)
- (task 3.1.4)

**Workpackage 1**
* Changing the child_id's columntype to character to overcome the maximum integer problem

### Tables
- 1_1_core_cohort-id_x_x_non_repeated_measures
- 1_1_core_cohort-id_x_x_trimester_measures
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
