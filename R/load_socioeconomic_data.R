load_socio_economic_data <- function(x){
  readr::read_delim(
    file = x,
    delim = ",", locale=readr::locale(decimal_mark = "."),
    na = "-",
    col_types = readr::cols(
      CD_GEOCMU = readr::col_character(),
      Município = readr::col_character(),
      CodEstado = readr::col_character(),
      Estado = readr::col_character(),
      IDHM1991 = readr::col_double(),
      IDHMR1991 = readr::col_double(),
      IDHML1991 = readr::col_double(),
      IDHME1991 = readr::col_double(),
      R1991 = readr::col_double(),
      IDHM2000 = readr::col_double(),
      IDHMR2000 = readr::col_double(),
      IDHML2000 = readr::col_double(),
      IDHME2000 = readr::col_double(),
      R2000 = readr::col_double(),
      IDHM2010 = readr::col_double(),
      IDHMR2010 = readr::col_double(),
      IDHML2010 = readr::col_double(),
      IDHME2010 = readr::col_double(),
      R2010 = readr::col_double(),
      NM_MUNNICIP = readr::col_character()
    )
  ) %>%
    janitor::clean_names() %>%
    dplyr::rename(code_muni = cd_geocmu, name_muni = municipio, code_uf = cod_estado, uf = estado) %>%
    dplyr::select(-nm_munnicip) %>%
    dplyr::mutate(code_muni = substr(code_muni, 0, 6)) %>%
    dplyr::select(code_muni, idhm1991, idhm2000, idhm2010)
}
