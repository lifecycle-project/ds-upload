#' Cohorts participating in the cohort network
#'
#' @keywords internal
du.enum.cohorts <- function() {
  list(
    DNBC = "dnbc", GECKO = "gecko", ALSPAC = "alspac", GENR = "genr", MOBA = "moba", SWS = "sws", BIB = "bib", CHOP = "chop", ELFE = "elfe",
    EDEN = "eden", NINFEA = "ninfea", HBCS = "hbcs", INMA = "inma", ISGLOBAL = "isglobal", NBFC66 = "nfbc66", NBFC86 = "nfbc86", RAINE = "raine", RHEA = "rhea",
    ABCD = "abcd"
  )
}

#' Supported table types
#'
#' @keywords internal
du.enum.table.types <- function() {
  list(NONREP = "non_rep", MONTHLY = "monthly_rep", YEARLY = "yearly_rep", WEEKLY = "weekly_rep", TRIMESTER = "trimester")
}

#' Supported input formats
#'
#' @keywords internal
du.enum.input.format <- function() {
  list(CSV = "CSV", STATA = "STATA", SPSS = "SPSS", SAS = "SAS", R = "R")
}

du.enum.action <- function() {
  list(ALL = "all", RESHAPE = "reshape", POPULATE = "populate")
}

du.enum.dict.kind <- function() {
  list(CORE = "core", OUTCOME = "outcome", BETA = "beta")
}
