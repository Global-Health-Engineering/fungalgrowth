#' fungal_growth: Fungal Growth
#'
#' Measurements on fungal growth and contamination across several timepoints.
#'
#' @format A tibble with 990 rows and 8 variables
#' \describe{
#'   \item{id_treatment}{Identifier for the experimental treatment unit; joins to experiment_setup and experiment_endpoint.}
#'   \item{date}{Date of the growth observation measurement.}
#'   \item{dpi}{Days post inoculation; days elapsed between this measurement and the first measurement for this treatment.}
#'   \item{area_size}{Area of fungal mycelium at the observation date.}
#'   \item{nr_contaminations}{Number of macroscopically distinct contaminating fungi observed at this timepoint.}
#'   \item{total_contamination_area}{Total area of contamination summed across all observed contamination spots at this timepoint.}
#'   \item{reproductive_structures}{Coded indicator of reproductive structures observed at this timepoint.}
#'   \item{growth_description}{Coded description of fungal growth at this timepoint; numeric score recorded during observation.}
#' }
"fungal_growth"
