#' Reshape Script for R: LifeCycle Harmonized Data
#'
#' @param upload_to_opal do you want automatically upload the files to your opal (default = true)
#' @param data_version version of the data you are going to upload into Opal
#' @param input_format possible formats are CSV,STATA,SPSS or SAS (default = CSV)
#' @param input_path path for importfile
#' @param output_path path to output directory (default = your working directory)
#' 
#' @examples 
#' lc.reshape.core(
#'   upload_to_opal = FALSE, 
#'   data_version = '1_0', 
#'   input_format = 'SPSS', 
#'   input_path = 'C:\MyDocuments\source_file.sav', 
#'   output_path = 'C:\MyDocuments\output_file.csv')
#'
#' @export
lc.reshape.core <- local(function(upload_to_opal = TRUE, data_version, input_format = 'CSV', input_path, output_path = getwd()) {
  
  message('######################################################')
  message('  Start reshaping data                                ')
  message('######################################################')
  message("* Setup: load data and set output directory")
  message('------------------------------------------------------')
  
  if (upload_to_opal) {
    if(!exists('hostname', envir = lifecycle.globals)) stop('You need to login first, please run lc.login')
    if(!exists('username', envir = lifecycle.globals)) stop('You need to login first, please run lc.login')
  }
  
  lc_data <- lc.read.source.file(input_path, input_format)
  
  file_prefix <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
  if(missing(data_version)) {
    data_version <- readline('- Specify version of cohort data upload (e.g. 1_0): ')
  }
  if(checkVersion(data_version)) {
    file_version <- data_version
  } else {
    stop("The data version does not match syntax: 'number_number'! Program is terminated.", call. = FALSE)
  }
  
  # Set order of variables
  lc_variables <- c("child_id", "mother_id", "preg_no", "child_no", "cohort_id", "recruit_age",  "coh_country", "cohab_0",
                    "cohab_1", "cohab_2", "cohab_3", "cohab_4", "cohab_5", "cohab_6", "cohab_7", "cohab_8", "cohab_9", "cohab_10", "cohab_11", 
                    "cohab_12", "cohab_13", "cohab_14", "cohab_15", "cohab_16", "cohab_17", "occup_m_0", "occup_m_1", "occup_m_2", 
                    "occup_m_3", "occup_m_4", "occup_m_5", "occup_m_6", "occup_m_7", "occup_m_8", "occup_m_9", "occup_m_10", "occup_m_11",
                    "occup_m_12", "occup_m_13", "occup_m_14", "occup_m_15", "occup_m_16", "occup_m_17", "occupcode_m_0", "occupcode_m_1", 
                    "occupcode_m_2", "occupcode_m_3", "occupcode_m_4", "occupcode_m_5", "occupcode_m_6", "occupcode_m_7", 
                    "occupcode_m_8", "occupcode_m_9", "occupcode_m_10", "occupcode_m_11", "occupcode_m_12", "occupcode_m_13", 
                    "occupcode_m_14", "occupcode_m_15", "occupcode_m_16", "occupcode_m_17", "edu_m_0", "edu_m_1", "edu_m_2", "edu_m_3", 
                    "edu_m_4", "edu_m_5", "edu_m_6", "edu_m_7", "edu_m_8", "edu_m_9", "edu_m_10", "edu_m_11", "edu_m_12", "edu_m_13", 
                    "edu_m_14", "edu_m_15", "edu_m_16", "edu_m_17", "cob_m", "ethn1_m", "ethn2_m", "ethn3_m", "agebirth_m_y", "agebirth_m_d", 
                    "death_m", "death_m_age", "prepreg_weight", "prepreg_weight_mes", "prepreg_weight_ga",  "latepreg_weight", 
                    "latepreg_weight_mes", "latepreg_weight_ga",  "preg_gain", "preg_gain_mes", "height_m",  "height_mes_m", 
                    "prepreg_dia", "preg_dia", "preg_thyroid", "preg_fever", "preeclam", "preg_ht", "asthma_m", "prepreg_psych", 
                    "preg_psych", "ppd", "prepreg_smk", "prepreg_cig",  "smk_t1", "smk_t2", "smk_t3", "preg_smk", "preg_cig", "prepreg_alc", 
                    "prepreg_alc_unit", "preg_alc",  "preg_alc_unit",  "alc_t1", "alc_t2", "alc_t3", "folic_prepreg", "folic_preg12", 
                    "folic_post12", "parity_m", "preg_plan", "mar", "ivf",  "outcome", "mode_delivery", "plac_abrup", "occup_f1_0", 
                    "occup_f1_1", "occup_f1_2", "occup_f1_3", "occup_f1_4", "occup_f1_5", "occup_f1_6", "occup_f1_7", "occup_f1_8", 
                    "occup_f1_9", "occup_f1_10", "occup_f1_11", "occup_f1_12", "occup_f1_13", "occup_f1_14", "occup_f1_15", "occup_f1_16", 
                    "occup_f1_17", "occup_f1_fath0", "occup_f1_fath1", "occup_f1_fath2", "occup_f1_fath3", "occup_f1_fath4", "occup_f1_fath5", 
                    "occup_f1_fath6", "occup_f1_fath7", "occup_f1_fath8", "occup_f1_fath9", "occup_f1_fath10", "occup_f1_fath11", 
                    "occup_f1_fath12", "occup_f1_fath13", "occup_f1_fath14", "occup_f1_fath15", "occup_f1_fath16", "occup_f1_fath17", 
                    "occup_f2_0", "occup_f2_1", "occup_f2_2", "occup_f2_3", "occup_f2_4", "occup_f2_5", "occup_f2_6", "occup_f2_7", "occup_f2_8", 
                    "occup_f2_9", "occup_f2_10", "occup_f2_11", "occup_f2_12", "occup_f2_13", "occup_f2_14", "occup_f2_15", "occup_f2_16", 
                    "occup_f2_17", "occup_f2_fath0", "occup_f2_fath1", "occup_f2_fath2", "occup_f2_fath3", "occup_f2_fath4", "occup_f2_fath5", 
                    "occup_f2_fath6", "occup_f2_fath7", "occup_f2_fath8", "occup_f2_fath9", "occup_f2_fath10", "occup_f2_fath11", 
                    "occup_f2_fath12", "occup_f2_fath13", "occup_f2_fath14", "occup_f2_fath15", "occup_f2_fath16", "occup_f2_fath17", 
                    "occupcode_f1_0", "occupcode_f1_1", "occupcode_f1_2", "occupcode_f1_3", "occupcode_f1_4", "occupcode_f1_5", 
                    "occupcode_f1_6", "occupcode_f1_7", "occupcode_f1_8", "occupcode_f1_9", "occupcode_f1_10", "occupcode_f1_11", 
                    "occupcode_f1_12", "occupcode_f1_13", "occupcode_f1_14", "occupcode_f1_15", "occupcode_f1_16", "occupcode_f1_17", 
                    "occupcode_f1_fath0", "occupcode_f1_fath1", "occupcode_f1_fath2", "occupcode_f1_fath3", "occupcode_f1_fath4", 
                    "occupcode_f1_fath5", "occupcode_f1_fath6", "occupcode_f1_fath7", "occupcode_f1_fath8", "occupcode_f1_fath9", 
                    "occupcode_f1_fath10", "occupcode_f1_fath11", "occupcode_f1_fath12", "occupcode_f1_fath13", "occupcode_f1_fath14", 
                    "occupcode_f1_fath15", "occupcode_f1_fath16", "occupcode_f1_fath17", "occupcode_f2_0", "occupcode_f2_1",  "occupcode_f2_2", 
                    "occupcode_f2_3", "occupcode_f2_4", "occupcode_f2_5", "occupcode_f2_6", "occupcode_f2_7",  "occupcode_f2_8", "occupcode_f2_9", 
                    "occupcode_f2_10", "occupcode_f2_11", "occupcode_f2_12", "occupcode_f2_13", "occupcode_f2_14", "occupcode_f2_15", 
                    "occupcode_f2_16", "occupcode_f2_17", "occupcode_f2_fath0", "occupcode_f2_fath1", "occupcode_f2_fath2", "occupcode_f2_fath3", 
                    "occupcode_f2_fath4", "occupcode_f2_fath5", "occupcode_f2_fath6", "occupcode_f2_fath7", "occupcode_f2_fath8", 
                    "occupcode_f2_fath9", "occupcode_f2_fath10", "occupcode_f2_fath11", "occupcode_f2_fath12", "occupcode_f2_fath13", 
                    "occupcode_f2_fath14", "occupcode_f2_fath15", "occupcode_f2_fath16", "occupcode_f2_fath17", "edu_f1_0", "edu_f1_1", "edu_f1_2", 
                    "edu_f1_3", "edu_f1_4", "edu_f1_5", "edu_f1_6", "edu_f1_7", "edu_f1_8",  "edu_f1_9", "edu_f1_10", "edu_f1_11", "edu_f1_12", "edu_f1_13", 
                    "edu_f1_14", "edu_f1_15", "edu_f1_16", "edu_f1_17", "edu_f1_fath0", "edu_f1_fath1", "edu_f1_fath2", "edu_f1_fath3", 
                    "edu_f1_fath4", "edu_f1_fath5", "edu_f1_fath6", "edu_f1_fath7", "edu_f1_fath8", "edu_f1_fath9", "edu_f1_fath10", 
                    "edu_f1_fath11", "edu_f1_fath12", "edu_f1_fath13", "edu_f1_fath14", "edu_f1_fath15", "edu_f1_fath16", 
                    "edu_f1_fath17", "edu_f2_0", "edu_f2_1", "edu_f2_2", "edu_f2_3", "edu_f2_4", "edu_f2_5", "edu_f2_6", "edu_f2_7", 
                    "edu_f2_8", "edu_f2_9", "edu_f2_10", "edu_f2_11", "edu_f2_12", "edu_f2_13", "edu_f2_14", "edu_f2_15", "edu_f2_16", 
                    "edu_f2_17", "edu_f2_fath0", "edu_f2_fath1", "edu_f2_fath2", "edu_f2_fath3", "edu_f2_fath4", "edu_f2_fath5", 
                    "edu_f2_fath6", "edu_f2_fath7", "edu_f2_fath8", "edu_f2_fath9", "edu_f2_fath10", "edu_f2_fath11",  "edu_f2_fath12", 
                    "edu_f2_fath13", "edu_f2_fath14", "edu_f2_fath15", "edu_f2_fath16", "edu_f2_fath17", "cob_p", "cob_p_fath", 
                    "ethn1_p", "ethn2_p", "ethn3_p", "ethn_p_fath", "agebirth_p_y", "agebirth_p_d", "agebirth_p_fath", "death_p", 
                    "death_p_age", "death_p_fath", "weight_f1", "weight_mes_f1", "weight_f1_fath", "height_f1", "height_mes_f1", 
                    "height_f1_fath", "dia_bf", "asthma_bf", "psych_bf", "smk_p", "smk_cig_p", "smk_fath", "birth_month", "birth_year", 
                    "apgar",  "neo_unit",  "sex", "plurality", "ga_lmp", "ga_us", "ga_mr", "ga_bj", "birth_weight", "birth_length", "birth_head_circum", 
                    "weight_who_ga", "plac_weight",  "con_anomalies",  "major_con_anomalies", "cer_palsy", "sibling_pos", "death_child", 
                    "death_child_age", "height_0", "height_1", "height_2", "height_3", "height_4", "height_5", "height_6", "height_7", 
                    "height_8", "height_9", "height_10", "height_11", "height_12", "height_13", "height_14", "height_15", "height_16", "height_17", 
                    "height_18", "height_19", "height_20", "height_21", "height_22", "height_23", "height_24", "height_25", "height_26", 
                    "height_27", "height_28", "height_29", "height_30", "height_31", "height_32", "height_33", "height_34", "height_35", 
                    "height_36", "height_37", "height_38", "height_39", "height_40", "height_41", "height_42", "height_43", "height_44", 
                    "height_45", "height_46", "height_47", "height_48", "height_49", "height_50", "height_51", "height_52", "height_53", 
                    "height_54", "height_55", "height_56", "height_57", "height_58", "height_59", "height_60", "height_61", "height_62", 
                    "height_63", "height_64", "height_65", "height_66", "height_67", "height_68", "height_69", "height_70", "height_71", 
                    "height_72", "height_73", "height_74", "height_75", "height_76", "height_77", "height_78", "height_79", "height_80", 
                    "height_81", "height_82", "height_83", "height_84", "height_85", "height_86", "height_87", "height_88", "height_89", 
                    "height_90", "height_91", "height_92", "height_93", "height_94", "height_95", "height_96", "height_97", "height_98", 
                    "height_99", "height_100", "height_101", "height_102", "height_103", "height_104", "height_105", "height_106",  "height_107", 
                    "height_108", "height_109", "height_110", "height_111", "height_112", "height_113", "height_114", "height_115", 
                    "height_116", "height_117", "height_118", "height_119", "height_120", "height_121", "height_122",  "height_123", 
                    "height_124", "height_125", "height_126", "height_127", "height_128", "height_129", "height_130", "height_131", 
                    "height_132", "height_133", "height_134", "height_135", "height_136", "height_137",  "height_138", "height_139", 
                    "height_140", "height_141", "height_142", "height_143", "height_144", "height_145", "height_146", "height_147", 
                    "height_148", "height_149", "height_150", "height_151", "height_152", "height_153", "height_154",  "height_155", 
                    "height_156", "height_157", "height_158", "height_159", "height_160", "height_161", "height_162", "height_163", 
                    "height_164", "height_165", "height_166", "height_167", "height_168", "height_169", "height_170", "height_171", 
                    "height_172", "height_173", "height_174", "height_175", "height_176", "height_177", "height_178", "height_179", 
                    "height_180", "height_181", "height_182", "height_183", "height_184", "height_185", "height_186", "height_187", 
                    "height_188", "height_189", "height_190", "height_191", "height_192",  "height_193", "height_194", "height_195", 
                    "height_196", "height_197", "height_198", "height_199", "height_200", "height_201", "height_202", "height_203", 
                    "height_204", "height_205", "height_206", "height_207", "height_208", "height_209", "height_210", "height_211", 
                    "height_212", "height_213", "height_214", "height_215", "height_age0", "height_age1", "height_age2", "height_age3",
                    "height_age4", "height_age5", "height_age6", "height_age7", "height_age8", "height_age9", "height_age10", "height_age11", 
                    "height_age12", "height_age13", "height_age14", "height_age15", "height_age16", "height_age17", "height_age18", 
                    "height_age19", "height_age20", "height_age21", "height_age22", "height_age23", "height_age24", "height_age25", "height_age26", 
                    "height_age27", "height_age28", "height_age29", "height_age30", "height_age31", "height_age32", "height_age33", "height_age34",
                    "height_age35", "height_age36", "height_age37", "height_age38", "height_age39", "height_age40", "height_age41", "height_age42", 
                    "height_age43", "height_age44", "height_age45", "height_age46", "height_age47", "height_age48", "height_age49", "height_age50", 
                    "height_age51", "height_age52", "height_age53", "height_age54", "height_age55", "height_age56", "height_age57", "height_age58", 
                    "height_age59", "height_age60", "height_age61", "height_age62", "height_age63", "height_age64", "height_age65", "height_age66", 
                    "height_age67", "height_age68", "height_age69", "height_age70", "height_age71", "height_age72", "height_age73", "height_age74", 
                    "height_age75", "height_age76", "height_age77", "height_age78", "height_age79", "height_age80", "height_age81", "height_age82", 
                    "height_age83", "height_age84", "height_age85", "height_age86", "height_age87", "height_age88", "height_age89",  "height_age90", 
                    "height_age91", "height_age92", "height_age93", "height_age94", "height_age95", "height_age96", "height_age97", "height_age98", 
                    "height_age99", "height_age100", "height_age101", "height_age102", "height_age103", "height_age104", "height_age105", "height_age106", 
                    "height_age107", "height_age108", "height_age109", "height_age110", "height_age111",  "height_age112", "height_age113", "height_age114", 
                    "height_age115", "height_age116", "height_age117", "height_age118", "height_age119", "height_age120", "height_age121", "height_age122", 
                    "height_age123", "height_age124", "height_age125", "height_age126", "height_age127", "height_age128", "height_age129", "height_age130", 
                    "height_age131", "height_age132", "height_age133", "height_age134", "height_age135", "height_age136", "height_age137", "height_age138", 
                    "height_age139", "height_age140", "height_age141", "height_age142", "height_age143", "height_age144", "height_age145", "height_age146", 
                    "height_age147", "height_age148", "height_age149", "height_age150", "height_age151", "height_age152", "height_age153", "height_age154", 
                    "height_age155", "height_age156", "height_age157", "height_age158", "height_age159", "height_age160", "height_age161", "height_age162", 
                    "height_age163", "height_age164", "height_age165", "height_age166", "height_age167", "height_age168", "height_age169", "height_age170", 
                    "height_age171", "height_age172", "height_age173", "height_age174", "height_age175", "height_age176", "height_age177",  "height_age178", 
                    "height_age179", "height_age180", "height_age181", "height_age182", "height_age183", "height_age184", "height_age185", "height_age186", 
                    "height_age187", "height_age188", "height_age189", "height_age190", "height_age191", "height_age192", "height_age193", "height_age194", 
                    "height_age195", "height_age196", "height_age197", "height_age198", "height_age199", "height_age200", "height_age201", "height_age202", 
                    "height_age203", "height_age204", "height_age205", "height_age206", "height_age207", "height_age208", "height_age209", "height_age210", 
                    "height_age211", "height_age212", "height_age213", "height_age214", "height_age215", "weight_0", "weight_1", "weight_2", "weight_3", "weight_4", 
                    "weight_5", "weight_6", "weight_7", "weight_8", "weight_9", "weight_10", "weight_11", "weight_12", "weight_13", "weight_14", "weight_15",  "weight_16", 
                    "weight_17", "weight_18", "weight_19", "weight_20", "weight_21", "weight_22",  "weight_23", "weight_24",  "weight_25", "weight_26", "weight_27", 
                    "weight_28", "weight_29", "weight_30", "weight_31", "weight_32", "weight_33", "weight_34", "weight_35", "weight_36", "weight_37", "weight_38",  "weight_39", 
                    "weight_40", "weight_41", "weight_42", "weight_43", "weight_44", "weight_45", "weight_46", "weight_47", "weight_48", "weight_49", "weight_50", "weight_51",
                    "weight_52", "weight_53", "weight_54", "weight_55", "weight_56", "weight_57", "weight_58", "weight_59", "weight_60", "weight_61", "weight_62", "weight_63",
                    "weight_64", "weight_65", "weight_66", "weight_67", "weight_68", "weight_69", "weight_70", "weight_71", "weight_72", "weight_73", "weight_74", 
                    "weight_75", "weight_76", "weight_77", "weight_78", "weight_79", "weight_80", "weight_81", "weight_82", "weight_83", "weight_84", "weight_85", "weight_86",
                    "weight_87", "weight_88", "weight_89", "weight_90", "weight_91", "weight_92", "weight_93", "weight_94", "weight_95", "weight_96", "weight_97", 
                    "weight_98", "weight_99", "weight_100", "weight_101", "weight_102",  "weight_103", "weight_104", "weight_105", "weight_106", "weight_107", "weight_108",
                    "weight_109", "weight_110", "weight_111", "weight_112", "weight_113", "weight_114", "weight_115", "weight_116", "weight_117", "weight_118", 
                    "weight_119", "weight_120", "weight_121", "weight_122", "weight_123", "weight_124", "weight_125", "weight_126", "weight_127", 
                    "weight_128", "weight_129", "weight_130", "weight_131", "weight_132", "weight_133", "weight_134", "weight_135", "weight_136", 
                    "weight_137", "weight_138", "weight_139", "weight_140", "weight_141", "weight_142", "weight_143", "weight_144", "weight_145", 
                    "weight_146", "weight_147", "weight_148", "weight_149",  "weight_150", "weight_151", "weight_152", "weight_153", "weight_154", 
                    "weight_155", "weight_156", "weight_157", "weight_158", "weight_159", "weight_160",  "weight_161", "weight_162", "weight_163", 
                    "weight_164", "weight_165", "weight_166", "weight_167", "weight_168", "weight_169", "weight_170", "weight_171", "weight_172", 
                    "weight_173",  "weight_174", "weight_175", "weight_176", "weight_177", "weight_178", "weight_179", "weight_180", "weight_181", 
                    "weight_182", "weight_183", "weight_184", "weight_185", "weight_186", "weight_187", "weight_188", "weight_189", "weight_190", 
                    "weight_191", "weight_192", "weight_193", "weight_194", "weight_195", "weight_196", "weight_197", "weight_198", "weight_199", 
                    "weight_200", "weight_201", "weight_202", "weight_203", "weight_204", "weight_205", "weight_206", "weight_207", "weight_208", 
                    "weight_209", "weight_210", "weight_211", "weight_212", "weight_213", "weight_214", "weight_215", "weight_age0", "weight_age1", 
                    "weight_age2", "weight_age3", "weight_age4", "weight_age5", "weight_age6", "weight_age7", "weight_age8", "weight_age9", "weight_age10", 
                    "weight_age11", "weight_age12", "weight_age13", "weight_age14", "weight_age15", "weight_age16", "weight_age17", "weight_age18", "weight_age19", 
                    "weight_age20", "weight_age21", "weight_age22", "weight_age23", "weight_age24", "weight_age25", "weight_age26", "weight_age27", "weight_age28", 
                    "weight_age29", "weight_age30", "weight_age31", "weight_age32", "weight_age33", "weight_age34", "weight_age35", "weight_age36", 
                    "weight_age37",  "weight_age38", "weight_age39", "weight_age40", "weight_age41", "weight_age42", "weight_age43", 
                    "weight_age44", "weight_age45", "weight_age46", "weight_age47", "weight_age48", "weight_age49", "weight_age50", 
                    "weight_age51", "weight_age52", "weight_age53", "weight_age54", "weight_age55", "weight_age56", "weight_age57", 
                    "weight_age58", "weight_age59", "weight_age60", "weight_age61", "weight_age62", "weight_age63", "weight_age64", 
                    "weight_age65", "weight_age66", "weight_age67", "weight_age68", "weight_age69", "weight_age70", "weight_age71", 
                    "weight_age72", "weight_age73", "weight_age74", "weight_age75", "weight_age76", "weight_age77", "weight_age78", 
                    "weight_age79", "weight_age80", "weight_age81", "weight_age82", "weight_age83", "weight_age84", "weight_age85", 
                    "weight_age86", "weight_age87", "weight_age88", "weight_age89", "weight_age90", "weight_age91", "weight_age92", 
                    "weight_age93", "weight_age94", "weight_age95", "weight_age96", "weight_age97", "weight_age98", "weight_age99", 
                    "weight_age100", "weight_age101", "weight_age102", "weight_age103", "weight_age104", "weight_age105",  "weight_age106", 
                    "weight_age107", "weight_age108", "weight_age109", "weight_age110", "weight_age111", "weight_age112", "weight_age113", 
                    "weight_age114", "weight_age115", "weight_age116", "weight_age117", "weight_age118", "weight_age119", "weight_age120", 
                    "weight_age121", "weight_age122", "weight_age123", "weight_age124", "weight_age125", "weight_age126", "weight_age127", 
                    "weight_age128", "weight_age129", "weight_age130", "weight_age131", "weight_age132", "weight_age133", "weight_age134", 
                    "weight_age135", "weight_age136", "weight_age137", "weight_age138", "weight_age139", "weight_age140", "weight_age141", 
                    "weight_age142", "weight_age143", "weight_age144", "weight_age145", "weight_age146", "weight_age147", "weight_age148", 
                    "weight_age149", "weight_age150", "weight_age151",  "weight_age152", "weight_age153", "weight_age154", "weight_age155", 
                    "weight_age156", "weight_age157", "weight_age158", "weight_age159", "weight_age160", "weight_age161", "weight_age162", "weight_age163", 
                    "weight_age164", "weight_age165", "weight_age166", "weight_age167", "weight_age168", "weight_age169", "weight_age170", "weight_age171", 
                    "weight_age172", "weight_age173", "weight_age174", "weight_age175", "weight_age176", "weight_age177", "weight_age178", "weight_age179", 
                    "weight_age180", "weight_age181", "weight_age182", "weight_age183", "weight_age184", "weight_age185", "weight_age186", "weight_age187", 
                    "weight_age188", "weight_age189", "weight_age190", "weight_age191", "weight_age192", "weight_age193", "weight_age194", "weight_age195", 
                    "weight_age196", "weight_age197", "weight_age198", "weight_age199", "weight_age200", "weight_age201", "weight_age202", "weight_age203", 
                    "weight_age204", "weight_age205", "weight_age206", "weight_age207", "weight_age208", "weight_age209", "weight_age210", "weight_age211", 
                    "weight_age212", "weight_age213", "weight_age214", "weight_age215", "breastfed_excl", "breastfed_any", "breastfed_ever", "solid_food", 
                    "childcare_intro", "childcare_0", "childcare_1", "childcare_2", "childcare_3", "childcarerel_0", "childcarerel_1", "childcarerel_2", "childcarerel_3", 
                    "childcareprof_0", "childcareprof_1", "childcareprof_2", "childcareprof_3", "childcarecentre_0", "childcarecentre_1", "childcarecentre_2", 
                    "childcarecentre_3", "smk_exp0", "smk_exp1", "smk_exp2", "smk_exp3", "smk_exp4", "smk_exp5", "smk_exp6", "smk_exp7", "smk_exp8", "smk_exp9", 
                    "smk_exp10", "smk_exp11", "smk_exp12", "smk_exp13", "smk_exp14", "smk_exp15", "smk_exp16", "smk_exp17", "pets_0", "pets_1", "pets_2", 
                    "pets_3", "pets_4", "pets_5", "pets_6", "pets_7", "pets_8", "pets_9", "pets_10", "pets_11", "pets_12", "pets_13", "pets_14", "pets_15", 
                    "pets_16", "pets_17", "mental_exp0", "mental_exp1", "mental_exp2", "mental_exp3", "mental_exp4", "mental_exp5", "mental_exp6", "mental_exp7", 
                    "mental_exp8", "mental_exp9", "mental_exp10", "mental_exp11", "mental_exp12", "mental_exp13", "mental_exp14", "mental_exp15",  "mental_exp16", 
                    "mental_exp17", "hhincome_0", "hhincome_1", "hhincome_2", "hhincome_3", "hhincome_4", "hhincome_5", "hhincome_6", "hhincome_7", "hhincome_8", 
                    "hhincome_9", "hhincome_10", "hhincome_11", "hhincome_12", "hhincome_13", "hhincome_14", "hhincome_15", "hhincome_16", "hhincome_17", 
                    "fam_splitup0", "fam_splitup1", "fam_splitup2", "fam_splitup3", "fam_splitup4", "fam_splitup5", "fam_splitup6",  "fam_splitup7", 
                    "fam_splitup8", "fam_splitup9", "fam_splitup10", "fam_splitup11", "fam_splitup12", "fam_splitup13", "fam_splitup14", 
                    "fam_splitup15", "fam_splitup16", "fam_splitup17", "famsize_child0", "famsize_child1", "famsize_child2", "famsize_child3", 
                    "famsize_child4", "famsize_child5", "famsize_child6", "famsize_child7", "famsize_child8", "famsize_child9", "famsize_child10", 
                    "famsize_child11", "famsize_child12", "famsize_child13", "famsize_child14", "famsize_child15", "famsize_child16", "famsize_child17", 
                    "famsize_adult0", "famsize_adult1", "famsize_adult2", "famsize_adult3", "famsize_adult4", "famsize_adult5", "famsize_adult6", "famsize_adult7", 
                    "famsize_adult8", "famsize_adult9",  "famsize_adult10", "famsize_adult11", "famsize_adult12", "famsize_adult13", "famsize_adult14",
                    "famsize_adult15", "famsize_adult16", "famsize_adult17")
  
  # Check which variables are missing in the study as compared to the full variable list (if character(0), continue, otherwise
  # check the list of variables in the original harmonized data)
  missing <- setdiff(lc_variables, names(lc_data))
  # Ammend the data with columns
  lc_data[missing] <- NA
  
  # Reorder the data set based on the variable vector above
  lc_data <- lc_data[,lc_variables]
  
  lc.reshape.core.generate.non.repeated(lc_data, upload_to_opal, output_path, file_prefix, file_version, 'non_repeated_measures')
  lc.reshape.core.generate.yearly.repeated(lc_data, upload_to_opal, output_path, file_prefix, file_version, 'yearly_repeated_measures')
  lc.reshape.core.generate.monthly.repeated(lc_data, upload_to_opal, output_path, file_prefix, file_version, 'monthly_repeated_measures')
  
  message('######################################################')
  message('  Reshaping successfully finished                     ')
  message('######################################################')
  
})

#' Generate the yearly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>%
#'   
lc.reshape.core.generate.non.repeated <- local(function(lc_data, upload_to_opal, output_path, file_prefix, file_version, file_name) {
  message("* Generating: non-repeated measures")
  
  # Create vector of positions for the non_repeated variables in the data set
  non_repeated <- c(which(names(lc_data) %in% "child_id") : which(names(lc_data) %in% "coh_country"), 
                    which(names(lc_data) %in% "cob_m") : which(names(lc_data) %in% "plac_abrup"), 
                    which(names(lc_data) %in% "cob_p") : which(names(lc_data) %in% "death_child_age"),
                    which(names(lc_data) %in% "breastfed_excl") : which(names(lc_data) %in% "childcare_intro"))
  
  # select the non-repeated measures from the full data set
  non_repeated_measures <- lc_data[,non_repeated]
  
  non_repeated_measures <- non_repeated_measures[,colSums(is.na(non_repeated_measures))<nrow(non_repeated_measures)]
  
  # add row_id again to preserve child_id
  non_repeated_measures <- data.frame(row_id = c(1:length(non_repeated_measures$child_id)), non_repeated_measures)
  
  # Write as csv   
  write_csv(non_repeated_measures, paste(output_path, '/', file_prefix, '_', file_version, '_', file_name, '.csv', sep=""), na = "")
  
  if(upload_to_opal) {
    lc.reshape.core.upload(file_prefix, file_version, file_name)
  }
  
})    

#' Generate the yearly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter
#' @importFrom data.table dcast
#' @importFrom tidyr gather spread
#' 
lc.reshape.core.generate.yearly.repeated <- local(function(lc_data, upload_to_opal, output_path, file_prefix, file_version, file_name) {
  # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- cohab_ <- cohab_0 <- famsize_adult17 <- age_years <- NULL
  
  message("* Generating: yearly-repeated measures")
  
  file_name <- 'yearly_repeated_measures'
  
  # Select only those variables, that are repeated yearly
  yearly_repeated <- c(which(names(lc_data) %in% "child_id"), 
                       which(names(lc_data) %in% "cohab_0") : which(names(lc_data) %in% "edu_m_17"), 
                       which(names(lc_data) %in% "occup_f1_0") : which(names(lc_data) %in% "edu_f2_fath17"), 
                       which(names(lc_data) %in% "childcare_0") :  which(names(lc_data) %in% "famsize_adult17")) 
  
  # Select the non-repeated measures from the full data set
  yearly_repeated_measures <- lc_data[,yearly_repeated]
  
  # First re-arrange the whole data set to long format, unspecific for variable
  long_1 <- yearly_repeated_measures %>% 
    gather(orig_var, cohab_, cohab_0:famsize_adult17, na.rm=FALSE)
  
  # Create the age_years variable with the regular expression extraction of the year
  long_1$age_years <- as.numeric(numextract(long_1$orig_var))
  
  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub('[[:digit:]]+$', '', long_1$orig_var)
  
  # Use the data.table package for spreading the data again, as tidyverse runs into memory issues 
  long_2 <- dcast(long_1, child_id + age_years ~ variable_trunc, value.var = "cohab_")
  
  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))
  
  # Arrange the variable names based on the original order
  long_yearly <- long_2[,c("row_id", "child_id", "age_years", unique(long_1$variable_trunc))]
  
  # As the data table is still too big for opal, remove those
  # rows, that have only missing values, but keep all rows at age_years=0, so
  # no child_id get's lost:
  
  # Subset of data with age_years = 0 
  zero_year <- long_yearly %>% filter(age_years %in% 0)
  
  # Subset of data with age_years > 0
  later_year <- long_yearly %>% filter(age_years > 0)
  
  # Remove all the rows that are missing only
  later_year <- later_year[rowSums(is.na(later_year[,unique(long_1$variable_trunc)])) < 
                             length(later_year[,unique(long_1$variable_trunc)]),]
  
  # Bind the 0 year and older data sets together 
  long_yearly <- rbind(zero_year,later_year)
  
  # strip fully na columns
  long_yearly <- long_yearly[,colSums(is.na(long_yearly))<nrow(long_yearly)]
  
  write_csv(long_yearly, paste(output_path, '/', file_prefix, '_', file_version, '_', file_name, '.csv', sep=""), na = "")
  
  if(upload_to_opal) {
    lc.reshape.core.upload(file_prefix, file_version, file_name)
  }
})

#' Generate the monthly repeated measures file and write it to your local workspace
#'
#' @param lc_data data frame with all the data based upon the CSV file
#' @param upload_to_opal do you want to upload to Opal (default = true)
#' @param output_path directory where the CSV files need to be stored
#' @param file_prefix the date of the generated file
#' @param file_version version of the data release (e.g. 1_0)
#' @param file_name non-repeated, monthly-repeated or yearly-repeated
#'
#' @importFrom readr write_csv
#' @importFrom dplyr %>% filter
#' @importFrom data.table dcast
#' @importFrom tidyr gather spread
#' 
lc.reshape.core.generate.monthly.repeated <- local(function(lc_data, upload_to_opal, output_path, file_prefix, file_version, file_name) {
  # workaround to avoid glpobal variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
  orig_var <- height_ <- height_0 <- weight_age215 <- age_months <- NULL
  
  message('* Generating: monthly-repeated measures')
  
  # Select only those variables with monthly repeated measures
  monthly_repeated <- c(which(names(lc_data) %in% "child_id"), 
                        which(names(lc_data) %in% "height_0") : which(names(lc_data) %in% "weight_age215"))
  
  # Select the non-repeated measures from the full data set
  monthly_repeated_measures <- lc_data[,monthly_repeated]
  
  # First re-arrange the whole data set to long format, unspecific for variable
  long_1<- monthly_repeated_measures %>% 
    gather(orig_var, height_, height_0:weight_age215, na.rm=FALSE)
  
  # Create the age_years and age_months variables with the regular expression extraction of the year
  long_1$age_years  <- as.integer(as.numeric(numextract(long_1$orig_var))/12)
  long_1$age_months <- as.numeric(numextract(long_1$orig_var))
  
  # Here we remove the year indicator from the original variable name
  long_1$variable_trunc <- gsub('[[:digit:]]+$', '', long_1$orig_var)
  
  # Use the data.table package for spreading the data again, as tidyverse ruins into memory issues 
  long_2 <- dcast(long_1, child_id + age_years + age_months ~ variable_trunc, value.var = "height_")
  
  # Create a row_id so there is a unique identifier for the rows
  long_2$row_id <- c(1:length(long_2$child_id))
  
  # Arrange the variable names based on the original order
  long_monthly <- long_2[,c("row_id", "child_id", "age_years", "age_months", unique(long_1$variable_trunc))]
  
  # As the data table is still too big for opal, remove those
  # rows, that have only missing values, but keep all rows at age_years=0, so
  # no child_id get's lost:
  
  # Subset of data with age_months = 0
  zero_monthly <- long_monthly %>%
    filter(age_months %in% 0)
  
  # Subset of data with age_months > 0
  later_monthly <- long_monthly %>%
    filter(age_months > 0)
  
  # Remove all the rows that are missing only: rowSums and is.na combined indicate if 0 or all columns are NA (4), and
  # remove the rows with rowSum values of 4
  later_monthly <- later_monthly[rowSums(is.na(later_monthly[,unique(long_1$variable_trunc)])) < 
                                   length(later_monthly[,unique(long_1$variable_trunc)]),]
  
  # Bind the 0 year and older data sets together 
  long_monthly <- rbind(zero_monthly,later_monthly)
  
  # strip completely missing columns
  long_monthly <- long_monthly[,colSums(is.na(long_monthly))<nrow(long_monthly)]
  
  write_csv(long_monthly, paste(output_path, '/', file_prefix, '_', file_version, '_', file_name, '.csv', sep=""), na = "")
  
  if(upload_to_opal) {
    lc.reshape.core.upload(file_prefix, file_version, file_name)
  }
})

#' Uploading the generated data files
#' 
#' @param file_prefix a date to prefix the file with
#' @param file_version the data release version
#' @param file_name name of the data file
#' 
#' @importFrom opalr opal.file_upload
#' 
lc.reshape.core.upload <- local(function(file_prefix, file_version, file_name) {
  upload_directory <- paste('/home/', lifecycle.globals$username, sep = '')
  file_ext <- '.csv'
  
  message(paste('* Upload: ', paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''), sep = ''))
  opal.file_upload(opal = lifecycle.globals$opal, source = paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''), destination = upload_directory)
    
  unlink(paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''))
})

#' Importing generated data files
#' 
#' @param file_prefix a date to prefix the file with
#' @param file_version the data release version
#' @param file_name name of the data file
#' 
#' @importFrom readr read_csv
#' @importFrom opalr opal.post
#' @importFrom opalr opal.projects
#' @importFrom opalr opal.tables
#' @importFrom jsonlite toJSON
#' 
lc.reshape.core.import <- local(function(file_prefix, file_version, file_name) {
  
  message('------------------------------------------------------')
  message('  Start importing data files')
  
  file_ext <- '.csv'
  
  projects <- opal.projects(lifecycle.globals$opal)
  project <- readline(paste('Which project you want to upload into: [ ', paste0(projects$name, collapse = ', '), ' ]: ', sep = ''))
  
  if(!(project %in% projects$name)) {
    stop(paste('Invalid projectname: [ ', project,' ]', sep = ''))
  }
  
  tables <- opal.tables(lifecycle.globals$opal, project)
  
  table_name <- ''
  if(file_name %in% tables$name) {
    table = tables$name 
  } 
  
  data <- read_csv(paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''))
    
  message(paste('* Import: ', paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''), sep = ''))
  opal.post(lifecycle.globals$opal, 'datasource', lifecycle.globals$project, 'table', table_name, 'variables', body=toJSON(data), contentType = 'application/x-protobuf+json')  
  
  unlink(paste(getwd(), '/', file_prefix, '_', file_version, '_', file_name, file_ext, sep = ''))
    
  message('  Succesfully imported the files')
})

