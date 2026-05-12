# fungal_growth: Fungal Growth

Measurements on fungal growth and contamination across several
timepoints.

## Usage

``` r
fungal_growth
```

## Format

A tibble with 990 rows and 8 variables

- id_treatment:

  Identifier for the experimental treatment unit; joins to
  experiment_setup and experiment_endpoint.

- date:

  Date of the growth observation measurement.

- dpi:

  Days post inoculation; days elapsed between this measurement and the
  first measurement for this treatment.

- area_size:

  Area of fungal mycelium at the observation date.

- nr_contaminations:

  Number of macroscopically distinct contaminating fungi observed at
  this timepoint.

- total_contamination_area:

  Total area of contamination summed across all observed contamination
  spots at this timepoint.

- reproductive_structures:

  Coded indicator of reproductive structures observed at this timepoint.

- growth_description:

  Coded description of fungal growth at this timepoint; numeric score
  recorded during observation.
