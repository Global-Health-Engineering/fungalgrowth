# Description ------------------------------------------------------------------
# R script to process uploaded raw data into a tidy, analysis-ready data frame
# Load packages ----------------------------------------------------------------
## Run the following code in console if you don't have the packages
## install.packages(c("usethis", "fs", "here", "readr", "readxl", "openxlsx"))
library(usethis)
library(fs)
library(here)
library(readr)
library(readxl)
library(openxlsx)

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
growthspeed_processed <- growthspeed_contam |>
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
faeces_processed <- faeces_bacteria |>
  rowwise() |>
  mutate(
    ecoli_concentration_mean = mean(c(ecoli_concentration_1, ecoli_concentration_2, ecoli_concentration_3), na.rm = TRUE),
    enterococcus_concentration_mean = mean(c(enterococcus_concentration_1, enterococcus_concentration_2, enterococcus_concentration_3), na.rm = TRUE),
    total_plate_count_concentration_mean = mean(c(total_plate_count_concentration_1, total_plate_count_concentration_2, total_plate_count_concentration_3), na.rm = TRUE)
  ) |>
  ungroup() |>
  select(id_faeces,
         collection_date_1,
         collection_date_2,
         weight_1,
         weight_2,
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

# Step 1: Calculate wet weights (no exclusion filter applied)
experiment_weights <- experiment |>
  mutate(
    wet_weight_0dpi = weight_0dpi - plate_empty_weight,
    wet_weight_14dpi = weight_14dpi - plate_empty_weight
  )

# Step 3: Calculate water content at 14 dpi
experiment_water <- experiment_weights |>
  mutate(
    water_content_14dpi = ((sample_weight_14dpi - foil_weight_14dpi) - (sample_dry_weight - foil_weight_14dpi)) / (sample_weight_14dpi - foil_weight_14dpi)
  )

# Step 4: Calculate bacterial concentrations at 14 dpi
experiment_bacteria <- experiment_water |>
  mutate(
    ecoli_concentration_14dpi = ecoli_counted * dilution_ecoli / bacteria_weight,
    enterococcus_concentration_14dpi = enterococcus_counted * dilution_enterococcus / bacteria_weight,
    total_plate_count_concentration_14dpi = pc_counted * dilution_pc / bacteria_weight
  )

# Step 5: Calculate dry weight at 14 dpi
experiment_processed <- experiment_bacteria |>
  mutate(
    dry_weight_14dpi = wet_weight_14dpi * (1 - water_content_14dpi)
  ) |>
  select(
    id_treatment, id_inoc, id_faeces,
    wet_weight_0dpi, wet_weight_14dpi, dry_weight_14dpi,
    ecoli_concentration_14dpi, enterococcus_concentration_14dpi, total_plate_count_concentration_14dpi,
    ph_14dpi
  )

cat("=== Experiment processed ===\n")
glimpse(experiment_processed)
cat("\n")

# Process inoculum data ----
inoculum_processed <- inoculum |>
  select(id_inoc, species)

# Join all processed tables ----
# Step 1: Join experiment with faeces
joined_faeces <- experiment_processed |>
  left_join(faeces_processed, by = "id_faeces")

cat("=== After joining faeces ===\n")
cat("Rows:", nrow(joined_faeces), "\n")
cat("Faeces IDs present:", paste(sort(unique(joined_faeces$id_faeces)), collapse = ", "), "\n\n")

# Step 2: Join with inoculum
joined_inoculum <- joined_faeces |>
  left_join(inoculum_processed, by = "id_inoc")

# Step 3: Join with growthspeed
cat("=== Before joining growthspeed ===\n")
cat("id_treatment range in experiment:",
    min(joined_inoculum$id_treatment, na.rm = TRUE), "-",
    max(joined_inoculum$id_treatment, na.rm = TRUE), "\n")
cat("id_treatment type in experiment:", class(joined_inoculum$id_treatment), "\n")

joined_growthspeed <- joined_inoculum |>
  left_join(growthspeed_processed, by = "id_treatment")

cat("\n=== After joining growthspeed ===\n")
cat("Rows:", nrow(joined_growthspeed), "\n")
cat("Columns:", ncol(joined_growthspeed), "\n")

# Check if area_size columns have data
area_cols_joined <- names(joined_growthspeed)[grepl("^area_size_", names(joined_growthspeed))]
cat("Area size columns in joined data:", paste(area_cols_joined, collapse = ", "), "\n")

if (length(area_cols_joined) > 0) {
  cat("Non-NA values in first area_size column:",
      sum(!is.na(joined_growthspeed[[area_cols_joined[1]]])), "of", nrow(joined_growthspeed), "\n")
}

# Check matching id_treatments
matching_ids <- intersect(joined_inoculum$id_treatment, growthspeed_processed$id_treatment)
cat("Matching id_treatment values:", length(matching_ids), "\n\n")

# Calculate derived variables ----
# Step 1: Calculate dry weight at 0 dpi
final_weights <- joined_growthspeed |>
  mutate(
    dry_weight_0dpi = wet_weight_0dpi * (1 - water_content_0dpi_mean)
  )

# Step 2: Calculate log changes for bacteria
final_data <- final_weights |>
  mutate(
    ecoli_log_change = log10(ecoli_concentration_14dpi + 1) - log10(ecoli_concentration_0dpi_mean + 1),
    enterococcus_log_change = log10(enterococcus_concentration_14dpi + 1) - log10(enterococcus_concentration_0dpi_mean + 1),
    total_plate_count_log_change = log10(total_plate_count_concentration_14dpi + 1) - log10(total_plate_count_concentration_0dpi_mean + 1)
  )

# Step 3: Filter out "new species" and "Coprinopsis F40 +"
final_data <- final_data |>
  filter(species != "new species") |>
  filter(species != "Coprinopsis F40 +")

cat("=== Final data after filtering 'new species' and 'Coprinopsis F40 +' ===\n")
cat("Rows:", nrow(final_data), "\n")
cat("Species:", paste(sort(unique(final_data$species)), collapse = ", "), "\n\n")

# Save processed data ----
dir.create(here("data", "processed"), showWarnings = FALSE, recursive = TRUE)
write_csv(final_data, here("data", "processed", "fungal_growth_assay_processed.csv"))

cat("=== Saved to data/processed/fungal_growth_assay_processed.csv ===\n")
cat("Final dimensions:", nrow(final_data), "rows x", ncol(final_data), "columns\n")

# Session info ----
cat("\n=== Session Info ===\n")
sessionInfo()



# Export Data ------------------------------------------------------------------
fungalgrowth <- final_data
usethis::use_data(fungalgrowth, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(fungalgrowth,
                 here::here("inst", "extdata", paste0("fungalgrowth", ".csv")))
openxlsx::write.xlsx(fungalgrowth,
                     here::here("inst", "extdata", paste0("fungalgrowth", ".xlsx")))
fs::file_copy(here::here("data-raw", "dictionary.csv"),
              here::here("inst", "extdata", "dictionary.csv"),
              overwrite = TRUE)
