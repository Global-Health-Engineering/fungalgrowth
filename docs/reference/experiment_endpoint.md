# experiment_endpoint: Experiment Endpoint Measurements

Measurements of weight, pH and bacterial concentration at endpoint.

## Usage

``` r
experiment_endpoint
```

## Format

A tibble with 132 rows and 7 variables

- id_treatment:

  Unique identifier for each experimental treatment unit.

- wet_weight:

  Wet weight of the faeces sample at day 14 post inoculation (14 dpi).

- dry_weight:

  Dry weight of the faeces sample at day 14 post inoculation (14 dpi);
  derived from wet weight and water content.

- ecoli_concentration:

  E. coli concentration at day 14 post inoculation (14 dpi).

- enterococcus_concentration:

  Enterococcus concentration at day 14 post inoculation (14 dpi).

- total_plate_count_concentration:

  Total plate count concentration at day 14 post inoculation (14 dpi).

- ph:

  pH of the faeces sample at day 14 post inoculation (14 dpi).
