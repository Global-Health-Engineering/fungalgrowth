# Description ------------------------------------------------------------------
# R script to process uploaded raw data into a tidy, analysis-ready data frame
# Load packages ----------------------------------------------------------------
## Run the following code in console if you don't have the packages
## install.packages(c("usethis", "fs", "here", "readr", "readxl", "openxlsx"))

# Load packages ----

library(tidyverse)
library(here)

# Note: Run this script to process the raw data and create the processed dataset

# Load data ----

experiment <- read_csv(
  here("data-raw", "experiment_2_2.csv"),
  show_col_types = FALSE
)

faeces <- read_csv(
  here("data-raw", "faeces_2_2.csv"),
  show_col_types = FALSE
)

inoculum <- read_csv(
  here("data-raw", "inoculum_2_2.csv"),
  show_col_types = FALSE
)

growthspeed <- read_csv(
  here("data-raw", "growthspeed_2_2.csv"),
  show_col_types = FALSE
)

# Process growthspeed data ----

# Fix data entry error on 2025-12-09:
# Treatment 53 is missing its 12/9 measurement; treatment 54 has two entries
# on that date. The FIRST (in file order) actually belongs to treatment 53.
# Treatment 58 is missint mesurements on dpi 0, which all are 0.
new_row_58 <- growthspeed |>
  filter(id_treatment == 58, date == "11/26/25") |>
  mutate(date = "11/25/25")

growthspeed_corrected <- growthspeed |>
  bind_rows(new_row_58) |>
  mutate(
    .is_target = id_treatment == 54 & date == "12/9/25",
    id_treatment = if_else(
      .is_target & cumsum(.is_target) == 1,
      53,
      id_treatment
    )
  ) |>
  select(-.is_target)

# Claculate dpi from treatment start date
growthspeed_dpi <- growthspeed_corrected |>
  mutate(date = mdy(date)) |>
  left_join(experiment |>
              mutate(starting_date = mdy(starting_date)) |>
              select(id_treatment, starting_date), by = "id_treatment") |>
  mutate(dpi = as.integer(date - starting_date)) |>
  arrange(id_treatment, date)

# Calculate total contamination area per row
growthspeed_contam <- growthspeed_dpi |>
  rowwise() |>
  mutate(
    total_contamination_area = sum(
      replace_na(as.numeric(c_across(starts_with("contamination_area_"))), 0))
  ) |>
  ungroup()

# Growthspeed processed
fungal_growth <- growthspeed_contam |>
  filter(!dpi == 0) |>
  select(id_treatment,
         date,
         dpi,
         area_size,
         nr_contaminations,
         total_contamination_area,
         reproductive_structures,
         growth_description)

# Process faeces data ----

# Calculate water content for each replicate
faeces_water <- faeces |>
  mutate(
    water_content_1 = ((weight_wet_1 - foil_weight_1) - (dry_weight_1 - foil_weight_1)) / (weight_wet_1 - foil_weight_1),
    water_content_2 = ((weight_wet_2 - foil_weight_2) - (dry_weight_2 - foil_weight_2)) / (weight_wet_2 - foil_weight_2),
    water_content_3 = ((weight_wet_3 - foil_weight_3) - (dry_weight_3 - foil_weight_3)) / (weight_wet_3 - foil_weight_3)
  )

# Calculate mean water content
faeces_water_mean <- faeces_water |>
  rowwise() |>
  mutate(
    water_content_mean = mean(c(water_content_1, water_content_2, water_content_3), na.rm = TRUE)
  ) |>
  ungroup()

# Calculate bacterial concentrations for each replicate
faeces_bacteria <- faeces_water_mean |>
  mutate(
    ecoli_concentration_1 = e_coli_counted_1 * dilution_factor_ecoli / sample_weight_1,
    ecoli_concentration_2 = e_coli_counted_2 * dilution_factor_ecoli / sample_weight_2,
    ecoli_concentration_3 = e_coli_counted_3 * dilution_factor_ecoli / sample_weight_3,
    enterococcus_concentration_1 = enterococcus_counted_1 * dilution_factor_enterococcus / sample_weight_1,
    enterococcus_concentration_2 = enterococcus_counted_2 * dilution_factor_enterococcus / sample_weight_2,
    enterococcus_concentration_3 = enterococcus_counted_3 * dilution_factor_enterococcus / sample_weight_3,
    total_plate_count_concentration_1 = total_plate_count_1 * dilution_factor_platecount / sample_weight_1,
    total_plate_count_concentration_2 = total_plate_count_2 * dilution_factor_platecount / sample_weight_2,
    total_plate_count_concentration_3 = total_plate_count_3 * dilution_factor_platecount / sample_weight_3
  )

# Calculate mean bacterial concentrations
faecal_measurements <- faeces_bacteria |>
  rowwise() |>
  mutate(
    ecoli_concentration_mean = mean(c(ecoli_concentration_1, ecoli_concentration_2, ecoli_concentration_3), na.rm = TRUE),
    enterococcus_concentration_mean = mean(c(enterococcus_concentration_1, enterococcus_concentration_2, enterococcus_concentration_3), na.rm = TRUE),
    total_plate_count_concentration_mean = mean(c(total_plate_count_concentration_1, total_plate_count_concentration_2, total_plate_count_concentration_3), na.rm = TRUE)
  ) |>
  ungroup() |>
  select(id_faeces,
         weight_total,
         weight_additive,
         additive,
         additive_ratio,
         ph,
         water_content_mean,
         ecoli_concentration_mean,
         enterococcus_concentration_mean,
         total_plate_count_concentration_mean)

# Process experiment data ----

# Calculate wet weights
experiment_processed <- experiment |>
  mutate(
    wet_weight_0dpi = weight_0dpi - plate_empty_weight,
    wet_weight_14dpi = weight_14dpi - plate_empty_weight,
    water_content_14dpi = ((sample_weight_14dpi - foil_weight_14dpi) -
                             (sample_dry_weight - foil_weight_14dpi)) /
      (sample_weight_14dpi - foil_weight_14dpi),
    ecoli_concentration_14dpi = ecoli_counted * dilution_ecoli / bacteria_weight,
    enterococcus_concentration_14dpi = enterococcus_counted * dilution_enterococcus /
      bacteria_weight,
    total_plate_count_concentration_14dpi = pc_counted * dilution_pc /
      bacteria_weight,
    dry_weight_14dpi = wet_weight_14dpi * (1 - water_content_14dpi)
  ) |>
  select(
    id_treatment,
    id_inoc,
    id_faeces,
    wet_weight_0dpi,
    wet_weight_14dpi,
    dry_weight_14dpi,
    ecoli_concentration_14dpi,
    enterococcus_concentration_14dpi,
    total_plate_count_concentration_14dpi,
    ph_14dpi
  )

experiment_setup <- experiment_processed |>
  select(id_treatment,
         id_inoc,
         id_faeces,
         wet_weight = wet_weight_0dpi)

experiment_endpoint <- experiment_processed |>
  select(-id_inoc,
         -id_faeces,
         -wet_weight_0dpi) |>
  rename_with(~ sub("_14dpi$", "", .x), ends_with("_14dpi"))

# Process inoculum data ----

inoculum_species <- inoculum |>
  select(id_inoc, species)

# Export Data ----

usethis::use_data(fungal_growth, overwrite = TRUE)
usethis::use_data(faecal_measurements, overwrite = TRUE)
usethis::use_data(experiment_setup, overwrite = TRUE)
usethis::use_data(experiment_endpoint, overwrite = TRUE)
usethis::use_data(inoculum_species, overwrite = TRUE)

fs::dir_create(here::here("inst", "extdata"))

readr::write_csv(fungal_growth,
                 here::here("inst",
                            "extdata",
                            paste0("fungal_growth", ".csv")))
openxlsx::write.xlsx(fungal_growth,
                     here::here("inst",
                                "extdata",
                                paste0("fungal_growth", ".xlsx")))

readr::write_csv(fungal_growth,
                 here::here("inst",
                            "extdata",
                            paste0("faecal_measurements", ".csv")))
openxlsx::write.xlsx(fungal_growth,
                     here::here("inst",
                                "extdata",
                                paste0("faecal_measurements", ".xlsx")))

readr::write_csv(fungal_growth,
                 here::here("inst",
                            "extdata",
                            paste0("experiment_setup", ".csv")))
openxlsx::write.xlsx(fungal_growth,
                     here::here("inst",
                                "extdata",
                                paste0("experiment_setup", ".xlsx")))

readr::write_csv(fungal_growth,
                 here::here("inst",
                            "extdata",
                            paste0("experiment_endpoint", ".csv")))
openxlsx::write.xlsx(fungal_growth,
                     here::here("inst",
                                "extdata",
                                paste0("experiment_endpoint", ".xlsx")))

readr::write_csv(fungal_growth,
                 here::here("inst",
                            "extdata",
                            paste0("inoculum_species", ".csv")))
openxlsx::write.xlsx(fungal_growth,
                     here::here("inst",
                                "extdata",
                                paste0("inoculum_species", ".xlsx")))

fs::file_copy(here::here("data-raw", "dictionary.csv"),
              here::here("inst", "extdata", "dictionary.csv"),
              overwrite = TRUE)
