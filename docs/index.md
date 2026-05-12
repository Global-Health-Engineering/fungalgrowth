# fungalgrowth

Data from a laboratory assay investigating the growth of fungal species
on human faeces and their effect on faecal physicochemical properties
and bacterial indicator concentrations over 14 days post inoculation.
Five fungal species were tested alongside untreated controls: Pleurotus
ostreatus (MG1015, MG1010), Ganoderma lucidum, Stropharia fimicola
(F35), and Trichoderma harzianum (T22).

## Installation

You can install the development version of fungalgrowth from
[GitHub](https://github.com/) with:

``` r

# install.packages("devtools")
devtools::install_github("openwashdata/fungalgrowth")
```

``` r

## Run the following code in console if you don't have the packages
## install.packages(c("dplyr", "knitr", "readr", "stringr", "gt", "kableExtra"))
library(dplyr)
library(knitr)
library(readr)
library(stringr)
library(gt)
library(kableExtra)
```

Alternatively, you can download the individual datasets as a CSV or XLSX
file from the table below.

1.  Click Download CSV. A window opens that displays the CSV in your
    browser.
2.  Right-click anywhere inside the window and select “Save Page As…”.
3.  Save the file in a folder of your choice.

| dataset | CSV | XLSX |
|:---|:---|:---|
| experiment_setup | [Download CSV](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/experiment_setup.csv) | [Download XLSX](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/experiment_setup.xlsx) |
| experiment_endpoint | [Download CSV](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/experiment_endpoint.csv) | [Download XLSX](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/experiment_endpoint.xlsx) |
| faecal_measurements | [Download CSV](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/faecal_measurements.csv) | [Download XLSX](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/faecal_measurements.xlsx) |
| inoculum_species | [Download CSV](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/inoculum_species.csv) | [Download XLSX](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/inoculum_species.xlsx) |
| fungal_growth | [Download CSV](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/fungal_growth.csv) | [Download XLSX](https://github.com/openwashdata/fungalgrowth/raw/main/inst/extdata/fungal_growth.xlsx) |

## Data

The package provides access to five datasets that together document the
experimental design, the characterization of the inputs (faeces samples
and fungal inocula), the time-series of mycelium growth observations,
and the endpoint measurements at 14 days post inoculation. Each dataset
can be loaded directly after attaching the package.

``` r

library(fungalgrowth)
```

### experiment_setup

The dataset `experiment_setup` contains data about the experimental
setup recorded at 0 days post inoculation (0 dpi), linking each
treatment unit to its faeces sample and fungal inoculum along with the
initial faeces wet weight on the plate. It has 132 observations and 4
variables

``` r

experiment_setup |>
  head(3) |>
  gt::gt() |>
  gt::as_raw_html()
```

| id_treatment | id_inoc | id_faeces | wet_weight |
|-------------:|--------:|----------:|-----------:|
|            1 |       1 |         1 |      15.53 |
|            2 |       1 |         1 |      15.81 |
|            3 |       1 |         1 |      15.43 |

For an overview of the variable names, see the following table.

| variable_name | variable_type | unit | description |
|:---|:---|:---|:---|
| id_treatment | numeric | NA | Unique identifier for each experimental treatment unit. |
| id_inoc | numeric | NA | Identifier for the fungal inoculum used in this treatment; joins to inoculum_species. |
| id_faeces | numeric | NA | Identifier for the faeces sample used in this treatment; joins to faecal_measurements. |
| wet_weight | numeric | g | Wet weight of the faeces sample at day 0 post inoculation (0 dpi). |

### experiment_endpoint

The dataset `experiment_endpoint` contains data about the experimental
measurements taken at 14 days post inoculation (14 dpi), including
faeces wet and dry weights, pH, and bacterial indicator concentrations
(E. coli, Enterococcus, total plate count) for each treatment unit. It
has 132 observations and 7 variables

``` r

experiment_endpoint |> 
  head(3) |> 
  gt::gt() |>
  gt::as_raw_html()
```

| id_treatment | wet_weight | dry_weight | ecoli_concentration | enterococcus_concentration | total_plate_count_concentration | ph |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 15.15 | 7.001594 | 0 | 0.0 | 0.000000e+00 | 5.18 |
| 2 | 15.48 | 6.952096 | 0 | 0.0 | 3.960396e+01 | 5.27 |
| 3 | 14.61 | 6.729455 | 0 | 178899.1 | 1.559633e+08 | 8.53 |

For an overview of the variable names, see the following table.

| variable_name | variable_type | unit | description |
|:---|:---|:---|:---|
| id_treatment | numeric | NA | Unique identifier for each experimental treatment unit. |
| wet_weight | numeric | g | Wet weight of the faeces sample at day 14 post inoculation (14 dpi). |
| dry_weight | numeric | g | Dry weight of the faeces sample at day 14 post inoculation (14 dpi); derived from wet weight and water content. |
| ecoli_concentration | numeric | CFU/g | E. coli concentration at day 14 post inoculation (14 dpi). |
| enterococcus_concentration | numeric | CFU/g | Enterococcus concentration at day 14 post inoculation (14 dpi). |
| total_plate_count_concentration | numeric | CFU/g | Total plate count concentration at day 14 post inoculation (14 dpi). |
| ph | numeric | NA | pH of the faeces sample at day 14 post inoculation (14 dpi). |

### faecal_measurements

The dataset `faecal_measurements` contains data about the
characterization of each faeces sample at 0 days post inoculation (0
dpi), including total faeces weight, additive composition, pH, water
content, and bacterial indicator concentrations (E. coli, Enterococcus,
total plate count) averaged across three replicates. It has 6
observations and 10 variables

``` r

faecal_measurements |>
  head(3) |>
  gt::gt() |>
  gt::as_raw_html()
```

| id_faeces | weight_total | weight_additive | additive | additive_ratio | ph | water_content_mean | ecoli_concentration_mean | enterococcus_concentration_mean | total_plate_count_concentration_mean |
|---:|---:|---:|:---|---:|---:|---:|---:|---:|---:|
| 1 | 394 | 197 | wood chips | 0.5 | 6.38 | 0.5541251 | 445626.2 | 384329.0 | 16545355 |
| 2 | 274 | 137 | wood chips | 0.5 | 6.44 | 0.5546023 | 6569243.5 | 200373.4 | 246047273 |
| 3 | 394 | 197 | wood chips | 0.5 | 6.04 | 0.5529212 | 6085053.9 | 2103578.7 | 62342903 |

For an overview of the variable names, see the following table.

| variable_name | variable_type | unit | description |
|:---|:---|:---|:---|
| id_faeces | numeric | NA | Identifier for the faeces sample. |
| weight_total | numeric | g | Total weight of faeces collected before additive at 0 dpi. |
| weight_additive | numeric | g | Weight of additive mixed into the faeces at 0 dpi. |
| additive | character | NA | Type of additive mixed into the faeces at 0 dpi. |
| additive_ratio | numeric | proportion | Proportion of additive relative to total mixture weight at 0 dpi. |
| ph | numeric | NA | pH of the faeces-additive mixture at collection (0 dpi). |
| water_content_mean | numeric | proportion | Mean water content of the faeces sample at day 0 post inoculation (0 dpi); mean of 3 replicates. |
| ecoli_concentration_mean | numeric | CFU/g | Mean E. coli concentration at day 0 post inoculation (0 dpi); mean of 3 replicates. |
| enterococcus_concentration_mean | numeric | CFU/g | Mean Enterococcus concentration at day 0 post inoculation (0 dpi); mean of 3 replicates. |
| total_plate_count_concentration_mean | numeric | CFU/g | Mean total plate count concentration at day 0 post inoculation (0 dpi); mean of 3 replicates. |

### inoculum_species

The dataset `inoculum_species` contains data about the fungal inocula
used in the assay, providing the mapping from each inoculum identifier
to the fungal species. It has 44 observations and 2 variables

``` r

inoculum_species |>
  head(3) |>
  gt::gt() |>
  gt::as_raw_html()
```

| id_inoc | species             |
|--------:|:--------------------|
|       1 | ctrl                |
|       2 | P. ostreatus MG1015 |
|       3 | P. ostreatus MG1010 |

For an overview of the variable names, see the following table.

| variable_name | variable_type | unit | description                         |
|:--------------|:--------------|:-----|:------------------------------------|
| id_inoc       | numeric       | NA   | Identifier for the fungal inoculum. |
| species       | character     | NA   | Fungal species used as inoculum.    |

### fungal_growth

The dataset `fungal_growth` contains time-series observations of fungal
mycelium growth on each treatment unit, with one row per
treatment-observation date. Variables include mycelium area,
contamination metrics, and growth descriptors recorded at each
timepoint. It has 990 observations and 8 variables

``` r

fungal_growth |>
  head(3) |>
  gt::gt() |>
  gt::as_raw_html()
```

| id_treatment | date | dpi | area_size | nr_contaminations | total_contamination_area | reproductive_structures | growth_description |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 2025-11-20 | 2 | 0 | 0 | 0 | 0 | 0 |
| 1 | 2025-11-21 | 3 | 0 | 0 | 0 | 0 | 0 |
| 1 | 2025-11-24 | 6 | 0 | 0 | 0 | 0 | 0 |

For an overview of the variable names, see the following table.

| variable_name | variable_type | unit | description |
|:---|:---|:---|:---|
| id_treatment | numeric | NA | Identifier for the experimental treatment unit; joins to experiment_setup and experiment_endpoint. |
| date | Date | NA | Date of the growth observation measurement. |
| dpi | integer | days | Days post inoculation; days elapsed between this measurement and the first measurement for this treatment. |
| area_size | numeric | cm2 | Area of fungal mycelium at the observation date. |
| nr_contaminations | numeric | NA | Number of macroscopically distinct contaminating fungi observed at this timepoint. |
| total_contamination_area | numeric | cm2 | Total area of contamination summed across all observed contamination spots at this timepoint. |
| reproductive_structures | numeric | NA | Coded indicator of reproductive structures observed at this timepoint. |
| growth_description | numeric | NA | Coded description of fungal growth at this timepoint; numeric score recorded during observation. |

## Example

``` r

library(fungalgrowth)
library(ggplot2)

ggplot(fungal_growth, aes(x = dpi, y = area_size, group = id_treatment)) +
  geom_line(alpha = 0.3) +
  labs(
    title = "Fungal mycelium growth over time",
    x = "Days post inoculation",
    y = "Area size (cm²)"
  ) +
  theme_minimal()
```

![](reference/figures/README-unnamed-chunk-15-1.png)

## License

Data are available as
[CC-BY](https://github.com/openwashdata/%7B%7B%7Bpackagename%7D%7D%7D/blob/main/LICENSE.md).

## Citation

Please cite this package using:

``` r

citation("fungalgrowth")
#> To cite package 'fungalgrowth' in publications use:
#> 
#>   Peter J, Clavijo Daza A (2026). _fungalgrowth: Fungal Growth Assay on
#>   Human Faeces_. R package version 0.0.0.9000,
#>   <https://github.com/openwashdata/fungalgrowth>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {fungalgrowth: Fungal Growth Assay on Human Faeces},
#>     author = {Jules Peter and Adriana {Clavijo Daza}},
#>     year = {2026},
#>     note = {R package version 0.0.0.9000},
#>     url = {https://github.com/openwashdata/fungalgrowth},
#>   }
```
