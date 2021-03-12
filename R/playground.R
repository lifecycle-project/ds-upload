library(magrittr)
library(tibble)
library(readxl)

fullDict <- du.retrieve.full.dict("2_1_non_rep.xlsx", "core")

trimester %<>% as_tibble()
nonrep %<>% as_tibble()


out <- nonrep
out <- du.add.metadata(out, fullDict)
dput(out$cohort_id)
