load_disease_data <- function(){

  # Variables to load
  important_vars <- c("DT_NOTIFIC","DT_SIN_PRI","ID_MN_RESI","COMUNINF")

  # Labels classified as positive dengue cases
  dengue_classifications <- c("Febre hemorrágica do dengue", "Síndrome do choque do dengue", "Dengue com sinais de alarme",
                              "Dengue clássico", "Dengue com complicações", "Dengue",
                              "Dengue grave")

  # Open dataset of parquet files
  open_dataset(sources = "input_data/disease/") %>%
    # Filter only positive cases
    filter(CLASSI_FIN %in% dengue_classifications) %>%
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
