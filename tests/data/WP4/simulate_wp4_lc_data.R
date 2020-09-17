#############################################
#
#    SIMULATE A FAKE HARMONISED WP4 DATASET
#      FOR TESTING THE RESHAPE FUNCTION
#             AHMED ELHALKEEM
#               31/10/2019
#
############################################

rm(list = ls())
library(tidyverse)

### 1. CREATE EMPTY LC_DATA WITH HARMONIZED COLUMN NAMES ---

wp4.non.repeated <- setNames(data.frame(matrix(ncol = 4, nrow = 10000)), c(
  "glucose_cord", "insulin_cord", "crp_cord", "il6_cord"
))

wp4.weekly.repeated <- setNames(data.frame(matrix(ncol = 49, nrow = 10000)), outer(c(
  "m_sbp_", "m_dbp_", "m_glucose_", "m_hdlc_", "m_ldlc_", "m_chol_", "m_triglycerides_"
), c(10, 14, 17, 25, 31, 37, 40), paste, sep = ""))

wp4.monthly.repeated <- setNames(data.frame(matrix(ncol = 252, nrow = 10000)), outer(c(
  "heightmes_", "weightmes_", "dxafm_", "dxafmage_", "dxafmmes_", "bio_", "bioage_", "biomes_",
  "dxalm_", "dxalmage_", "dxalmmes_", "sbp_", "dbp_", "sbpav_", "dbpav_", "bpage_",
  "pulse_", "pulseage_", "pulsemessit_", "chol_", "cholage_", "cholmes_",
  "hdlc_c", "hdlcage_", "hdlcmes_", "ldlc_", "ldlcage_", "ldlcmes_"
), c(3, 6, 10, 14, 25, 39, 88, 100, 130), paste, sep = ""))

lc_data <- merge(
  wp4.non.repeated,
  wp4.weekly.repeated,
  by = "row.names"
)

lc_data <- lc_data %>% select(-Row.names)

lc_data <- merge(
  lc_data,
  wp4.monthly.repeated,
  by = "row.names"
)

lc_data <- lc_data %>%
  select(-Row.names) %>%
  mutate(
    heightmes_41 = NA, weightmes_41 = NA,
    heightmes_96 = NA, weightmes_96 = NA
  )

### 2.1 REPLACE ALL WITH NORMAL VALUES ----
### 2.2 THEN REPLACE CATEGORICAL DATA WITH APPROPRIATE DISTRIBUTIONS ---

lc_data <- lc_data %>%
  mutate_all(
    funs(rnorm(n = 10000, mean = 100, sd = 5))
  ) %>%
  mutate_at(
    vars(matches("mes_")), funs(rbinom(n = 10000, size = 1, prob = 0.5))
  ) %>%
  mutate_at(
    vars(matches("heightmes_")), funs(rbinom(n = 10000, size = 2, prob = 0.5))
  ) %>%
  mutate_at(
    vars(matches("weightmes_")), funs(rbinom(n = 10000, size = 2, prob = 0.5))
  )

### 3. RANDOMLY ADD 25% MISSING DATA ---

lc_data <- as.data.frame(lapply(
  lc_data, function(cc) {
    cc[sample(
      c(TRUE, NA),
      prob = c(0.75, 0.25),
      size = length(cc),
      replace = TRUE
    )]
  }
))

### 4. ADD ROW ID AND CHILD ID ---

lc_data <- lc_data %>%
  mutate(
    row_id = row_number(),
    child_id = sample(1:10000, 10000)
  ) %>%
  select(
    row_id, child_id, everything()
  )


### 5. SAVE HARMONISED DATASET AS CSV ----

write.csv(lc_data, file = "lc_data_wp4.csv", row.names = FALSE)
