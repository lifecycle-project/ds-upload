


filename <- "core/2_1_non_rep.xlsx"

fullDict <- getFullDict(filename)


require(magrittr)

trimester %<>% as_tibble()
nonrep %<>% as_tibble()

nonrep
fact.vars <- fullDict %>% rowwise() %>% filter(nrow(cats) > 0)
dbl.vars <- fullDict %>% filter(valueType == "decimal") %>% pull(name)
int.vars <- fullDict %>% filter(valueType == "integer") %>% pull(name)
char.vars <- fullDict %>% filter(valueType == "text") %>% pull(name)

fact.vars

out <- nonrep %>% 
  mutate_at(vars(any_of(dbl.vars)), as.numeric) %>% 
  mutate_at(vars(any_of(int.vars)), as.integer) %>% 
  mutate_at(vars(any_of(char.vars)), as.character)
  #mutate_at(vars(any_of(fact.vars)), )
out



for(i in range(1, nrow(fact.vars))) {
  try(
    out %<>% mutate_at(c(fact.vars$name[[i]]), ~factor(., levels = fact.vars$cats[[i]]$value))
  )
}

which(out$cohort_id == 106)

nonrep

country <- nonrep$coh_country
t <- tibble(country = c(36, 208, 36, 36))

?factor

test <- factor(x = t$country, levels = c(36, 208))

levels(test)
dput(test)

which(test == 36)

class(test)


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

