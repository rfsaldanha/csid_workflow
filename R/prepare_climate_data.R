prepare_climate_data <- function(files_list, zonal_list, db_file){

  sf_geom <- geobr::read_municipality() %>%
    st_transform(crs = 4326)

  zonal_tasks <- zonalclim::create_zonal_tasks(
    nc_files_list = files_list,
    nc_chunk_size = 50,
    sf_geom = sf_geom,
    sf_chunck_size = 50,
    zonal_functions = zonal_list
  )

  res <- zonalclim::compute_zonal_tasks(
    zonal_tasks = zonal_tasks,
    g_var = "code_muni",
    db_file = db_file
  )

  return(db_file)
}
