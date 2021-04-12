#' Cohorts participating in the cohort network
#'
#' @noRd
du.enum.cohorts <- function() {
  list(
    DNBC = "dnbc", GECKO = "gecko", ALSPAC = "alspac", GENR = "genr", MOBA = "moba", SWS = "sws", BIB = "bib", CHOP = "chop", ELFE = "elfe",
    EDEN = "eden", NINFEA = "ninfea", HBCS = "hbcs", INMA = "inma", ISGLOBAL = "isglobal", NBFC66 = "nfbc66", NBFC86 = "nfbc86", RAINE = "raine", RHEA = "rhea",
    ABCD = "abcd", BISC = "bisc", ENVIRONAGE = "environage", KANC = "kanc", PELAGIE = "pelagie", SEPAGES = "sepages", TNG = "tng", HGS = "hgs", RECETOX = "recetox", 
    GENXXI = "genxxi"
  )
}

#' Supported table types
#'
#' @noRd
du.enum.table.types <- function() {
  list(NONREP = "non_rep", MONTHLY = "monthly_rep", YEARLY = "yearly_rep", WEEKLY = "weekly_rep", TRIMESTER = "trimester", METHYL = "methyl", ALL = "all")
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
  list(CORE = "core", OUTCOME = "outcome", BETA = "beta")
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
