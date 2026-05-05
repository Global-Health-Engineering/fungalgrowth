#' Fungal Growth Assay on Human Faeces
#'
#' Data from a laboratory assay investigating the growth of fungal species on
#' human faeces and their effect on faecal physicochemical properties and
#' bacterial indicator concentrations over 14 days post inoculation. Five fungal
#' species were tested alongside untreated controls across multiple inoculation
#' batches: \emph{Pleurotus ostreatus} (MG1015, MG1010), \emph{Ganoderma
#' lucidum}, \emph{Stropharia fimicola} (F35), and \emph{Trichoderma harzianum}
#' (T22).
#'
#' @format A data frame with 108 rows and 38 columns:
#' \describe{
#'   \item{id_treatment}{Unique identifier for each experimental treatment unit}
#'   \item{id_inoc}{Identifier for the fungal inoculum}
#'   \item{id_faeces}{Identifier for the faeces sample}
#'   \item{species}{Fungal species used as inoculum}
#'   \item{wet_weight_0dpi}{Wet weight of the faeces sample at day 0 post inoculation (g)}
#'   \item{wet_weight_14dpi}{Wet weight of the faeces sample at day 14 post inoculation (g)}
#'   \item{dry_weight_0dpi}{Dry weight of the faeces sample at day 0 post inoculation, derived from wet weight and water content (g)}
#'   \item{dry_weight_14dpi}{Dry weight of the faeces sample at day 14 post inoculation, derived from wet weight and water content (g)}
#'   \item{ph_0dpi}{pH of the faeces sample at day 0 post inoculation}
#'   \item{ph_14dpi}{pH of the faeces sample at day 14 post inoculation}
#'   \item{water_content_0dpi_mean}{Mean water content of the faeces sample at day 0 post inoculation; mean of 3 replicates (proportion)}
#'   \item{ecoli_concentration_0dpi_mean}{Mean \emph{E. coli} concentration at day 0 post inoculation; mean of 3 replicates (CFU/g)}
#'   \item{ecoli_concentration_14dpi}{\emph{E. coli} concentration at day 14 post inoculation (CFU/g)}
#'   \item{ecoli_log_change}{Log10 change in \emph{E. coli} concentration from day 0 to day 14}
#'   \item{enterococcus_concentration_0dpi_mean}{Mean \emph{Enterococcus} concentration at day 0 post inoculation; mean of 3 replicates (CFU/g)}
#'   \item{enterococcus_concentration_14dpi}{\emph{Enterococcus} concentration at day 14 post inoculation (CFU/g)}
#'   \item{enterococcus_log_change}{Log10 change in \emph{Enterococcus} concentration from day 0 to day 14}
#'   \item{total_plate_count_concentration_0dpi_mean}{Mean total plate count concentration at day 0 post inoculation; mean of 3 replicates (CFU/g)}
#'   \item{total_plate_count_concentration_14dpi}{Total plate count concentration at day 14 post inoculation (CFU/g)}
#'   \item{total_plate_count_log_change}{Log10 change in total plate count concentration from day 0 to day 14}
#'   \item{area_size_0dpi}{Area size of fungal mycelium at day 0 post inoculation (cm2)}
#'   \item{area_size_1dpi}{Area size of fungal mycelium at day 1 post inoculation (cm2)}
#'   \item{area_size_2dpi}{Area size of fungal mycelium at day 2 post inoculation (cm2)}
#'   \item{area_size_3dpi}{Area size of fungal mycelium at day 3 post inoculation (cm2)}
#'   \item{area_size_5dpi}{Area size of fungal mycelium at day 5 post inoculation (cm2)}
#'   \item{area_size_6dpi}{Area size of fungal mycelium at day 6 post inoculation (cm2)}
#'   \item{area_size_7dpi}{Area size of fungal mycelium at day 7 post inoculation (cm2)}
#'   \item{area_size_8dpi}{Area size of fungal mycelium at day 8 post inoculation (cm2)}
#'   \item{area_size_9dpi}{Area size of fungal mycelium at day 9 post inoculation (cm2)}
#'   \item{area_size_10dpi}{Area size of fungal mycelium at day 10 post inoculation (cm2)}
#'   \item{area_size_12dpi}{Area size of fungal mycelium at day 12 post inoculation (cm2)}
#'   \item{area_size_13dpi}{Area size of fungal mycelium at day 13 post inoculation (cm2)}
#'   \item{area_size_14dpi}{Area size of fungal mycelium at day 14 post inoculation (cm2)}
#'   \item{max_contamination_area}{Maximum total contamination area across all measured timepoints (cm2)}
#'   \item{contamination_auc}{Area under the curve of total contamination area over time, calculated using the trapezoidal rule (cm2*days)}
#'   \item{any_contamination}{Whether any contamination was observed across all timepoints}
#'   \item{any_reproductive_structures}{Whether any reproductive structures were observed across all timepoints}
#'   \item{growth_description}{Description of fungal growth at the final measured timepoint}
#' }
#' @source Data collected at ETH Zurich, Global Health Engineering group.
"fungalgrowth"
