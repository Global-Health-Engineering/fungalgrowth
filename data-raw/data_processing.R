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
  locale = locale(encoding = "UTF-8"),
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

# Verify data loaded ----
cat("=== Data loaded ===\n")
cat("experiment:", nrow(experiment), "rows\n")
cat("faeces:", nrow(faeces), "rows\n")
cat("inoculum:", nrow(inoculum), "rows\n")
cat("growthspeed:", nrow(growthspeed), "rows\n\n")

# Process growthspeed data ----
# Step 1: Parse dates
growthspeed_dated <- growthspeed |>
  mutate(date = mdy(date))

# Step 2: Calculate DPI (days post inoculation) from first date per treatment
growthspeed_dpi <- growthspeed_dated |>
  group_by(id_treatment) |>
  mutate(first_date = min(date, na.rm = TRUE)) |>
  ungroup() |>
  mutate(dpi = as.integer(date - first_date))

cat("=== DPI values in growthspeed ===\n")
print(table(growthspeed_dpi$dpi))
cat("\n")

# Step 3: Calculate total contamination area per row
growthspeed_contam <- growthspeed_dpi |>
  mutate(
    total_contamination_area = rowSums(
      across(starts_with("contamination_area_"), ~replace_na(as.numeric(.), 0)),
      na.rm = TRUE
    )
  )

# Step 4: Pivot area_size to wide format (one column per DPI)
# First check for NA dpi values
cat("NA dpi values:", sum(is.na(growthspeed_contam$dpi)), "\n")
cat("NA id_treatment values:", sum(is.na(growthspeed_contam$id_treatment)), "\n")

# Check for duplicates (same id_treatment + dpi combination)
duplicates <- growthspeed_contam |>
  filter(!is.na(dpi), !is.na(id_treatment)) |>
  group_by(id_treatment, dpi) |>
  filter(n() > 1)

cat("Duplicate id_treatment + dpi combinations:", nrow(duplicates), "\n")

# Prepare data for pivot - take mean if there are duplicates
area_for_pivot <- growthspeed_contam |>
  filter(!is.na(dpi)) |>
  filter(!is.na(id_treatment)) |>
  group_by(id_treatment, dpi) |>
  summarise(area_size = mean(area_size, na.rm = TRUE), .groups = "drop")

cat("Rows after deduplication:", nrow(area_for_pivot), "\n")

area_wide <- area_for_pivot |>
  pivot_wider(
    names_from = dpi,
    values_from = area_size,
    names_glue = "area_size_{dpi}dpi"
  )

# Verify pivot worked
cat("area_wide dimensions:", nrow(area_wide), "rows x", ncol(area_wide), "columns\n")
cat("Sample of area_wide:\n")
print(head(area_wide[, 1:min(5, ncol(area_wide))]))

# Step 5: Summarize contamination and growth description per treatment
contamination_summary <- growthspeed_contam |>
  group_by(id_treatment) |>
  arrange(dpi) |>
  summarise(
    max_contamination_area = max(total_contamination_area, na.rm = TRUE),
    # Calculate contamination AUC using trapezoidal rule
    contamination_auc = if (n() > 1) {
      sum(diff(dpi) * (head(total_contamination_area, -1) + tail(total_contamination_area, -1)) / 2, na.rm = TRUE)
    } else {
      0
    },
    any_contamination = any(nr_contaminations > 0, na.rm = TRUE),
    any_reproductive_structures = any(reproductive_structures > 0, na.rm = TRUE),
    # Get growth_description at final timepoint (max DPI)
    growth_description = growth_description[which.max(dpi)],
    .groups = "drop"
  )

# Step 6: Join area and contamination summaries
growthspeed_processed <- area_wide |>
  left_join(contamination_summary, by = "id_treatment")

cat("=== Growthspeed processed ===\n")
cat("Rows:", nrow(growthspeed_processed), "\n")
cat("Columns:", ncol(growthspeed_processed), "\n")
cat("Column names:\n")
print(names(growthspeed_processed))
cat("\nid_treatment range in growthspeed:",
    min(growthspeed_processed$id_treatment, na.rm = TRUE), "-",
    max(growthspeed_processed$id_treatment, na.rm = TRUE), "\n")
cat("id_treatment type:", class(growthspeed_processed$id_treatment), "\n")

# Check for NA columns in area_size
area_cols <- names(growthspeed_processed)[grepl("^area_size_", names(growthspeed_processed))]
cat("Area size columns:", paste(area_cols, collapse = ", "), "\n")

# Check sample of data
cat("\nSample of growthspeed_processed:\n")
print(head(growthspeed_processed[, c("id_treatment", area_cols[1:min(3, length(area_cols))])]))
cat("\n")

# Process faeces data ----
# Step 1: Convert comma-separated numbers to numeric
faeces_numeric <- faeces |>
  mutate(
    dilution_factor_ecoli = as.numeric(gsub(",", "", dilution_factor_ecoli)),
    dilution_factor_enterococcus = as.numeric(gsub(",", "", dilution_factor_enterococcus)),
    dilution_factor_platecount = as.numeric(gsub(",", "", dilution_factor_platecount))
  )

# Step 2: Calculate water content for each replicate
faeces_water <- faeces_numeric |>
  mutate(
    water_content_0dpi_1 = ((weight_wet_1 - foil_weight_1) - (dry_weight_1 - foil_weight_1)) / (weight_wet_1 - foil_weight_1),
    water_content_0dpi_2 = ((weight_wet_2 - foil_weight_2) - (dry_weight_2 - foil_weight_2)) / (weight_wet_2 - foil_weight_2),
    water_content_0dpi_3 = ((weight_wet_3 - foil_weight_3) - (dry_weight_3 - foil_weight_3)) / (weight_wet_3 - foil_weight_3)
  )

# Step 3: Calculate mean water content
faeces_water_mean <- faeces_water |>
  rowwise() |>
  mutate(
    water_content_0dpi_mean = mean(c(water_content_0dpi_1, water_content_0dpi_2, water_content_0dpi_3), na.rm = TRUE)
  ) |>
  ungroup()

# Step 4: Calculate bacterial concentrations for each replicate
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

# Step 5: Calculate mean bacterial concentrations
faeces_processed <- faeces_bacteria |>
  rowwise() |>
  mutate(
    ecoli_concentration_mean = mean(c(ecoli_concentration_1, ecoli_concentration_2, ecoli_concentration_3), na.rm = TRUE),
    enterococcus_concentration_mean = mean(c(enterococcus_concentration_1, enterococcus_concentration_2, enterococcus_concentration_3), na.rm = TRUE),
    total_plate_count_concentration_mean = mean(c(total_plate_count_concentration_1, total_plate_count_concentration_2, total_plate_count_concentration_3), na.rm = TRUE)
  ) |>
  ungroup() |>
  select(id_faeces, ph_0dpi = ph, water_content_0dpi_mean, ecoli_concentration_0dpi_mean = ecoli_concentration_mean, enterococcus_concentration_0dpi_mean = enterococcus_concentration_mean, total_plate_count_concentration_0dpi_mean = total_plate_count_concentration_mean)

cat("=== Faeces processed ===\n")
cat("Rows:", nrow(faeces_processed), "\n")
glimpse(faeces_processed)
cat("\n")

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
    water_content_14dpi = ((sample_weight_14dpi - foil_weight) - (`sample_dry weight` - foil_weight)) / (sample_weight_14dpi - foil_weight)
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
