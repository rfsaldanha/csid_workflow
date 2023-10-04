# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)

# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c(
    "tibble", "dplyr", "arrow", "lubridate", "readr", "timetk", "janitor",
    "sf", "filesstrings", "brpop", "disdata", "zonalclim"
  ),
  controller = crew::crew_controller_local(workers = 4)
)

# Run the R scripts in the R/ folder with custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed.

# Definitions
g_var <- "ID_MN_RESI"
g_var_candidate <- "COMUNINF"
g_var_nchar <- 6
d_var <- "DT_SIN_PRI"
d_var_candidate <- "DT_NOTIFIC"
d_var_min <- as.Date("2011-01-01")
d_var_max <- as.Date("2021-12-31")
a_unit <- "week"

files_max_temperature_data <- list.files("input_data/climate/max_temperature/", full.names = TRUE)
files_min_temperature_data <- list.files("input_data/climate/min_temperature/", full.names = TRUE)
files_precipitation_data <- list.files("input_data/climate/precipitation/", full.names = TRUE)

# Target list
list(
  ### Disease data
  tar_target(
    name = raw_disease_data,
    command = load_disease_data()
  ),
  tar_target(
    name = imputated_disease_data,
    command = imp_data(
      x = raw_disease_data,
      g_var = g_var,
      g_var_candidate = g_var_candidate,
      g_var_nchar = g_var_nchar,
      d_var = d_var,
      d_var_candidate = d_var_candidate,
      d_var_min = d_var_min,
      d_var_max = d_var_max
    )
  ),
  tar_target(
    name = valid_disease_data,
    command = filter_disease_data(imputated_disease_data)
  ),
  tar_target(
    name = disease_data,
    command = agg_data(
      x = valid_disease_data,
      g_var = g_var,
      d_var = d_var,
      a_unit = a_unit
    )
  ),
  ### Socio economic data
  tar_target(
    name = socio_economic_data_file,
    command = "input_data/socioeconomic/idhm.csv",
    format = "file"
  ),
  tar_target(
    name = socioeconomic_data,
    command = load_socio_economic_data(x = socio_economic_data_file)
  ),
  ### Population data
  tar_target(
    name = population_data,
    command = load_population_data(d_var_min, d_var_max)
  ),
  ### Climate data
  tar_target(
    name = max_temperature_data,
    command = prepare_climate_data(
      files_list = files_max_temperature_data,
      zonal_list <- c("mean"),
      db_file = "output_data/max_temperature.sqlite"
    ),
    format = "file"
  ),
  tar_target(
    name = min_temperature_data,
    command = prepare_climate_data(
      files_list = files_min_temperature_data,
      zonal_list <- c("mean"),
      db_file = "output_data/min_temperature.sqlite"
    ),
    format = "file"
  ),

  tar_target(
    name = precipitation_data,
    command = prepare_climate_data(
      files_list = files_precipitation_data,
      zonal_list <- c("sum"),
      db_file = "output_data/precipitation.sqlite"
    ),
    format = "file"
  ),
  ### Bundle data
  tar_target(
    name = bundled_data,
    command = create_bundled_data(
      disease_data = disease_data,
      g_var = g_var,
      d_var = d_var,
      population_data = population_data,
      socioeconomic_data = socioeconomic_data,
      max_temperature_data = max_temperature_data,
      min_temperature_data = min_temperature_data,
      precipitation_data = precipitation_data
    )
  ),
  tar_target(
    name = write_bundled_data,
    command = write_bundled_data_fun(
      bundled_data,
      "output_data/bundled_data.parquet"
    ),
    format = "file"
  )
)
