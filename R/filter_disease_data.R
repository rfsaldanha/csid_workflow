filter_disease_data <- function(x){
  x %>%
    select(ID_MN_RESI, DT_SIN_PRI) %>%
    filter(
      DT_SIN_PRI >= as.Date("2011-01-01") & DT_SIN_PRI <= as.Date("2021-12-31")
    ) %>%
    na.omit()
}
