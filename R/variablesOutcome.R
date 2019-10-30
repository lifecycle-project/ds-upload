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
  return(c(
    "glucose_cord", "haem_cord", "hba1c_cord", "insulin_cord", "crp_cord", "il6_cord", "adipo_cord", 
    "leptin_cord", "chol_cord", "hdlc_cord", "ldlc_cord", "vldlc_cord", "triglycerides_cord"
           ))
  })

#' List all measures for yearly repeated meaures for the outcome variables
#'
#' @returns list with yearly repeated measures for the outcome variables
lc.variables.outcome.yearly.repeated <- local(function() {
  return(c(
  ))
})

#' List all measures for weekly repeated pregnancy measures for the outcome variables
#'
#' @returns list with weekly repeated pregnancy measures for the outcome variables
lc.variables.outcome.weekly.repeated <- local(function() {
  return(as.vector(outer(c(
    'm_sbp_', 'm_dbp_', 'm_crp_', 'm_glucose_', 'm_haem_', 'm_hba1c_', 'm_insulin_',
    'm_hdl_', 'm_ldl_', 'm_chol_', 'm_triglycerides_', 'f_sbp_', 'f_dbp_'
  ), 0:42, paste, sep = ''
  )))
})

#' List all measures for monthly repeated meaures for the outcome variables
#'
#' @returns list with monthly repeated measures for the outcome variables
lc.variables.outcome.monthly.repeated <- local(function() {
  return(as.vector(outer(c(
    'heightmes_', 'weightmes_', 
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
