#' List all primary keys for all tables in LifeCycle dictionaries  
#'   
#' @return list with primary keys 
lc.variables.primary.keys <- local(function() {
  return(c("child_id"))
})

#' List all measures for non repeated meaures for the core variables
#'
#' @return list with non repeated measures for the core variables
lc.variables.core.non.repeated <- local(function() {
  return(c("mother_id", "preg_no", "child_no", "cohort_id", "recruit_age",  "coh_country", "cob_m", "ethn1_m", "ethn2_m", "ethn3_m", "agebirth_m_y", "agebirth_m_d", 
           "death_m", "death_m_age", "prepreg_weight", "prepreg_weight_mes", "prepreg_weight_ga",  "latepreg_weight", 
           "latepreg_weight_mes", "latepreg_weight_ga",  "preg_gain", "preg_gain_mes", "height_m",  "height_mes_m", 
           "prepreg_dia", "preg_dia", "preg_thyroid", "preg_fever", "preeclam", "preg_ht", "asthma_m", "prepreg_psych", 
           "preg_psych", "ppd", "prepreg_smk", "prepreg_cig", "preg_smk", "preg_cig", "prepreg_alc", "prepreg_alc_unit", "preg_alc",  "preg_alc_unit", 
           "folic_prepreg", "folic_preg12", "folic_post12", "parity_m", "preg_plan", "mar", "ivf", "outcome", "mode_delivery", "plac_abrup", "cob_p", "cob_p_fath", 
           "ethn1_p", "ethn2_p", "ethn3_p", "ethn_p_fath", "agebirth_p_y", "agebirth_p_d", "agebirth_p_fath", "death_p", 
           "death_p_age", "death_p_fath", "weight_f1", "weight_mes_f1", "weight_f1_fath", "height_f1", "height_mes_f1", 
           "height_f1_fath", "dia_bf", "asthma_bf", "psych_bf", "smk_p", "smk_cig_p", "smk_fath", "birth_month", "birth_year", 
           "apgar",  "neo_unit",  "sex", "plurality", "ga_lmp", "ga_us", "ga_mr", "ga_bj", "birth_weight", "birth_length", "birth_head_circum", 
           "weight_who_ga", "plac_weight",  "con_anomalies",  "major_con_anomalies", "cer_palsy", "sibling_pos", "death_child", 
           "death_child_age", "breastfed_excl", "breastfed_any", "breastfed_ever", "solid_food", "childcare_intro", "cats_preg", 
           "cats_quant_preg", "dogs_preg", "dogs_quant_preg", "eusilc_income", "eusilc_income_quintiles", "miggen", "region_mo", 
           "region_fa", "reledu_mo", "reledu_fa", "urb_area_id", "no2_preg", "nox_preg", "pm10_preg", "pm25_preg", "pmcoarse_preg", "pm25abs_preg", 
           "pm25cu_preg", "pm25fe_preg", "pm25k_preg", "pm25ni_preg", "pm25s_preg", "pm25si_preg", "pm25v_preg", "pm25zn_preg", "pm10cu_preg", 
           "pm10fe_preg", "pm10k_preg", "pm10ni_preg", "pm10s_preg", "pm10si_preg", "pm10v_preg", "pm10zn_preg", "popdens_preg", "bdens100_preg", 
           "bdens300_preg", "connind100_preg", "connind300_preg", "bus_lines_100_preg", "bus_lines_300_preg", "bus_lines_500_preg", "bus_stops_100_preg", 
           "bus_stops_300_preg", "bus_stops_500_preg", "fdensity300_preg", "frichness300_preg", "landuseshan300_preg", "walkability_mean_preg", "agrgr_preg",
           "airpt_preg", "hdres_preg", "indtr_preg", "ldres_preg", "natgr_preg", "other_preg", "port_preg", "trans_preg", "urbgr_preg", "vldres_preg", 
           "water_preg", "blue_dist_preg", "green_dist_preg", "blue_size_preg", "green_size_preg", "blueyn300_preg", "greenyn300_preg", "ndvi100_preg", 
           "ndvi300_preg", "ndvi500_preg", "lden_preg", "ln_preg", "lden_c_preg", "ln_c_preg", "noise_dist_preg", "areases_tert_preg", "areases_quint_preg",
           "distinvnear1_preg", "trafload100_preg", "trafmajorload100_preg", "trafnear_preg", "foodenvdens300_preg", "foodenvdensosm300_preg",
           "tm_preg", "tmin_preg", "tmax_preg", "hum_preg", "hmin_preg", "hmax_preg", "uvddc_preg", "uvdec_preg", "uvdvc_preg", "lst_preg", "sleept_psc", 
           "sleeptage_psc", "outdoorp_psc", "outdoorpage_psc", "tv_psc", "screenoth_psc", "screenage_psc", "patternA_snackscreen_psc", "patternB_psc", 
           "veg_pgn", "fruit_pgn", "dairy_pgn", "fish_pgn", "meat_pgn", "pulses_pgn", "sugar_pgn", "egg_pgn", "grain_pgn", "lfdairy_pgn", 
           "ffish_pgn", "nffish_pgn", "redmeat_pgn", "procmeat_pgn", "whgrains_pgn", "swebev_pgn", "potat_pgn", "sav_pgn", "dietass_pgn", 
           "dietga_pgn", "veg_psc", "fruit_psc", "dairy_psc", "fish_psc", "meat_psc", "pulses_psc", "sugar_psc", "egg_psc", "grain_psc", 
           "lfdairy_psc", "ffish_psc", "nffish_psc", "redmeat_psc", "procmeat_psc", "whgrains_psc", "swebev_psc", "potat_psc", "sav_psc", 
           "dietass_psc", "dietage_psc", "veg_sch", "fruit_sch", "dairy_sch", "fish_sch", "meat_sch", "pulses_sch", "sugar_sch", "egg_sch", 
           "grain_sch", "lfdairy_sch", "ffish_sch", "nffish_sch", "redmeat_sch", "procmeat_sch", "whgrains_sch", "swebev_sch", "potat_sch", 
           "sav_sch", "dietass_sch", "dietage_sch", "kcal_pgn", "totfat_pgn", "percfat_pgn", "satfat_pgn", "pufas_pgn", "transfat_pgn", 
           "totprot_pgn", "percprot_pgn", "totcarb_pgn", "perccarb_pgn", "na_pgn", "kcal_psc", "totfat_psc", "percfat_psc", "satfat_psc", 
           "pufas_psc", "transfat_psc", "totprot_psc", "percprot_psc", "totcarb_psc", "perccarb_psc", "na_psc", "kcal_sch", "totfat_sch", 
           "percfat_sch", "satfat_sch", "pufas_sch", "transfat_sch", "totprot_sch", "percprot_sch", "totcarb_sch", "perccarb_sch", "na_sch", 
           "dash_pgn", "dash_sch", "skipbreakf_psc", "famdinner_psc", "tveat_psc", "mainmeal_psc", "snacks_psc", "fastfood_psc", "skipbreakf_sch", 
           "famdinner_sch", "tveat_sch", "mainmeal_sch", "snacks_sch", "fastfood_sch", "supp_pgn", "supp_psc", "supp_sch"))
})

#' List all measures for yearly repeated meaures for the core variables
#'
#' @return list with yearly repeated measures for the core variables
lc.variables.core.yearly.repeated <- local(function() {
  yearly_from_0_till_17 <- as.vector(outer(c(
    "cohab_", "occup_m_", "occupcode_m_", "edu_m_", "occup_f1_", "occup_f1_fath", "occup_f2_", "occup_f2_fath",
    "occupcode_f1_", "occupcode_f1_fath", "occupcode_f2_", "occupcode_f2_fath", "edu_f1_", "edu_f1_fath", "edu_f2_",
    "edu_f2_fath", "smk_exp", "pets_", "cats_", "cats_quant_", "dogs_", "dogs_quant_", "mental_exp", "hhincome_",
    "fam_splitup", "famsize_child", "famsize_adult"
    ), 0:17, paste, sep = ''))
  
  yearly_from_1_till_12 <- as.vector(outer(c(
    "no2_", "nox_", "pm10_", "pm25_", "pmcoarse_", "pm25abs_", "tm_", "tmin_", "tmax_", "hum_", "hmin_", "hmax_", 
    "uvddc_", "uvdec_", "uvdvc_", "lst_"
    ), 1:12, paste, sep = ''))
  
  yearly_from_0_till_12 <- as.vector(outer(c(
    "pm25cu_", "pm25fe_", "pm25k_", "pm25ni_", "pm25s_", "pm25si_", "pm25v_", "pm25zn_", "pm10cu_", "pm10fe_", "pm10k_", "pm10ni_", 
    "pm10s_", "pm10v_", "pm10zn_", "popdens_", "bdens100_", "bdens300_", "connind100_", "connind300_", "bus_lines_100_", "bus_lines_300_",
    "bus_lines_500_", "bus_stops_100_", "bus_stops_300_", "bus_stops_500_", "fdensity300_", "frichness300_", "landuseshan300_",
    "walkability_mean_", "agrgr_", "airpt_", "hdres_", "indtr_", "ldres_", "natgr_", "other_", "port_", "trans_", "urbgr_", "vldres_",
    "water_", "blue_dist_", "green_dist_", "blue_size_", "green_size_", "blueyn300_", "ndvi100_", "ndvi300_", "ndvi500_", "lden_",
    "ln_", "lden_c_", "ln_c_", "noise_dist_", "areases_tert_", "areases_quint_", "distinvnear1_", "trafload100_", "trafmajorload100_", 
    "trafnear_", "foodenvdens300_", "foodenvdensosm300_"
    ), 0:12, paste, sep = ''))
  
  yearly_from_0_till_3 <- as.vector(outer(c(
    "childcare_", "childcarerel_", "childcareprof_", "childcarecentre_"
    ), 0:3, paste, sep = ''))
  
  return(c(yearly_from_0_till_3, yearly_from_0_till_12, yearly_from_1_till_12, yearly_from_0_till_17))
})

#' List all measures for monthly repeated meaures for the core variables
#'
#' @return list with monthly repeated measures for the core variables
lc.variables.core.monthly.repeated <- local(function() {
  return(as.vector(outer(c("height_","height_age","weight_","weight_age"), 0:215, paste, sep = "")))
})

#' List all measures for trimesterly repeated meaures for the core variables
#'
#' @return list with trimesterly repeated measures for the core variables
lc.variables.core.trimester.repeated <- local(function() {
  return(as.vector(outer(c(
    "smk_t","alc_t","no2_t","nox_t","pm10_t","pm25_t","pmcoarse_t","pm25abs_t","pm25cu_t","pm25fe_t",
    "pm25k_t","pm25ni_t","pm25s_t","pm25si_t","pm25v_t","pm25zn_t","pm10cu_t","pm10fe_t","pm10k_t",
    "pm10ni_t","pm10s_t","pm10si_t","pm10v_t","pm10zn_t","popdens_t","bdens100_t","bdens300_t","connind100_t",
    "connind300_t","bus_lines_100_t","bus_lines_300_t","bus_lines_500_t","bus_stops_100_t","bus_stops_300_t",
    "bus_stops_500_t","fdensity300_t","frichness300_t","landuseshan300_t","walkability_mean_t","agrgr_t",
    "airpt_t","hdres_t","indtr_t","ldres_t","natgr_t","other_t","port_t","trans_t","urbgr_t","vldres_t","water_t",
    "blue_dist_t","green_dist_t","blue_size_t","green_size_t","blueyn300_t","greenyn300_t","ndvi100_t","ndvi300_t",
    "ndvi500_t","lden_t","ln_t","lden_c_t","ln_c_t","noise_dist_t","areases_tert_t","areases_quint_t","distinvnear1_t",
    "trafload100_t","trafmajorload100_t","trafnear_t","foodenvdens300_t","foodenvdensosm300_t","tm_t","tmin_t","tmax_t",
    "hum_t","hmin_t","hmax_t","uvddc_t","uvdec_t","uvdvc_t","lst_t"
  ), 1:3, paste, sep = "")))
})
