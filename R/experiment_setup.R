#' experiment_setup: Experiment Setup
#'
#' Fungal inoculum, faecals sample and wet weight for experimental setup.
#'
#' @format A tibble with 132 rows and 4 variables
#' \describe{
#'   \item{id_treatment}{Unique identifier for each experimental treatment unit.}
#'   \item{id_inoc}{Identifier for the fungal inoculum used in this treatment; joins to inoculum_species.}
#'   \item{id_faeces}{Identifier for the faeces sample used in this treatment; joins to faecal_measurements.}
#'   \item{wet_weight}{Wet weight of the faeces sample at day 0 post inoculation (0 dpi).}
#' }
"experiment_setup"
