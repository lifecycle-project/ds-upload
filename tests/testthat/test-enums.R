test_that("cohorts", {
  x <- list(
    ABCD = "abcd", ALSPAC = "alspac", AOF = "aof", BIB = "bib", BISC = "bisc", 
    CHILD = "child", CHOP = "chop", DFBC = "dfbc", DNBC = "dnbc", EDEN = "eden", 
    ELFE = "elfe", ELSPAC = "elspac", ENVIRONAGE = "environage", 
    GECKO = "gecko", GENESIS = "genesis", GENR = "genr", GENRNEXT = "genrnext", 
    GENXXI = "genxxi", HBCS = "hbcs", HGS = "hgs", INMA = "inma", 
    ISGLOBAL = "isglobal", KANC = "kanc", MOBA = "moba", NBFC66 = "nfbc66", 
    NBFC86 = "nfbc86", NINFEA = "ninfea", PCL = "pcl", PELAGIE = "pelagie", 
    RAINE = "raine", RECETOX = "recetox", RHEA = "rhea", SEPAGES = "sepages", 
    SWS = "sws", TNG = "tng"
  )
  expect_equal(du.enum.cohorts(), x)
  expect_equal(typeof(du.enum.cohorts()), "list")
  expect_length(du.enum.cohorts(), 35)
})

test_that("table types", {
  x <- list(NONREP = "non_rep", WEEKLY = "weekly_rep", MONTHLY = "monthly_rep", TRIMESTER = "trimester_rep", YEARLY = "yearly_rep")
  expect_equal(du.enum.table.types(), x)
  expect_equal(typeof(du.enum.table.types()), "list")
  expect_length(du.enum.table.types(), 5)
})

test_that("input format", {
  x <- list(CSV = "CSV", STATA = "STATA", SPSS = "SPSS", SAS = "SAS", R = "R")
  expect_equal(du.enum.input.format(), x)
  expect_equal(typeof(du.enum.input.format()), "list")
  expect_length(du.enum.input.format(), 5)
})

test_that("action", {
  x <- list(ALL = "all", RESHAPE = "reshape", POPULATE = "populate")
  expect_equal(du.enum.action(), x)
  expect_equal(typeof(du.enum.action()), "list")
  expect_length(du.enum.action(), 3)
})

test_that("dict kind", {
  x <- list(CORE = "core", CHEMICALS = "chemicals_ath", OUTCOME = "outcome", BETA = "beta", OUTCOME_ATH = "outcome_ath")
  expect_equal(du.enum.dict.kind(), x)
  expect_equal(typeof(du.enum.dict.kind()), "list")
  expect_length(du.enum.dict.kind(), 5)
})

test_that("backends", {
  x <- list(OPAL = "OpalDriver", ARMADILLO = "ArmadilloDriver")
  expect_equal(du.enum.backends(), x)
  expect_equal(typeof(du.enum.backends()), "list")
  expect_length(du.enum.backends(), 2)
})

test_that("run mode", {
  x <- list(NORMAL = "normal", NON_INTERACTIVE = "non_interactive", TEST = "test")
  expect_equal(du.enum.run.mode(), x)
  expect_equal(typeof(du.enum.run.mode()), "list")
  expect_length(du.enum.run.mode(), 3)
})