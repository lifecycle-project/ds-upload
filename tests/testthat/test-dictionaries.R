test_that("dict retrieve tables", {
  expect_message(du.dict.retrieve.tables(
    api_url = "https://api.github.com/repos/lifecycle-project/ds-dictionaries/contents/",
    dict_name = "core",
    dict_version = "1_0",
    data_version = "1_0"
  ), " * Check released dictionaries")
})

test_that("populate dict versions", {
  expect_invisible(du.populate.dict.versions())
})
