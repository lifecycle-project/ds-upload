test_that("login", {
  expect_error(suppressMessages(du.login()))
  expect_error(suppressMessages(du.login(login_data = data.frame(server = "https://armadillo.dev.molgenis.org", driver = "ArmadilloDriver"))))
  expect_error(suppressMessages(du.login(login_data = data.frame(server = "https://opal.org", driver = "OpalDriver", password = "admin"))))
})

test_that("check session", {
  expect_silent(du.check.session(upload = FALSE))
  expect_error(du.check.session(upload = TRUE))
})
