#' experiment_endpoint: Experiment Endpoint Measurements
#'
#' Measurements of weight, pH and bacterial concentration at endpoint.
#'
#' @format A tibble with 132 rows and 7 variables
#' \describe{
#'   \item{id_treatment}{Unique identifier for each experimental treatment unit.}
#'   \item{wet_weight}{Wet weight of the faeces sample at day 14 post inoculation (14 dpi).}
#'   \item{dry_weight}{Dry weight of the faeces sample at day 14 post inoculation (14 dpi); derived from wet weight and water content.}
#'   \item{ecoli_concentration}{E. coli concentration at day 14 post inoculation (14 dpi).}
#'   \item{enterococcus_concentration}{Enterococcus concentration at day 14 post inoculation (14 dpi).}
#'   \item{total_plate_count_concentration}{Total plate count concentration at day 14 post inoculation (14 dpi).}
#'   \item{ph}{pH of the faeces sample at day 14 post inoculation (14 dpi).}
#' }
"experiment_endpoint"
