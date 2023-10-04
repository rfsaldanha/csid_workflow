load_population_data <- function(d_var_min, d_var_max){
  mun_pop_totals() %>%
    filter(year %in% seq(lubridate::year(d_var_min), lubridate::year(d_var_max))) %>%
    mutate(mun = as.character(mun))
}
