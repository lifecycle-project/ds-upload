


filename <- "core/2_1_trimester_rep.xlsx"

fullDict <- getFullDict(filename)
fullDict





#' Get the full dictionary with mapped categories
#'
#'
#' @importFrom readxl read_xlsx excel_sheets
#' @importFrom dplyr %>% nest_join mutate rename bind_rows
#' @importFrom tibble as_tibble
#'
getFullDict <- function(filename) {
    vars <- read_xlsx(path = filename, sheet = 1) %>% as_tibble()
    if (length(excel_sheets(filename)) == 2) {
      cats <- read_xlsx(path = filename, sheet = 2) %>% as_tibble()
      cats <- cats %>%
        rename(value = name, name = variable) %>%
        mutate(name = as.character(name), label = as.character(label))
      vars <- nest_join(vars, cats, by = "name")
    } 
    vars %>% bind_rows()
}

