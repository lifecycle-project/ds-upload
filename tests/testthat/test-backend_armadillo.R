test_that("login", {
  login_data <- data.frame(
    server = "https://armadillo.dev.molgenis.org",
    driver = "ArmadilloDriver"
  )
  expect_error(suppressMessages(du.login(login_data)))
})