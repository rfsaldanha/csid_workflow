load_socio_economic_data <- function(x){
  read_delim(
    file = x,
    delim = ",", locale=locale(decimal_mark = "."),
    na = "-",
    col_types = cols(
      CD_GEOCMU = col_character(),
      Município = col_character(),
      CodEstado = col_character(),
      Estado = col_character(),
      IDHM1991 = col_double(),
      IDHMR1991 = col_double(),
      IDHML1991 = col_double(),
      IDHME1991 = col_double(),
      R1991 = col_double(),
      IDHM2000 = col_double(),
      IDHMR2000 = col_double(),
      IDHML2000 = col_double(),
      IDHME2000 = col_double(),
      R2000 = col_double(),
      IDHM2010 = col_double(),
      IDHMR2010 = col_double(),
      IDHML2010 = col_double(),
      IDHME2010 = col_double(),
      R2010 = col_double(),
      NM_MUNNICIP = col_character()
    )
  ) %>%
    clean_names() %>%
    rename(code_muni = cd_geocmu, name_muni = municipio, code_uf = cod_estado, uf = estado) %>%
    select(-nm_munnicip) %>%
    mutate(code_muni = substr(code_muni, 0, 6)) %>%
    select(code_muni, idhm1991, idhm2000, idhm2010)
}
