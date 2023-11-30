test_that("num extract", {
  expect_equal(du.num.extract("heightmes_41"), "41")
  expect_equal(du.num.extract("heightmes_96"), "96")
  expect_type(du.num.extract("heightmes_41"), "character")
})

test_that("extract version", {
  expect_equal(du.check.version("1_0"), TRUE)
  expect_equal(du.check.version("1_1"), TRUE)
  expect_equal(du.check.version("1_a"), FALSE)
  expect_equal(du.check.version("b_2"), FALSE)
  expect_equal(du.check.version("SomeRandom45String"), FALSE)
  expect_equal(du.check.version(11), FALSE)
  expect_type(du.check.version("1_0"), "logical")
})

test_that("get response as dataframe", {
  url <- "https://api.github.com/repositories/278172633/contents/dictionaries/core/1_0?ref=core-1_0"
  response <- du.get.response.as.dataframe(url)
  expect_type(response, "list")
  expect_equal(length(response), 10)
  expect_equal(names(response), c("name", "path", "sha", "size", "url", "html_url", "git_url", "download_url", "type", "_links"))
})

test_that("get action", {
  expect_silent(du.check.action("all"))
  expect_silent(du.check.action("reshape"))
  expect_silent(du.check.action("populate"))
  expect_error(du.check.action("some_random_action"))
  expect_error(du.check.action(1))
})

test_that("create temp workdir", {
  original_workdir <- getwd()
  expect_message(du.create.temp.workdir(), " * Create temporary workdir")
  temp_workdir <- getwd()
  suppressMessages(du.clean.temp.workdir(TRUE, c(original_workdir,temp_workdir)))
})

test_that("clean temp workdir", {
  suppressMessages(expect_message(du.clean.temp.workdir(FALSE, c(getwd(),"")), " * Be advised: you need to cleanup the temporary directories yourself now."))
})

test_that("is empty", {
  expect_type(du.is.empty(""), "logical")
  expect_equal(du.is.empty(""), TRUE)
  expect_equal(du.is.empty(" "), FALSE)
  expect_equal(du.is.empty(1), FALSE)
  expect_equal(du.is.empty(NULL), TRUE)
  expect_equal(du.is.empty(NA), NA)
  expect_error(du.is.empty(c(1,2,3)))
})
