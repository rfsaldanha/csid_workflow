write_bundled_data_fun <- function(x, dest){
  arrow::write_parquet(x = x, sink = dest)

  return(dest)
}
