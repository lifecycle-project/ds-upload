#' Cohorts participating in the cohort network
#'
#' @noRd
du.enum.cohorts <- function() {
  list(
    ABCD = "abcd", ALSPAC = "alspac", AOF = "aof", BIB = "bib", BISC = "bisc", 
    CHILD = "child", CHOP = "chop", DNBC = "dnbc", EDEN = "eden", ELFE = "elfe", 
    ELSPAC = "elspac", ENVIRONAGE = "environage", GECKO = "gecko", 
    GENESIS = "genesis", GENR = "genr", GENRNEXT = "genrnext", 
    GENXXI = "genxxi", HBCS = "hbcs", HGS = "hgs", INMA = "inma", 
    ISGLOBAL = "isglobal", KANC = "kanc", MOBA = "moba", NBFC66 = "nfbc66", 
    NBFC86 = "nfbc86", NINFEA = "ninfea", PELAGIE = "pelagie", RAINE = "raine", 
    RECETOX = "recetox", RHEA = "rhea", SEPAGES = "sepages", SWS = "sws", 
    TNG = "tng"
  )
}

#' Supported table types
#'
#' @noRd
du.enum.table.types <- function() {
  list(NONREP = "non_rep", WEEKLY = "weekly_rep", MONTHLY = "monthly_rep", TRIMESTER = "trimester_rep", YEARLY = "yearly_rep")
}

#' Supported input formats
#'
#' @noRd
du.enum.input.format <- function() {
  list(CSV = "CSV", STATA = "STATA", SPSS = "SPSS", SAS = "SAS", R = "R")
}

#' Actions that can be performed
#'
#' @noRd
du.enum.action <- function() {
  list(ALL = "all", RESHAPE = "reshape", POPULATE = "populate")
}

#' Dictionary kinds
#'
#' @noRd
du.enum.dict.kind <- function() {
  list(CORE = "core", CHEMICALS = "chemicals_ath", OUTCOME = "outcome", BETA = "beta", OUTCOME_ATH = "outcome_ath")
}

#' Projects that are containing dictionaries. Repositories containing these dictionaries should be:
#'
#' - ds-dictionaries
#' - ds-beta-dictionaries
#'
#' @noRd
du.enum.projects <- function() {
  list(LIFECYCLE = "lifecycle-project")
}

#' Possible DataSHIELD backends
#'
#' @noRd
du.enum.backends <- function() {
  list(OPAL = "OpalDriver", ARMADILLO = "ArmadilloDriver")
}

#' Run modes in uploading data
#'
#' @noRd
du.enum.run.mode <- function() {
  list(NORMAL = "normal", NON_INTERACTIVE = "non_interactive", TEST = "test")
}
