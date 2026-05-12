# experiment_setup: Experiment Setup

Fungal inoculum, faecals sample and wet weight for experimental setup.

## Usage

``` r
experiment_setup
```

## Format

A tibble with 132 rows and 4 variables

- id_treatment:

  Unique identifier for each experimental treatment unit.

- id_inoc:

  Identifier for the fungal inoculum used in this treatment; joins to
  inoculum_species.

- id_faeces:

  Identifier for the faeces sample used in this treatment; joins to
  faecal_measurements.

- wet_weight:

  Wet weight of the faeces sample at day 0 post inoculation (0 dpi).
