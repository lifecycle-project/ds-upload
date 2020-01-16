#' List all primary keys for all tables in LifeCycle dictionaries  
#'   
#' @return list with primary keys 
lc.variables.primary.keys <- local(function() {
  return(c("child_id"))
})

#' List all measures for non repeated meaures for the outcome variables
#'
#' @return list with non repeated measures for the outcome variables
lc.variables.outcome.non.repeated <- local(function() {
 return(c(
   "glucose_cord", "haem_cord", "hba1c_cord", "insulin_cord", "crp_cord", "il6_cord", "adipo_cord", 
   "leptin_cord", "chol_cord", "hdlc_cord", "ldlc_cord", "vldlc_cord", "triglycerides_cord",
   "eczema_m", "allergy_inh_m", "allergy_food_m", "allergy_any_m", "whe_ever", "whe_ever2",
   "whe_ever4", "whe_ever5_10", "asthma_ever_CHICOS", "asthma_ever_MeDALL", "asthma_current_MeDALL", 
   "asthma_current_CHICOS", "food_all_ever", "inh_all_ever", "all_ever", "urticaria", "anaphylaxis", 
   "eczema_ever", "asthma_adult", "COPD_adult_GOLD", "COPD_adult_LLN", "COPD_adult_diagnosis", "pets_pregn"))
})

#' List all measures for yearly repeated meaures for the outcome variables
#'
#' @return list with yearly repeated measures for the outcome variables
lc.variables.outcome.yearly.repeated <- local(function() {
 return(as.vector(outer(c(
    "int_raw_", "int_age_", "int_instr_", "int_eval_", "int_pro_", "int_avg_", "int_pc_", 
    "ext_raw_", "ext_age_", "ext_instr_", "ext_eval_", "ext_pro_", "ext_avg_", "ext_pc_", 
    "adhd_raw_", "adhd_age_", "adhd_instr_", "adhd_eval_", "adhd_pro_", "adhd_avg_", "adhd_pc_", "adhdR_", "adhdR_age_", "adhdR_eval_", 
    "asd_raw_", "asd_age_", "asd_instr_", "asd_eval_", "asd_pro_", "asd_avg_", "asd_pc_", "asdR_", "asdR_age_", "asdR_eval_", 
    "gm_raw_", "gm_age_", "gm_instr_", "gm_eval_", "gm_pro_", "gm_avg_", "gm_pc_", "gm_std_", 
    "fm_raw_", "fm_age_", "fm_instr_", "fm_eval_", "fm_pro_", "fm_avg_", "fm_pc_", "fm_std_", 
    "nvi_raw_", "nvi_age_", "nvi_instr_", "nvi_eval_", "nvi_pro_", "nvi_avg_", "nvi_pc_", "nvi_std_", 
    "wm_raw_", "wm_age_", "wm_instr_", "wm_eval_", "wm_pro_", "wm_avg_", "wm_pc_", "wm_std_", 
    "lan_raw_", "lan_age_", "lan_instr_", "lan_eval_", "lan_pro_", "lan_avg_", "lan_pc_", "lan_std_",
    "whe_", "asthma_", "asthma_med_", "asthma_med_spec_", "URTI_", "LRTI_", "FEV1_abs_", 
    "FVC_abs_", "FEF25_abs_", "FEF5_abs_", "FEF75_abs_", "FEV1_z_", "FVC_z_", "FEV1FVC_z_", 
    "repro_", "BHR_", "FeNO_", "food_all_", "inh_all_", "all_", "food_all_sens_SPT_", 
    "inh_all_sens_SPT_", "inh_all_sens_IgE__HDM", "inh_all_sens_IgE__CAT", "inh_all_sens_IgE__RYE",
    "inh_all_sens_IgE__GRASS", "inh_all_sens_IgE__MOULD", "eczema_", "rash_", "rash_loc_" 
 ), 0:17, paste, sep = ""
 )))
})

#' List all measures for weekly repeated pregnancy measures for the outcome variables
#'
#' @return list with weekly repeated pregnancy measures for the outcome variables
lc.variables.outcome.weekly.repeated <- local(function() {
  return(as.vector(outer(c(
    "m_sbp_", "m_dbp_", "m_crp_", "m_glucose_", "m_haem_", "m_hba1c_", "m_insulin_",
    "m_hdl_", "m_ldl_", "m_chol_", "m_triglycerides_", "f_sbp_", "f_dbp_"
  ), 0:42, paste, sep = ""
  )))
})

#' List all measures for monthly repeated meaures for the outcome variables
#'
#' @return list with monthly repeated measures for the outcome variables
lc.variables.outcome.monthly.repeated <- local(function() {
  return(as.vector(outer(c(
    "heightmes_", "weightmes_", 
    "headcirc_", "headcircage_", "headcircmes_",
    "waistcirc_", "waistcircage_", "waistcircmes_",
    "hipcirc_", "hipcircage_", "hipcircmes_",
    "armcirc_", "armcircage_", "armcircmes_", "dominant_armc_",
    "dxafm_", "dxafmage_", "dxafmmes_", 
    "dxalm_", "dxalmage_", "dxalmmes_",
    "bio_", "bioage_", "biomes_",
    "bicepsf_", "bicepsfage_", "bicepsfmes_",
    "subscapsf_", "subscapsfage_", "subscapsfmes_",
    "tricepsf_", "tricepsfage_", "tricepsfmes_",
    "suprasf_", "suprasfage_", "suprasfmes_",
    "armlength_", "armlengthage_", "armlengthmes_",
    "sittinght_", "sittinghtage_", "sittinghtmes_",
    "glucose_", "glucoseage_", "glucosemes_",
    "haem_", "haemage_", "haemmes_",
    "hba1c_", "hba1cage_", "hba1cmes_",
    "insulin_", "insulinage_", "insulinmes_",
    "crp_", "crpage_", "crpmes_",
    "il6_", "il6age_", "il6mes_",
    "adipo_", "adipoage_", "adipomes_",
    "leptin_", "leptinage_", "leptinmes_",
    "chol_", "cholage_", "cholmes_",
    "hdlc_c", "hdlcage_", "hdlcmes_",
    "ldlc_", "ldlcage_", "ldlcmes_",
    "vldlc_", "vldlcage_", "vldlcmes_",
    "triglycerides_", "triglyceridesage_", "triglyceridesmes_",
    "sbp_", "dbp_", "sbpav_", "dbpav_", "bpage_",
    "pulse_", "pulseage_", "pulsemessit_",
    "csbp_", "cdbp_", "cbpage_", "cbpsit_",
    "crpwv_", "crpwvage_","cfpwv_", "cfpwvage_",
    "cimt_", "cimtage_", "cimtmes_"
   ), 0:215, paste, sep = ""
  )))
})
