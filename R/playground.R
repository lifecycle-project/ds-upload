library(magrittr)
library(tibble)
library(readxl)

fullDict <- du.retrieve.full.dict("2_1_non_rep.xlsx", "core")

trimester %<>% as_tibble()
nonrep %<>% as_tibble()

du.set.datatype <- function(column, valueType, label, cats) {
  if (nrow(cats) > 0) {
    column <- factor(column, levels = cats$value)
    attr(column, "labels") <- setNames(as.character(cats$value), cats$label)
  }
  else if (valueType == "decimal") {
    column <- as.numeric(column)
  }
  else if (valueType == "integer") {
    column <- as.integer(column)
  }
  else if (valueType == "text") {
    column <- as.character(column)
  }
  attr(column, "label") <- label
  return(column)
}
out <- nonrep
for (i in 1:nrow(fullDict)) {
  try(
    out <- mutate_at(
      out, c(fullDict$name[[i]]),
      ~ du.set.datatype(
        .,
        fullDict$valueType[[i]],
        fullDict$label[[i]],
        fullDict$cats[[i]]
      )
    ),
    silent = TRUE
  )
}
out
dput(out$cohort_id)
