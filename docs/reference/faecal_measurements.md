# faecal_measurements: Feacal Samples Measurements

Weight, additive, pH, bactial and water concentration measurements on
faecal samples at the start of the experiment.

## Usage

``` r
faecal_measurements
```

## Format

A tibble with 6 rows and 10 variables

- id_faeces:

  Identifier for the faeces sample.

- weight_total:

  Total weight of faeces collected before additive at 0 dpi.

- weight_additive:

  Weight of additive mixed into the faeces at 0 dpi.

- additive:

  Type of additive mixed into the faeces at 0 dpi.

- additive_ratio:

  Proportion of additive relative to total mixture weight at 0 dpi.

- ph:

  pH of the faeces-additive mixture at collection (0 dpi).

- water_content_mean:

  Mean water content of the faeces sample at day 0 post inoculation (0
  dpi); mean of 3 replicates.

- ecoli_concentration_mean:

  Mean E. coli concentration at day 0 post inoculation (0 dpi); mean of
  3 replicates.

- enterococcus_concentration_mean:

  Mean Enterococcus concentration at day 0 post inoculation (0 dpi);
  mean of 3 replicates.

- total_plate_count_concentration_mean:

  Mean total plate count concentration at day 0 post inoculation (0
  dpi); mean of 3 replicates.
