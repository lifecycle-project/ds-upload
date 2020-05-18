# Versions of data dictionaries (outcome = wp4, wp5 and wp6)
We define here in what versions of the data dictionaries contains which tables.

## 1.x
**lifecycleProject R-package version >= 2.x.x** *--> not released yet*

### Content

#### General changes

#### Additional variables

*non-repeated variables*

*yearly-repeated variables*

*monthly-repeated variables*

*trimester-repeated variables*

### Tables
- 1_x_outcome_x_x_non_repeated
- 1_x_outcome_x_x_weekly_repeated
- 1_x_outcome_x_x_monthly_repeated
- 1_x_outcome_x_x_yearly_repeated

## 1.1
**lifecycleProject R-package version >= 2.3.0**

### Content
Additional variables for yearly repeats and some renames.

#### General changes
- *yearly-repeated variables*
  - Change unit of FeNO_ to "parts per billion"
- *monthly-repeated variables*
  - hba1c units changed to %. 
  - hdlc_c changed to hdlc_
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

| Variable                      | Type    | Description                                                                                                      |
| ----------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------- |
| food_all_sens_SPT_COWMILK_    | integer | food allergic sensitization to cow milk, measured by skin prick test                                             |
| food_all_sens_SPT_EGG_        | integer | food allergic sensitization to chicken egg, measured by skin prick test                                          |
| food_all_sens_SPT_WHEAT_      | integer | food allergic sensitization to wheat, measured by skin prick test                                                |
| food_all_sens_SPT_PNT_        | integer | food allergic sensitization to peanut, measured by skin prick test                                               |
| food_all_sens_SPT_NUT_mix_    | integer | food allergic sensitization to nut mix, measured by skin prick test                                              |
| food_all_sens_SPT_NUT_wal_    | integer | food allergic sensitization to walnut, measured by skin prick test                                               |
| food_all_sens_SPT_NUT_cas_    | integer | food allergic sensitization to cashew nut, measured by skin prick test                                           |
| food_all_sens_SPT_NUT_haz_    | integer | food allergic sensitization to hazelnut, measured by skin prick test                                             |
| food_all_sens_SPT_SES_        | integer | food allergic sensitization to sesame, measured by skin prick test                                               |
| food_all_sens_SPT_FISH_mix_   | integer | food allergic sensitization to fish mix, measured by skin prick test                                             |
| food_all_sens_SPT_FISH_cod_   | integer | food allergic sensitization to cod fish, measured by skin prick test                                             |
| food_all_sens_SPT_SHELL_mix_  | integer | food allergic sensitization to shell fish mix, measured by skin prick test                                       |
| food_all_sens_SPT_FRUIT_kiw_  | integer | food allergic sensitization to kiwi fruit, measured by skin prick test                                           |
| food_all_sens_SPT_FRUIT_pea_  | integer | food allergic sensitization to peach fruit, measured by skin prick test                                          |
| inh_all_sens_SPT_GRASS_mix _  | integer | inhalant allergic sensitization to grass mix, measured by skin prick test                                        |
| inh_all_sens_SPT_GRASS_tim _  | integer | inhalant allergic sensitization to timothy grass, measured by skin prick test                                    |
| inh_all_sens_SPT_CAT _        | integer | inhalant allergic sensitization to cat, measured by skin prick test                                              |
| inh_all_sens_SPT_DOG _        | integer | inhalant allergic sensitization to dog, measured by skin prick test                                              |
| inh_all_sens_SPT_HDM_mix _    | integer | inhalant allergic sensitization to house dust mite mix, measured by skin prick test                              |
| inh_all_sens_SPT_HDM_derf _   | integer | inhalant allergic sensitization to house dust mite (dermatophagoides farinae), measured by skin prick test       |
| inh_all_sens_SPT_HDM_derp _   | integer | inhalant allergic sensitization to house dust mite (dermatophagoides pteronyssinus), measured by skin prick test |
| inh_all_sens_SPT_TREE_mix _   | integer | inhalant allergic sensitization to tree polen mix, measured by skin prick test                                   |
| inh_all_sens_SPT_TREE_birch _ | integer | inhalant allergic sensitization to birch, measured by skin prick test                                            |

### Tables
- 1_1_outcome_x_x_non_repeated
- 1_1_outcome_x_x_weekly_repeated
- 1_1_outcome_x_x_monthly_repeated
- 1_1_outcome_x_x_yearly_repeated

## 1.0
**lifecycleProject R-package version >= 2.1.0**

New variables for work packages 4, 5 and 6.

### Content

#### General changes

#### Additional variables

**Early-life stressors and cardio-metabolic health life course trajectories (WP4)**

*monthly-repeated variables*

| Variable          | Type    | Description                                               |
|-------------------|---------|-----------------------------------------------------------|
| row_id            | integer | Unique identifier for the row in Opal                     |
| child_id          | text    | Unique identifier for the child                           |
| age_years         | integer | Age of the child in years                                 |
| age_months        | integer | Age of the child in months                                |
| heightmes_        | integer | measured vs. reported child's height                      |
| weightmes_        | integer | measured vs. reported child's weight                      |
| headcirc_         | decimal | head circumference                                        |
| headcircage_      | decimal | age at head circumference measurement                     |
| headcircmes_      | integer | measured vs. reported head circumference                  |
| waistcirc_        | decimal | waist circumference                                       |
| waistcircage_     | decimal | age at waist circumference measurement                    |
| waistcircmes_     | integer | measured vs. reported waist circumference                 |
| hipcirc_          | decimal | hip circumference                                         |
| hipcircage_       | decimal | age at hip circumference measurement                      |
| hipcircmes_       | integer | measured vs. reported hip circumference                   |
| armcirc_          | decimal | arm circumference                                         |
| armcircage_       | decimal | age at arm circumference measurement                      |
| armcircmes_       | integer | measured vs. reported arm circumference                   |
| dominant_armc_    | integer | arm circumference  measured in dominant or non-dominant   |
| dxafm_            | decimal | whole-body DXA fat mass                                   |
| dxafmage_         | decimal | age at DXA fat mass measurement                           |
| dxafmmes_         | integer | device used to measure DXA fat mass                       |
| dxalm_            | decimal | whole-body DXA lean mass                                  |
| dxalmage_         | decimal | age at DXA lean mass measurement                          |
| dxalmmes_         | integer | device used to measure DXA lean mass                      |
| bio_              | decimal | body fat from bioimpedance                                |
| bioage_           | decimal | age at bioimpedance measurement                           |
| biomes_           | integer | device used to measure bioimpedance                       |
| bicepsf_          | decimal | bicep skinfold                                            |
| bicepsfage_       | decimal | age at biceps skinfold measurement                        |
| bicepsfmes_       | integer | measured vs. reported bicep skinfold                      |
| subscapsf_        | decimal | subscapular skinfold                                      |
| subscapsfage_     | decimal | age at subscapular skinfold measurement                   |
| subscapsfmes_     | integer | measured vs. reported subscapular skinfold                |
| tricepsf_         | decimal | tricep skinfold                                           |
| tricepsfage_      | decimal | age at triceps skinfold measurement                       |
| tricepsfmes_      | integer | measured vs. reported tricep skinfold                     |
| suprasf_          | decimal | suprailiac skinfold                                       |
| suprasfage_       | decimal | age at suprailiac skinfold measurement                    |
| suprasfmes_       | integer | measured vs. reported suprailiac skinfold                 |
| armlength_        | decimal | arm length                                                |
| armlengthage_     | decimal | age at arm length measurement                             |
| armlengthmes_     | integer | measured vs. reported arm length                          |
| sittinght_        | decimal | sitting height                                            |
| sittinghtage_     | decimal | age at sitting height measurement                         |
| sittinghtmes_     | integer | measured vs. reported sitting height                      |
| glucose_          | decimal | glucose                                                   |
| glucoseage_       | decimal | age at glucose measurement                                |
| glucosemes_       | integer | fasting or nonfasting when glucose measured               |
| haem_             | decimal | haemoglobin                                               |
| haemage_          | decimal | age at haemoglobin measurement                            |
| haemmes_          | integer | fasting or nonfasting when haemoglobin measured           |
| hba1c_            | decimal | HbA1c                                                     |
| hba1cage_         | decimal | age at HbA1c measurement                                  |
| hba1cmes_         | integer | fasting or nonfasting when HbA1c measured                 |
| insulin_          | decimal | insulin                                                   |
| insulinage_       | decimal | age at insulin measurement                                |
| insulinmes_       | integer | fasting or nonfasting when insulin measured               |
| crp_              | decimal | CRP                                                       |
| crpage_           | decimal | age at CRP measurement                                    |
| crpmes_           | integer | fasting or nonfasting when CRP measured                   |
| il6_              | decimal | IL6                                                       |
| il6age_           | decimal | age at Il6 measurement                                    |
| il6mes_           | integer | fasting or nonfasting when IL6 measured                   |
| adipo_            | decimal | adiponectin                                               |
| adipoage_         | decimal | age at adiponectin measurement                            |
| adipomes_         | integer | fasting or nonfasting when adiponectin measured           |
| leptin_           | decimal | leptin                                                    |
| leptinage_        | decimal | age at leptin measurement                                 |
| leptinmes_        | integer | fasting or nonfasting when leptin measured                |
| chol_             | decimal | total cholesterol                                         |
| cholage_          | decimal | age at total cholesterol measurement                      |
| cholmes_          | integer | fasting or nonfasting when total cholesterol measured     |
| hdlc_c            | decimal | hdl cholesterol                                           |
| hdlcage_          | decimal | age at hdl cholesterol measurement                        |
| hdlcmes_          | integer | fasting or nonfasting when HDLc measured                  |
| ldlc_             | decimal | ldl cholesterol                                           |
| ldlcage_          | decimal | age at ldl cholesterol measurement                        |
| ldlcmes_          | integer | fasting or nonfasting when LDLc measured                  |
| vldlc_            | decimal | vldl cholesterol                                          |
| vldlcage_         | decimal | age at vldl cholesterol measurement                       |
| vldlcmes_         | integer | fasting or nonfasting when vLDLc measured                 |
| triglycerides_    | decimal | triglycerides                                             |
| triglyceridesage_ | decimal | age at triglycerides measurement                          |
| triglyceridesmes_ | integer | fasting or nonfasting when triglycerides measured         |
| sbp_              | decimal | systolic blood pressure 1st measurement                   |
| dbp_              | decimal | diastolic blood pressure 1st measurement                  |
| sbpav_            | decimal | systolic blood pressure average                           |
| dbpav_            | decimal | diastolic blood pressure average                          |
| bpage_            | decimal | age at peripheral blood pressure measurement              |
| pulse_            | decimal | pulse rate                                                |
| pulseage_         | decimal | age at pulse rate measurement                             |
| pulsemessit_      | integer | sitting or standing when measuring pulse rate             |
| csbp_             | decimal | central (i.e. aortic) systolic blood pressure             |
| cdbp_             | decimal | central (i.e. aortic) diastolic blood pressure            |
| cbpage_           | decimal | age at central (i.e. aortic) blood pressure measurement   |
| cbpsit_           | integer | sitting or standing when measuring central blood pressure |
| crpwv_            | decimal | carotid-radial pulse wave velocity                        |
| crpwvage_         | decimal | age at carotid-radial pulse wave velocity measurement     |
| cfpwv_            | decimal | carotid-femoral pulse wave velocity                       |
| cfpwvage_         | decimal | age at carotid-femoral pulse wave velocity measurement    |
| cimt_             | decimal | carotid intima-media thickness                            |
| cimtage_          | decimal | age at carotid intima-media thickness measurement         |
| cimtmes_          | integer | device used to measure carotid intima-media thickness     |

*weekly-repeated variables*

| Variable         | Type    | Description                                                                        |
| ---------------- | ------- | ---------------------------------------------------------------------------------- |
| row_id           | integer | Unique identifer for the row in Opal                                               |
| child_id         | text    | Unique identifer for the child                                                     |
| age_years        | integer | Age of the child in years                                                          |
| age_weeks        | integer | Age of the child in weeks                                                          |
| m_sbp_           | decimal | Mother's systolic blood pressure during pregnancy in completed weeks of gestation  |
| m_dbp_           | decimal | Mother's diastolic blood pressure during pregnancy in completed weeks of gestation |
| m_crp_           | decimal | Mother's CRP during pregnancy in completed weeks of gestation                      |
| m_glucose_       | decimal | Mother's glucose during pregnancy in completed weeks of gestation                  |
| m_haem_          | decimal | Mother's haemoglobin during pregnancy in completed weeks of gestation              |
| m_hba1c_         | decimal | Mother's HbA1c during pregnancy in completed weeks of gestation                    |
| m_insulin_       | decimal | Mother's insulin during pregnancy in completed weeks of gestation                  |
| m_hdlc_          | decimal | Mother's HDLc during pregnancy in completed weeks of gestation                     |
| m_ldlc_          | decimal | Mother's LDLc during pregnancy in completed weeks of gestation                     |
| m_chol_          | decimal | Mother's total cholesterol during pregnancy in completed weeks of gestation        |
| m_triglycerides_ | decimal | mother's triglycerides during pregnancy in completed weeks of gestation            |
| f_sbp_           | decimal | Father's systolic blood pressure during pregnancy in completed weeks of gestation  |
| f_dbp_           | decimal | Father's diastolic blood pressure during pregnancy in completed weeks of gestation |

**Early-life stressors and respiratory health life course trajectories (WP5)**

*non-repeated variables*
| Variable              | Type    | Description                                                                      |
|-----------------------|---------|----------------------------------------------------------------------------------|
| row_id                | integer | Unique identifer for the row in Opal                                             |
| child_id              | text    | Unique identifer for the child                                                   |
| eczema_m              | integer | Maternal history of eczema before pregnancy (of index child)                     |
| allergy_inh_m         | integer | Maternal history of inhalant allergy before pregnancy (of index child)           |
| allergy_food_m        | integer | Maternal history of food allergy before pregnancy (of index child)               |
| allergy_any_m         | integer | Maternal history of any allergy before pregnancy (of index child)                |
| whe_ever              | integer | Wheezing between ages 0-4 years                                                  |
| whe_ever2             | integer | Wheezing between ages 0-2 years                                                  |
| whe_ever4             | integer | Wheezing between ages 2-4 years                                                  |
| whe_ever5_10          | integer | Wheezing between ages 5-10 years                                                 |
| asthma_ever_CHICOS    | integer | School age asthma according to CHICOS definition                                 |
| asthma_ever_MeDALL    | integer | Ever diagnosis of asthma according to MeDALL definition                          |
| asthma_current_MeDALL | integer | Current asthma (MeDALL)                                                          |
| asthma_current_ISAAC  | integer | Current asthma (ISAAC)                                                           |
| food_all_ever         | integer | Ever doctor diagnosis of food allergy                                            |
| inh_all_ever          | integer | Ever doctor diagnosis of inhalant allergy                                        |
| all_ever              | integer | Ever doctor diagnosis of allergy, type of allergen unspecified                   |
| urticaria             | integer | Ever diagnosis of urticaria                                                      |
| anaphylaxis           | integer | Ever diagnosis of anaphylactic shock                                             |
| eczema_ever           | integer | Ever doctor-diagnosis of eczema                                                  |
| asthma_adult          | integer | Ever diagnosis of asthma in adulthood based on physician diagnosis               |
| COPD_adult_GOLD       | integer | Ever diagnosis of COPD in adulthood based on GOLD criteria                       |
| COPD_adult_LLN        | integer | Ever diagnosis of COPD in adulthood based on lower limit of normal (LLN)         |
| COPD_adult_diagnosis  | integer | Ever diagnosis of COPD in adulthood based on physician diagnosis                 |
| pets_preg             | integer | Furry pet (dogs, cats, rodents) ownership in child's household during pregnancy. |

*yearly-repeated variables*

| Variable                | Type    | Description                                                                                                           |
|-------------------------|---------|-----------------------------------------------------------------------------------------------------------------------|
| row_id                  | integer | Unique identifer for the row in Opal                                                                                  |
| child_id                | text    | Unique identifer for the child                                                                                        |
| age_years               | integer | Age of child in years                                                                                                 |
| whe_                    | integer | wheezing                                                                                                              |
| asthma_                 | integer | asthma diagnosis                                                                                                      |
| asthma_current_MeDALL_  | integer | Current asthma (MeDALL)                                                                                               |
| asthma_current_ISAAC_   | integer | Current asthma  (ISAAC)                                                                                               |
| asthma_med_             | integer | asthma medication use                                                                                                 |
| asthma_med_spec_        | integer | asthma medication use, type specified                                                                                 |
| URTI_                   | integer | upper respiratory tract infection (ear infection, throat infection, laryngitis, croup, whooping cough or equivalent)  |
| LRTI_                   | integer | lower respiratory tract infection (bronchiolitis, bronchitis, pneumonia, chest infection, or equivalent)              |
| FEV1_abs_               | decimal | FEV (L)                                                                                                               |
| FVC_abs_                | decimal | FVC (L)                                                                                                               |
| FEF25_abs_              | decimal | FEF25 (L/s)                                                                                                           |
| FEF50_abs_              | decimal | FEF50 (L/s)                                                                                                           |
| FEF75_abs_              | decimal | FEF75 (L/s)                                                                                                           |
| FEV1_z_                 | decimal | FEV1 (z-score according to GLI)                                                                                       |
| FVC_z_                  | decimal | FVC (z-score according to GLI)                                                                                        |
| FEV1FVC_z_              | decimal | FEV1FVC (z-score according to GLI)                                                                                    |
| FEF75_z_                | decimal | FEF75 (z-score according to GLI)                                                                                      |
| repro_                  | integer | reproducibility of the spirometry                                                                                     |
| BHR_                    | integer | Bronchial hyperresponsiveness (measured by metacholine challenge test)                                                |
| FeNO_                   | decimal | Fractional exhaled nitric oxide (FeNO)                                                                                |
| food_all_               | integer | food allergy                                                                                                          |
| inh_all_                | integer | inhalant allergy                                                                                                      |
| all_                    | integer | allergy, type of allergen unspecified                                                                                 |
| food_all_sens_SPT_      | integer | food allergic sensitization, measured by skin prick test                                                              |
| inh_all_sens_SPT_       | integer | inhalant allergic sensitization, measured by skin prick test                                                          |
| inh_all_sens_IgE_HDM_   | decimal | inhalant allergic senzitization to house dust mite, measured by IgE                                                   |
| inh_all_sens_IgE_CAT_   | decimal | inhalant allergic senzitization to cat, measured by IgE                                                               |
| inh_all_sens_IgE_RYE_   | decimal | inhalant allergic senzitization to rye, measured by IgE                                                               |
| inh_all_sens_IgE_MOULD_ | decimal | inhalant allergic senzitization to mould, measured by IgE                                                             |
| eczema_                 | integer | eczema                                                                                                                |
| rash_                   | integer | itchy rash                                                                                                            |
| rash_loc_               | integer | location of itchy rash typical for eczema                                                                             |

**Early-life stressors and mental health life course trajectories (WP6)**

*non-repeated variables*

| Variable              | Type    | Description                                                                      |
|-----------------------|---------|----------------------------------------------------------------------------------|
| row_id                | integer | Unique identifer for the row in Opal                                             |
| child_id              | text    | Unique identifer for the child                                                   |
| glucose_cord          | decimal | glucose measured in cord blood                                                   |
| haem_cord             | decimal | hameoglobin measured in cord blood                                               |
| hba1c_cord            | decimal | hba1c measured in cord blood                                                     |
| insulin_cord          | decimal | insulin measured in cord blood                                                   |
| crp_cord              | decimal | crp measured in cord blood                                                       |
| il6_cord              | decimal | il6 measured in cord blood                                                       |
| adipo_cord            | decimal | adiponectin measured in cord blood                                               |
| leptin_cord           | decimal | leptin measured in cord blood                                                    |
| chol_cord             | decimal | total cholesterol measured in cord blood                                         |
| hdlc_cord             | decimal | hdl cholesterol measured in cord blood                                           |
| ldlc_cord             | decimal | ldl cholesterol measured in cord blood                                           |
| vldlc_cord            | decimal | vldl cholesterol measured in cord blood                                          |
| triglycerides_cord    | decimal | triglycerides measured in cord blood                                             |

*yearly-repeated variables*

| Variable    | Type    | Description                                                                                 |
|-------------|---------|---------------------------------------------------------------------------------------------|
| int_raw_    | decimal | internalizing problems, total raw score                                                     |
| int_age_    | decimal | exact age of the child (in years) when internalizing problems were recorded                 |
| int_instr_  | integer | Cohort-specific instrument used to measure the internalizing problems                       |
| int_eval_   | integer | who the test for measuring internalizing problems was administered/answered by              |
| int_pro_    | decimal | total internalizing problems score after prorating internalizing problems total raw score   |
| int_avg_    | decimal | average of available items comprising the total raw score of internalizing problems         |
| int_pc_     | decimal | internalizing problems, percentiles                                                         |
| ext_raw_    | decimal | externalizing problems, total raw score                                                     |
| ext_age_    | decimal | exact age of the child (in years) when externalizing problems were recorded                 |
| ext_instr_  | integer | Cohort-specific instrument used to measure the externalizing problems                       |
| ext_eval_   | integer | who the test for measuring externalizing problems was administered/answered by              |
| ext_pro_    | decimal | total externalizing problems score after prorating externalizing problems total raw score   |
| ext_avg_    | decimal | average of available items comprising the total raw score of externalizing problems         |
| ext_pc_     | decimal | externalizing problems, percentiles                                                         |
| adhd_raw_   | decimal | ADHD, total raw score                                                                       |
| adhd_age_   | decimal | exact age of the child (in years) when ADHD were recorded                                   |
| adhd_instr_ | integer | Cohort-specific instrument used to measure the ADHD                                         |
| adhd_eval_  | integer | who the test for measuring ADHD was administered/answered by                                |
| adhd_pro_   | decimal | total ADHD score after prorating ADHD total raw score                                       |
| adhd_avg_   | decimal | average of available items comprising the total raw score of ADHD                           |
| adhd_pc_    | decimal | ADHD, percentiles                                                                           |
| adhdR_      | integer | ADHD diagnosis                                                                              |
| adhdR_age_  | decimal | exact age of the child (in years) at onset for ADHD diagnosis                               |
| adhdR_eval_ | integer | how was the medical diagnosis reported for ADHD                                             |
| asd_raw_    | decimal | ASD, total raw score                                                                        |
| asd_age_    | decimal | exact age of the child (in years) when ASD were recorded                                    |
| asd_instr_  | integer | Cohort-specific instrument used to measure the ASD                                          |
| asd_eval_   | integer | who the test for measuring ASD was administered/answered by                                 |
| asd_pro_    | decimal | total ASD score after prorating ASD total raw score                                         |
| asd_avg_    | decimal | average of available items comprising the total raw score of ASD                            |
| asd_pc_     | decimal | ASD, percentiles                                                                            |
| asdR_       | integer | ASD diagnosis                                                                               |
| asdR_age_   | decimal | exact age of the child (in years) at onset for ASD diagnosis                                |
| asdR_eval_  | integer | how was the medical diagnosis reported for ASD                                              |
| gm_raw_     | decimal | gross motor, total raw score                                                                |
| gm_age_     | decimal | exact age of the child (in years) when gross motor were recorded                            |
| gm_instr_   | integer | Cohort-specific instrument used to measure the gross motor                                  |
| gm_eval_    | integer | who the test for measuring gross motor was administered/answered by                         |
| gm_pro_     | decimal | total gross motor score after prorating gross motor total raw score                         |
| gm_avg_     | decimal | average of available items comprising the total raw score of gross motor                    |
| gm_pc_      | decimal | gross motor, percentiles                                                                    |
| gm_std_     | decimal | gross motor, standardized score                                                             |
| fm_raw_     | decimal | fine motor, total raw score                                                                 |
| fm_age_     | decimal | exact age of the child (in years) when fine motor were recorded                             |
| fm_instr_   | integer | Cohort-specific instrument used to measure the fine motor                                   |
| fm_eval_    | integer | who the test for measuring fine motor was administered/answered by                          |
| fm_pro_     | decimal | total fine motor score after prorating fine motor total raw score                           |
| fm_avg_     | decimal | average of available items comprising the total raw score of fine motor                     |
| fm_pc_      | decimal | fine motor, percentiles                                                                     |
| fm_std_     | decimal | fine motor, standardized score                                                              |
| nvi_raw_    | decimal | non-verbal intelligence, total raw score                                                    |
| nvi_age_    | decimal | exact age of the child (in years) when non-verbal intelligence were recorded                |
| nvi_instr_  | integer | Cohort-specific instrument used to measure the non-verbal intelligence                      |
| nvi_eval_   | integer | who the test for measuring non-verbal intelligence was administered/answered by             |
| nvi_pro_    | decimal | total non-verbal intelligence score after prorating non-verbal intelligence total raw score |
| nvi_avg_    | decimal | average of available items comprising the total raw score of non-verbal intelligence        |
| nvi_pc_     | decimal | non-verbal intelligence, percentiles                                                        |
| nvi_std_    | decimal | non-verbal intelligence, standardized score                                                 |
| wm_raw_     | decimal | working memory, total raw score                                                             |
| wm_age_     | decimal | exact age of the child (in years) when working memory were recorded                         |
| wm_instr_   | integer | Cohort-specific instrument used to measure the working memory                               |
| wm_eval_    | integer | who the test for measuring working memory was administered/answered by                      |
| wm_pro_     | decimal | total working memory score after prorating working memory total raw score                   |
| wm_avg_     | decimal | average of available items comprising the total raw score of working memory                 |
| wm_pc_      | decimal | working memory, percentiles                                                                 |
| wm_std_     | decimal | working memory, standardized score                                                          |
| lan_raw_    | decimal | language, total raw score                                                                   |
| lan_age_    | decimal | exact age of the child (in years) when language were recorded                               |
| lan_instr_  | integer | Cohort-specific instrument used to measure the language                                     |
| lan_eval_   | integer | who the test for measuring language was administered/answered by                            |
| lan_pro_    | decimal | total language score after prorating language total raw score                               |
| lan_avg_    | decimal | average of available items comprising the total raw score of language                       |
| lan_pc_     | decimal | language, percentiles                                                                       |
| lan_std_    | decimal | language, standardized score                                                                |

### Tables
- 1_0_outcome_x_x_non_repeated
- 1_0_outcome_x_x_weekly_repeated
- 1_0_outcome_x_x_monthly_repeated
- 1_0_outcome_x_x_yearly_repeated
