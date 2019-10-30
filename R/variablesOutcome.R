#' List all primary keys for all tables in LifeCycle dictionaries  
#'   
#' @returns list with primary keys 
lc.variables.primary.keys <- local(function() {
  return(c("child_id"))
})

#' List all measures for non repeated meaures for the outcome variables
#'
#' @returns list with non repeated measures for the outcome variables
lc.variables.outcome.non.repeated <- local(function() {
  return(c("glucose_cord", "haem_cord", "hba1c_cord", "insulin_cord", "crp_cord", "il6_cord", 
           "adipo_cord", "leptin_cord", "chol_cord", "hdlc_cord", "ldlc_cord", "vldlc_cord", "triglycerides_cord",
           "m_sbp_0", "m_sbp_1", "m_sbp_2", "m_sbp_3", "m_sbp_4", "m_sbp_5", "m_sbp_6", "m_sbp_7", "m_sbp_8", "m_sbp_9",
           "m_sbp_10", "m_sbp_11", "m_sbp_12", "m_sbp_13", "m_sbp_14", "m_sbp_15", "m_sbp_16", "m_sbp_17", "m_sbp_18",
           "m_sbp_19", "m_sbp_20", "m_sbp_21", "m_sbp_22", "m_sbp_23", "m_sbp_24", "m_sbp_25", "m_sbp_26", "m_sbp_27",
           "m_sbp_28", "m_sbp_29", "m_sbp_30", "m_sbp_31", "m_sbp_32", "m_sbp_33", "m_sbp_34", "m_sbp_35", "m_sbp_36",
           "m_sbp_37", "m_sbp_38", "m_sbp_39", "m_sbp_40", "m_sbp_41", "m_sbp_42", "m_dbp_0", "m_dbp_1", "m_dbp_2", 
           "m_dbp_3", "m_dbp_4", "m_dbp_5", "m_dbp_6", "m_dbp_7", "m_dbp_8", "m_dbp_9", "m_dbp_10", "m_dbp_11", "m_dbp_12", 
           "m_dbp_13", "m_dbp_14", "m_dbp_15", "m_dbp_16", "m_dbp_17", "m_dbp_18", "m_dbp_19", "m_dbp_20", "m_dbp_21", 
           "m_dbp_22", "m_dbp_23", "m_dbp_24", "m_dbp_25", "m_dbp_26", "m_dbp_27", "m_dbp_28", "m_dbp_29", "m_dbp_30", 
           "m_dbp_31", "m_dbp_32", "m_dbp_33", "m_dbp_34", "m_dbp_35", "m_dbp_36", "m_dbp_37", "m_dbp_38", "m_dbp_39", 
           "m_dbp_40", "m_dbp_41", "m_dbp_42", "m_crp_0", "m_crp_1", "m_crp_2", "m_crp_3", "m_crp_4", "m_crp_5", "m_crp_6", 
           "m_crp_7", "m_crp_8", "m_crp_9", "m_crp_10", "m_crp_11", "m_crp_12", "m_crp_13", "m_crp_14", "m_crp_15", "m_crp_16", 
           "m_crp_17", "m_crp_18", "m_crp_19", "m_crp_20", "m_crp_21", "m_crp_22", "m_crp_23", "m_crp_24", "m_crp_25", 
           "m_crp_26", "m_crp_27", "m_crp_28", "m_crp_29", "m_crp_30", "m_crp_31", "m_crp_32", "m_crp_33", "m_crp_34", 
           "m_crp_35", "m_crp_36", "m_crp_37", "m_crp_38", "m_crp_39", "m_crp_40", "m_crp_41", "m_crp_42", "m_glucose_0",
           "m_glucose_1", 'm_glucose_2', "m_glucose_3", "m_glucose_4", "m_glucose_5", "m_glucose_6", "m_glucose_7",
           "m_glucose_8", "m_glucose_9", "m_glucose_10", "m_glucose_11", "m_glucose_12", "m_glucose_13", "m_glucose_14",
           "m_glucose_15", "m_glucose_16", "m_glucose_17", "m_glucose_18", "m_glucose_19", "m_glucose_20", "m_glucose_21",
           "m_glucose_22", "m_glucose_23", "m_glucose_24", "m_glucose_25", "m_glucose_26", "m_glucose_27", "m_glucose_28",
           "m_glucose_29", "m_glucose_30", "m_glucose_31", "m_glucose_32", "m_glucose_33", "m_glucose_34", "m_glucose_35",
           "m_glucose_36", "m_glucose_37", "m_glucose_38", "m_glucose_39", "m_glucose_40", "m_glucose_41", "m_glucose_42",
           "m_haem_0", "m_haem_1", "m_haem_2", "m_haem_3", "m_haem_4","m_haem_5", "m_haem_6", "m_haem_7", "m_haem_8", 
           "m_haem_9", "m_haem_10", "m_haem_11", "m_haem_12", "m_haem_13", "m_haem_14", "m_haem_15", "m_haem_16", "m_haem_17", 
           "m_haem_18", "m_haem_19", "m_haem_20", "m_haem_21", "m_haem_22", "m_haem_23", "m_haem_24", "m_haem_25", "m_haem_26", 
           "m_haem_27", "m_haem_28", "m_haem_29", "m_haem_30", "m_haem_31", "m_haem_32", "m_haem_33", "m_haem_34", "m_haem_35", 
           "m_haem_36", "m_haem_37", "m_haem_38", "m_haem_39", "m_haem_40", "m_haem_41", "m_haem_42", 'm_hba1c_0', 'm_hba1c_1', 
           "m_hba1c_2", "m_hba1c_3", "m_hba1c_4", 'm_hba1c_5', "m_hba1c_6", "m_hba1c_7",  "m_hba1c_8", "m_hba1c_9", "m_hba1c_10", 
           "m_hba1c_11", "m_hba1c_12", "m_hba1c_13", "m_hba1c_14", "m_hba1c_15", 'm_hba1c_16', "m_hba1c_17", "m_hba1c_18", 
           "m_hba1c_19", "m_hba1c_20", "m_hba1c_21", "m_hba1c_22", "m_hba1c_23", 'm_hba1c_24', "m_hba1c_25", "m_hba1c_26", 
           "m_hba1c_27", "m_hba1c_28", "m_hba1c_29", "m_hba1c_30", "m_hba1c_31", "m_hba1c_32", "m_hba1c_33",  "m_hba1c_34", 
           "m_hba1c_35", "m_hba1c_36", "m_hba1c_37", "m_hba1c_38", "m_hba1c_39", "m_hba1c_40", "m_hba1c_41", "m_hba1c_42", 
           'm_insulin_0', 'm_insulin_1', "m_insulin_2", "m_insulin_3", "m_insulin_4", 'm_insulin_5', "m_insulin_6", "m_insulin_7",  
           "m_insulin_8", "m_insulin_9", "m_insulin_10", "m_insulin_11", "m_insulin_12", "m_insulin_13", "m_insulin_14", "m_insulin_15", 
           'm_insulin_16', "m_insulin_17", "m_insulin_18", "m_insulin_19", "m_insulin_20", "m_insulin_21", "m_insulin_22", "m_insulin_23", 
           'm_insulin_24', "m_insulin_25", "m_insulin_26", "m_insulin_27", "m_insulin_28", "m_insulin_29", "m_insulin_30", "m_insulin_31",
           "m_insulin_32", "m_insulin_33",  "m_insulin_34", "m_insulin_35", "m_insulin_36", "m_insulin_37", "m_insulin_38", "m_insulin_39", 
           "m_insulin_40", "m_insulin_41", "m_insulin_42", "m_hdl_0", "m_hdl_1", "m_hdl_2", "m_hdl_3", "m_hdl_4", "m_hdl_5", "m_hdl_6", 
           "m_hdl_7", "m_hdl_8",  "m_hdl_9", "m_hdl_10", "m_hdl_11", "m_hdl_12", "m_hdl_13", "m_hdl_14", "m_hdl_15", "m_hdl_16", "m_hdl_17", 
           'm_hdl_18', "m_hdl_19", "m_hdl_20", "m_hdl_21", 'm_hdl_22', "m_hdl_23", "m_hdl_24", 'm_hdl_25', "m_hdl_26", "m_hdl_27", "m_hdl_28", 
           "m_hdl_29", "m_hdl_30", "m_hdl_31", "m_hdl_32", "m_hdl_33", "m_hdl_34", "m_hdl_35", "m_hdl_36", "m_hdl_37", "m_hdl_38", "m_hdl_39", 
           "m_hdl_40", "m_hdl_41", "m_hdl_42", "m_ldl_0", "m_ldl_1", "m_ldl_2", "m_ldl_3", "m_ldl_4", "m_ldl_5", "m_ldl_6",  "m_ldl_7", 
           "m_ldl_8",  "m_ldl_9", "m_ldl_10", "m_ldl_11", "m_ldl_12", "m_ldl_13", "m_ldl_14", "m_ldl_15", "m_ldl_16", "m_ldl_17", 'm_ldl_18', 
           "m_ldl_19", "m_ldl_20", "m_ldl_21", 'm_ldl_22', "m_ldl_23", "m_ldl_24", 'm_ldl_25', "m_ldl_26", "m_ldl_27", "m_ldl_28", "m_ldl_29", 
           "m_ldl_30", "m_ldl_31", "m_ldl_32", "m_ldl_33", "m_ldl_34", "m_ldl_35", "m_ldl_36", "m_ldl_37", "m_ldl_38", "m_ldl_39", "m_ldl_40",
            "m_hdl_41", "m_hdl_42", "m_chol_0", "m_chol_1", "m_chol_2", "m_chol_3", "m_chol_4", "m_chol_5", "m_chol_6", "m_chol_7","m_chol_8",   
           "m_chol_9", "m_chol_10", "m_chol_11", "m_chol_12", "m_chol_13", "m_chol_14", "m_chol_15", "m_chol_16", "m_chol_17", 'm_chol_18', 
           "m_chol_19", "m_chol_20", "m_chol_21", 'm_chol_22', "m_chol_23", "m_chol_24", 'm_chol_25', "m_chol_26", "m_chol_27", "m_chol_28", 
           "m_chol_29", "m_chol_30", "m_chol_31", "m_chol_32", "m_chol_33", "m_chol_34", "m_chol_35", "m_chol_36", "m_chol_37", "m_chol_38", 
           "m_chol_39", "m_chol_40","m_chol_41", "m_chol_42", "m_triglycerides_0","m_triglycerides_1","m_triglycerides_2","m_triglycerides_3",
           "m_triglycerides_4", "m_triglycerides_5", "m_triglycerides_6", "m_triglycerides_7", "m_triglycerides_8", "m_triglycerides_9", 
           "m_triglycerides_10", "m_triglycerides_11", "m_triglycerides_12", "m_triglycerides_13", "m_triglycerides_14", "m_triglycerides_15",
           "m_triglycerides_16", "m_triglycerides_17", "m_triglycerides_18", "m_triglycerides_19", "m_triglycerides_20", "m_triglycerides_21",
           "m_triglycerides_22", "m_triglycerides_23", "m_triglycerides_24", "m_triglycerides_25", "m_triglycerides_26", "m_triglycerides_27",
           "m_triglycerides_28", "m_triglycerides_29", "m_triglycerides_30", "m_triglycerides_31", "m_triglycerides_32", "m_triglycerides_33",
           "m_triglycerides_34", "m_triglycerides_35", "m_triglycerides_36", "m_triglycerides_37", "m_triglycerides_38", "m_triglycerides_39",
           "m_triglycerides_40", "m_triglycerides_41", "m_triglycerides_42","f_sbp_0", "f_sbp_1", "_sbp_2", "f_sbp_3", "f_sbp_4", "f_sbp_5", 
           "f_sbp_6", "f_sbp_7", "f_sbp_8", "f_sbp_9","f_sbp_10", "f_sbp_11", "f_sbp_12", "f_sbp_13", "f_sbp_14", "f_sbp_15", "f_sbp_16", 
           "f_sbp_17", "f_sbp_18","f_sbp_19", "f_sbp_20", "f_sbp_21", "f_sbp_22", "f_sbp_23", "f_sbp_24", "f_sbp_25", "f_sbp_26", "f_sbp_27",
           "f_sbp_28", "f_sbp_29", "f_sbp_30", "f_sbp_31", "f_sbp_32", "f_sbp_33", "f_sbp_34", "f_sbp_35", "f_sbp_36","f_sbp_37", "f_sbp_38", 
           "f_sbp_39", "f_sbp_40", "f_sbp_41", "f_sbp_42", "f_dbp_0", "f_dbp_1", "f_dbp_2", "f_dbp_3", "f_dbp_4", "f_dbp_5", "f_dbp_6", "f_dbp_7", 
           "f_dbp_8", "f_dbp_9", "f_dbp_10", "f_dbp_11", "f_dbp_12", "f_dbp_13", "f_dbp_14", "f_dbp_15", "f_dbp_16", "f_dbp_17", "f_dbp_18", 
           "f_dbp_19", "f_dbp_20", "f_dbp_21", "f_dbp_22", "f_dbp_23", "f_dbp_24", "f_dbp_25", "f_dbp_26", "f_dbp_27", "f_dbp_28", "f_dbp_29", "f_dbp_30", 
           "f_dbp_31", "f_dbp_32", "f_dbp_33", "f_dbp_34", "f_dbp_35", "f_dbp_36", "f_dbp_37", "f_dbp_38", "f_dbp_39", "f_dbp_40", "f_dbp_41", "f_dbp_42"
           ))
  })

#' List all measures for yearly repeated meaures for the outcome variables
#'
#' @returns list with yearly repeated measures for the outcome variables
lc.variables.outcome.yearly.repeated <- local(function() {
  return(c(
    
  ))
})

#' List all measures for monthly repeated meaures for the outcome variables
#'
#' @returns list with monthly repeated measures for the outcome variables
lc.variables.outcome.monthly.repeated <- local(function() {
  return(as.vector(outer(c('heightmes_', 'weightmes_', 
                           'headcirc_', 'headcircage_', 'headcircmes_',
                           'waistcirc_', 'waistcircage_', 'waistcircmes_',
                           'hipcirc_', 'hipcircage_', 'hipcircmes_',
                           'armcirc_', 'armcircage_', 'armcircmes_', 'dominant_armc_',
                           'dxafm_', 'dxafmage_', 'dxafmmes_', 
                           'dxalm_', 'dxalmage_', 'dxalmmes_',
                           'bio_', 'bioage_', 'biomes_',
                           'bicepsf_', 'bicepsfage_', 'bicepsfmes_',
                           'subscapsf_', 'subscapsfage_', 'subscapsfmes_',
                           'tricepsf_', 'tricepsfage_', 'tricepsfmes_',
                           'suprasf_', 'suprasfage_', 'suprasfmes_',
                           'armlength_', 'armlengthage_', 'armlengthmes_',
                           'sittinght_', 'sittinghtage_', 'sittinghtmes_',
                           'glucose_', 'glucoseage_', 'glucosemes_',
                           'haem_', 'haemage_', 'haemmes_',
                           'hba1c_', 'hba1cage_', 'hba1cmes_',
                           'insulin_', 'insulinage_', 'insulinmes_',
                           'crp_', 'crpage_', 'crpmes_',
                           'il6_', 'il6age_', 'il6mes_',
                           'adipo_', 'adipoage_', 'adipomes_',
                           'leptin_', 'leptinage_', 'leptinmes_',
                           'chol_', 'cholage_', 'cholmes_',
                           'hdlc_c', 'hdlcage_', 'hdlcmes_',
                           'ldlc_', 'ldlcage_', 'ldlcmes_',
                           'vldlc_', 'vldlcage_', 'vldlcmes_',
                           'triglycerides_', 'triglyceridesage_', 'triglyceridesmes_',
                           'sbp_', 'dbp_', 'sbpav_', 'dbpav_', 'bpage_',
                           'pulse_', 'pulseage_', 'pulsemessit_',
                           'csbp_', 'cdbp_', 'cbpage_', 'cbpsit_',
                           'crpwv_', 'crpwvage_','cfpwv_', 'cfpwvage_',
                           'cimt_', 'cimtage_', 'cimtmes_'
                           
                           ), 0:215, paste, sep = ''
  )))
})
