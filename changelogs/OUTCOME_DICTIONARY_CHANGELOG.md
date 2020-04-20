# Versions of data dictionaries (outcome = wp4, wp5 and wp6)
We define here in what versions of the data dictionaries contains which tables.

## 1.1

### Content

#### General changes
- *yearly-repeated variables*
  - Change unit of FeNO_ to "parts per billion"
- *monthly-repeated variables*
  - hba1c units changed to %. 
  - information on category labels for heightmes_ and weightmes_added in the categories tab
- *weekly-repeated variables*
  - hba1c units changed to %
- *non-repeated variables*
  - hba1c units changed to %

#### Additional variables

*yearly-repeated variables*

**Added FEF75_z_**

| Variable  | Type    | Description                           |
| --------- | ------- | ------------------------------------- |
| FEF75_z_	| decimal	| FEF75 (z-score according to GLI)      |

**Non-priority variables for WP5**

| Variable                | Type    | Description                           |
|-------------------------------|---------|---------|------------------------------------------------------------------------------------------------------------------|
| food_all_sens_SPT_COWMILK_    | integer | numeric | food allergic sensitization to cow milk, measured by skin prick test                                             |
| food_all_sens_SPT_EGG_        | integer | numeric | food allergic sensitization to chicken egg, measured by skin prick test                                          |
| food_all_sens_SPT_WHEAT_      | integer | numeric | food allergic sensitization to wheat, measured by skin prick test                                                |
| food_all_sens_SPT_PNT_        | integer | numeric | food allergic sensitization to peanut, measured by skin prick test                                               |
| food_all_sens_SPT_NUT_mix_    | integer | numeric | food allergic sensitization to nut mix, measured by skin prick test                                              |
| food_all_sens_SPT_NUT_wal_    | integer | numeric | food allergic sensitization to walnut, measured by skin prick test                                               |
| food_all_sens_SPT_NUT_cas_    | integer | numeric | food allergic sensitization to cashew nut, measured by skin prick test                                           |
| food_all_sens_SPT_NUT_haz_    | integer | numeric | food allergic sensitization to hazelnut, measured by skin prick test                                             |
| food_all_sens_SPT_SES_        | integer | numeric | food allergic sensitization to sesame, measured by skin prick test                                               |
| food_all_sens_SPT_FISH_mix_   | integer | numeric | food allergic sensitization to fish mix, measured by skin prick test                                             |
| food_all_sens_SPT_FISH_cod_   | integer | numeric | food allergic sensitization to cod fish, measured by skin prick test                                             |
| food_all_sens_SPT_SHELL_mix_  | integer | numeric | food allergic sensitization to shell fish mix, measured by skin prick test                                       |
| food_all_sens_SPT_FRUIT_kiw_  | integer | numeric | food allergic sensitization to kiwi fruit, measured by skin prick test                                           |
| food_all_sens_SPT_FRUIT_pea_  | integer | numeric | food allergic sensitization to peach fruit, measured by skin prick test                                          |
| inh_all_sens_SPT_GRASS_mix _  | integer | numeric | inhalant allergic sensitization to grass mix, measured by skin prick test                                        |
| inh_all_sens_SPT_GRASS_tim _  | integer | numeric | inhalant allergic sensitization to timothy grass, measured by skin prick test                                    |
| inh_all_sens_SPT_CAT _        | integer | numeric | inhalant allergic sensitization to cat, measured by skin prick test                                              |
| inh_all_sens_SPT_DOG _        | integer | numeric | inhalant allergic sensitization to dog, measured by skin prick test                                              |
| inh_all_sens_SPT_HDM_mix _    | integer | numeric | inhalant allergic sensitization to house dust mite mix, measured by skin prick test                              |
| inh_all_sens_SPT_HDM_derf _   | integer | numeric | inhalant allergic sensitization to house dust mite (dermatophagoides farinae), measured by skin prick test       |
| inh_all_sens_SPT_HDM_derp _   | integer | numeric | inhalant allergic sensitization to house dust mite (dermatophagoides pteronyssinus), measured by skin prick test |
| inh_all_sens_SPT_TREE_mix _   | integer | numeric | inhalant allergic sensitization to tree polen mix, measured by skin prick test                                   |
| inh_all_sens_SPT_TREE_birch _ | integer | numeric | inhalant allergic sensitization to birch, measured by skin prick test       |


## 1.0
**lifecycleProject R-package version >= 2.1.0**

New variables for work packages 4, 5 and 6.

### Content

#### General changes

#### Additional variables

**Early-life stressors and cardio-metabolic health life course trajectories (WP4)**


**Early-life stressors and respiratory health life course trajectories (WP5)**


**Early-life stressors and mental health life course trajectories (WP6)**

### Tables
- 1_0_outcome_x_x_non_repeated
- 1_0_outcome_x_x_weekly_repeated
- 1_0_outcome_x_x_monthly_repeated
- 1_0_outcome_x_x_yearly_repeated
