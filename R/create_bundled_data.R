create_bundled_data <- function(disease_data, g_var, d_var, subsets, population_data,
                                socioeconomic_data, max_temperature_data,
                                min_temperature_data, precipitation_data){
  # Disease data
  res1 <- disease_data %>%
    # Rename fields
    rename("code_muni" = !!sym(g_var), "date" = !!sym(d_var), "cases" = "freq") %>%
    # Join subset id
    inner_join(subsets, by = "code_muni") %>%
    # Create year variable to join with population data
    mutate(dengue_year = lubridate::year(date)) %>%
    # Join population data by mun and year
    inner_join(population_data, by = c("dengue_year" = "year", "code_muni" = "mun")) %>%
    # Compute population rate
    mutate(rate = cases/pop*100000) %>%
    # Remove year variable
    select(-dengue_year) %>%
    # Join socioeconomic data by year
    left_join(socioeconomic_data, by = c("code_muni")) %>%
    # Remove invalid municipalities
    filter(substr(code_muni, 4,6) != "000")


  # Municipalities present at the dataset
  mun_list <- unique(res1$code_muni)

  # Max temp
  max_temperature_data_conn = DBI::dbConnect(RSQLite::SQLite(), max_temperature_data, extended_types = TRUE)
  max_temperature_data_table_name <- DBI::dbListTables(max_temperature_data_conn)

  res2 <- tbl(max_temperature_data_conn, max_temperature_data_table_name) %>%
    mutate(code_muni = substr(code_muni, 0, 6)) %>%
    filter(code_muni %in% mun_list) %>%
    collect() %>%
    group_by(code_muni) %>%
    summarise_by_time(.date_var = date, .by = "week", value = mean(value, na.rm = TRUE)) %>%
    ungroup() %>%
    rename(tmax = value)

  # Min temp
  min_temperature_data_conn = DBI::dbConnect(RSQLite::SQLite(), min_temperature_data, extended_types = TRUE)
  min_temperature_data_table_name <- DBI::dbListTables(min_temperature_data_conn)

  res3 <- tbl(min_temperature_data_conn, min_temperature_data_table_name) %>%
    mutate(code_muni = substr(code_muni, 0, 6)) %>%
    filter(code_muni %in% mun_list) %>%
    collect() %>%
    group_by(code_muni) %>%
    summarise_by_time(.date_var = date, .by = "week", value = mean(value, na.rm = TRUE)) %>%
    ungroup() %>%
    rename(tmin = value)

  # Prec
  precipitation_data_conn = DBI::dbConnect(RSQLite::SQLite(), precipitation_data, extended_types = TRUE)
  precipitation_data_table_name <- DBI::dbListTables(precipitation_data_conn)

  res4 <- tbl(precipitation_data_conn, precipitation_data_table_name) %>%
    mutate(code_muni = substr(code_muni, 0, 6)) %>%
    filter(code_muni %in% mun_list) %>%
    collect() %>%
    group_by(code_muni) %>%
    summarise_by_time(.date_var = date, .by = "week", value = sum(value, na.rm = TRUE)) %>%
    ungroup() %>%
    rename(prec = value)

  # Join all data
  res5 <- left_join(res1, res2, by = c("code_muni", "date")) %>%
    left_join(res3, by = c("code_muni", "date")) %>%
    left_join(res4, by = c("code_muni", "date"))

  # Lag variables
  res6 <- res5 %>%
    group_by(code_muni) %>%
    arrange(date) %>%
    tk_augment_lags(.value = c(cases, tmax, tmin, prec), .lags = 1:6) %>%
    ungroup()

  return(res6)
}
