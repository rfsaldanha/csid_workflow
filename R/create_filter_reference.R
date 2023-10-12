create_filter_reference <- function(population_data){
  population_data %>%
    filter(year == max(year)) %>%
    filter(pop >= 100000) %>%
    select(mun, pop)
}
