test_that("dict download", {
  expect_error(supressWarnings(du.dict.download()))
})

test_that("dict retrieve tables", {
  expect_message(du.dict.retrieve.tables(
    api_url = "https://api.github.com/repos/lifecycle-project/ds-dictionaries/contents/",
    dict_name = "core",
    dict_version = "1_0",
    data_version = "1_0"
  ), " * Check released dictionaries")
  expect_error(du.dict.retrieve.tables())
})

test_that("populate dict versions", {
  expect_invisible(du.populate.dict.versions())
  expect_in(names(du.populate.dict.versions()),list("chemicals_ath","core","methyl","outcome_ath","outcome","urban_ath" ))
})

test_that("retrieve dictionaries", {
  expect_error(du.retrieve.dictionaries())
})

test_that("retrieve full dict", {
  expect_error(du.retrieve.full.dict())
})
