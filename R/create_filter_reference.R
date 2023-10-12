create_filter_reference <- function(population_data, p){
  population_data %>%
    filter(year == max(year)) %>%
    filter(pop >= p) %>%
    select(mun, pop)
}
