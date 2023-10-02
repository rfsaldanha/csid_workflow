load_population_data <- function(d_var){
  brpop::mun_pop_totals() %>%
    dplyr::filter(year %in% seq(lubridate::year(min(d_var)), lubridate::year(max(d_var)))) %>%
    dplyr::mutate(mun = as.character(mun))
}
