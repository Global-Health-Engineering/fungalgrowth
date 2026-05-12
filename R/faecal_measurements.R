#' faecal_measurements: Feacal Samples Measurements
#'
#' Weight, additive, pH, bactial and water concentration measurements on faecal
#' samples at the start of the experiment.
#'
#' @format A tibble with 6 rows and 10 variables
#' \describe{
#'   \item{id_faeces}{Identifier for the faeces sample.}
#'   \item{weight_total}{Total weight of faeces collected before additive at 0 dpi.}
#'   \item{weight_additive}{Weight of additive mixed into the faeces at 0 dpi.}
#'   \item{additive}{Type of additive mixed into the faeces at 0 dpi.}
#'   \item{additive_ratio}{Proportion of additive relative to total mixture weight at 0 dpi.}
#'   \item{ph}{pH of the faeces-additive mixture at collection (0 dpi).}
#'   \item{water_content_mean}{Mean water content of the faeces sample at day 0 post inoculation (0 dpi); mean of 3 replicates.}
#'   \item{ecoli_concentration_mean}{Mean E. coli concentration at day 0 post inoculation (0 dpi); mean of 3 replicates.}
#'   \item{enterococcus_concentration_mean}{Mean Enterococcus concentration at day 0 post inoculation (0 dpi); mean of 3 replicates.}
#'   \item{total_plate_count_concentration_mean}{Mean total plate count concentration at day 0 post inoculation (0 dpi); mean of 3 replicates.}
#' }
"faecal_measurements"
