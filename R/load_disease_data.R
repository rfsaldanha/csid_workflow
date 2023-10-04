load_disease_data <- function(x, important_vars, labels_classifications){

  # Open dataset of parquet files
  open_dataset(sources = x) %>%
    # Filter only positive cases
    filter(CLASSI_FIN %in% labels_classifications) %>%
    # Select only important variables
    select(all_of(important_vars)) %>%
    # Convert variables from char to date
    mutate(
      DT_NOTIFIC = ymd(DT_NOTIFIC),
      DT_SIN_PRI = ymd(DT_SIN_PRI)
    ) %>%
    # Collect data to memory
    collect()
}
