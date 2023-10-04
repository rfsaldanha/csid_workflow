write_bundled_data <- function(x, dest){
  arrow::write_parquet(x = x, sink = dest)

  return(dest)
}
