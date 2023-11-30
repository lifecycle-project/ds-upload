test_that("read source file", {
  expect_error(du.read.source.file(test_path("data/demo","demo-athlete-outcome.csv"),"TXT"))
  expect_type(du.read.source.file(test_path("data/demo","demo-athlete-outcome.csv"),"CSV"), "list")
  expect_length(du.read.source.file(test_path("data/demo","demo-athlete-outcome.csv"),"CSV"), 10)
  expect_type(du.read.source.file(test_path("data/WP3","subtask314.sas7bdat"),"SAS"), "list")
  expect_length(du.read.source.file(test_path("data/WP3","subtask314.sas7bdat"),"SAS"), 897)
  # source(test_path("data/WP4","simulate_wp4_lc_data.R"))
  expect_type(du.read.source.file(test_path("data/WP5","random_generated_dataset_WP5_GENR_dict_1_0.sav"),"SPSS"), "list")
  expect_length(du.read.source.file(test_path("data/WP5","random_generated_dataset_WP5_GENR_dict_1_0.sav"),"SPSS"), 56)
})

test_that("data frame remove all na rows", {
  expect_type(du.data.frame.remove.all.na.rows(
    du.read.source.file(test_path("data/WP5","random_generated_dataset_WP5_GENR_dict_1_0.sav"),"SPSS")
  ), "list")
  expect_length(du.data.frame.remove.all.na.rows(
    du.read.source.file(test_path("data/WP5","random_generated_dataset_WP5_GENR_dict_1_0.sav"),"SPSS")
  ), 55)
  # Note that du.data.frame.remove.all.na.rows() will remove the first column no matter what!!
  expect_equal(du.data.frame.remove.all.na.rows(data.frame(column_a = c(1,2,NA,4,5),column_b = c(5,4,NA,2,1))),c(5,4,2,1))
  expect_s3_class(du.data.frame.remove.all.na.rows(data.frame(column_a = c(1,2,NA,4,5))), "data.frame") # return empty dataframe
})

test_that("matched columns", {
  expect_equal(
    du.match.columns(
      colnames(du.read.source.file(test_path("data/demo","demo-athlete-outcome.csv"),"CSV")),
      c("mother_id","c_bpa_raw_")
    ),
    c("mother_id","c_bpa_raw_0","c_bpa_raw_1","c_bpa_raw_3"))
})

                 