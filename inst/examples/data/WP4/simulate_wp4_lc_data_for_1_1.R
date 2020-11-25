
########################################################
#                                                      #
#  SIMULATE A FAKE HARMONISED WP4 DATASET FOR TESTING  #
#          BASED ON WP4 DATA DICTIONARY 1_1            #
#                 AHMED ELHALKEEM                      #
#                   23/04/2020                         #
#                                                      #
########################################################

rm(list = ls())
install.packages("tidyverse")
library(tidyverse)
getwd()

### 1. CREATE EMPTY LC_DATA WITH HARMONIZED COLUMN NAMES ---

wp4_non_rep_1_1 <- setNames(data.frame(matrix(ncol = 4, nrow = 10000)), c(
  "chol_cord", "hdlc_cord", "ldlc_cord", "triglycerides_cord"
))

wp4_weekly_rep_1_1 <- setNames(data.frame(matrix(ncol = 14, nrow = 10000)), outer(c(
  "m_sbp_", "m_dbp_"
), c(10, 14, 17, 25, 31, 37, 40), paste, sep = ""))

wp4_monthly_rep_1_1 <- setNames(data.frame(matrix(ncol = 252, nrow = 10000)), outer(c(
  "heightmes_", "weightmes_", "dxafm_", "dxafmage_", "dxafmmes_", "bio_", "bioage_", "biomes_",
  "dxalm_", "dxalmage_", "dxalmmes_", "sbp_", "dbp_", "sbpav_", "dbpav_", "bpage_",
  "pulse_", "pulseage_", "pulsemessit_", "chol_", "cholage_", "cholmes_",
  "hdlc_c", "hdlcage_", "hdlcmes_", "ldlc_", "ldlcage_", "ldlcmes_"
), c(3, 6, 10, 14, 25, 39, 88, 100, 130), paste, sep = ""))

fake_wp4_dataset_1_1 <- merge(
  wp4_non_rep_1_1,
  wp4_weekly_rep_1_1,
  by = "row.names"
)

fake_wp4_dataset_1_1 <- fake_wp4_dataset_1_1 %>% select(-Row.names)

fake_wp4_dataset_1_1 <- merge(
  fake_wp4_dataset_1_1,
  wp4_monthly_rep_1_1,
  by = "row.names"
)

fake_wp4_dataset_1_1 <- fake_wp4_dataset_1_1 %>%
  select(-Row.names) %>%
  mutate(
    heightmes_41 = NA, weightmes_41 = NA,
    heightmes_96 = NA, weightmes_96 = NA
  )

### 2.1 REPLACE ALL WITH NORMAL VALUES ----
### 2.2 THEN REPLACE CATEGORICAL DATA WITH APPROPRIATE DISTRIBUTIONS ---

fake_wp4_dataset_1_1 <- fake_wp4_dataset_1_1 %>%
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

fake_wp4_dataset_1_1 <- as.data.frame(lapply(
  fake_wp4_dataset_1_1, function(cc) {
    cc[sample(
      c(TRUE, NA),
      prob = c(0.75, 0.25),
      size = length(cc),
      replace = TRUE
    )]
  }
))

### 4. ADD ROW ID AND CHILD ID ---

fake_wp4_dataset_1_1 <- fake_wp4_dataset_1_1 %>%
  mutate(
    row_id = row_number(), child_id = sample(1:10000, 10000)
  ) %>%
  select(
    row_id, child_id, everything()
  )

fake_wp4_dataset_1_1$child_id <- as.character(fake_wp4_dataset_1_1$child_id)
rm(wp4_non_rep_1_1, wp4_weekly_rep_1_1, wp4_monthly_rep_1_1)

### 5. SAVE HARMONISED DATASET AS CSV ----
# NOTE WHEN YOU SAVE AS CSV CHILD_ID SAVED AS NUMERIC NOT CHARACTER

write.csv(fake_wp4_dataset_1_1, file = "fake_harm_wp4_dataset_for_1_1.csv", row.names = FALSE)
