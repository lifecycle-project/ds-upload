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