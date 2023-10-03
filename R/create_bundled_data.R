create_bundled_data <- function(disease_data, population_data, socioeconomic_data,
                                max_temperature_data, min_temperature_data,
                                mean_temperature_data){
  res1 <- disease_data %>%
    dplyr::mutate(dengue_year = lubridate::year(date)) %>%
    dplyr::inner_join(population_data, by = c("dengue_year" = "year", "mun")) %>%
    select(-dengue_year) %>%
    dplyr::left_join(socioeconomic_data, by = c("mun" = "code_muni")) %>%
    dplyr::rename("code_muni" = "mun")

  max_temperature_data_conn = DBI::dbConnect(RSQLite::SQLite(), max_temperature_data, extended_types = TRUE)
  max_temperature_data_table_name <- DBI::dbListTables(max_temperature_data_conn)

  res2 <- dplyr::tbl(max_temperature_data_conn, max_temperature_data_table_name) %>%
    dplyr::collect() %>%
    dplyr::mutate(code_muni = substr(code_muni, 0, 6)) %>%
    dplyr::group_by(code_muni) %>%
    timetk::summarise_by_time(.date_var = date, .by = "week", value = mean(value, na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    rename(temp_max = value)


  min_temperature_data_conn = DBI::dbConnect(RSQLite::SQLite(), min_temperature_data, extended_types = TRUE)
  min_temperature_data_table_name <- DBI::dbListTables(min_temperature_data_conn)

  res3 <- dplyr::tbl(min_temperature_data_conn, min_temperature_data_table_name) %>%
    dplyr::collect() %>%
    dplyr::mutate(code_muni = substr(code_muni, 0, 6)) %>%
    dplyr::group_by(code_muni) %>%
    timetk::summarise_by_time(.date_var = date, .by = "week", value = mean(value, na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    rename(temp_min = value)

  mean_temperature_data_conn = DBI::dbConnect(RSQLite::SQLite(), mean_temperature_data, extended_types = TRUE)
  mean_temperature_data_table_name <- DBI::dbListTables(mean_temperature_data_conn)

  res4 <- dplyr::tbl(mean_temperature_data_conn, mean_temperature_data_table_name) %>%
    dplyr::collect() %>%
    dplyr::mutate(code_muni = substr(code_muni, 0, 6)) %>%
    dplyr::group_by(code_muni) %>%
    timetk::summarise_by_time(.date_var = date, .by = "week", value = mean(value, na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    rename(temp_mean = value)


  res5 <- left_join(res1, res2, by = c("code_muni", "date")) %>%
    left_join(res3, by = c("code_muni", "date")) %>%
    left_join(res4, by = c("code_muni", "date"))

  return(res5)
}
