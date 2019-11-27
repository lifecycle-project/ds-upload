#' List all primary keys for all tables in LifeCycle dictionaries  
#'   
#' @return list with primary keys 
lc.variables.primary.keys <- local(function() {
  return(c("child_id"))
})', 'haemage_', 'haemmes_',
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
