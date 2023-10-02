create_bundled_data <- function(disease_data, pop_data, socio_data){
  disease_data %>%
    dplyr::mutate(dengue_year = lubridate::year(date)) %>%
    dplyr::inner_join(pop_data, by = c("dengue_year" = "year", "mun")) %>%
    select(-dengue_year) %>%
    dplyr::left_join(socio_data, by = c("mun" = "code_muni"))
}
