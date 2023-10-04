### Load packages required to define the pipeline
library(targets)
library(tarchetypes)
library(quarto)

### Set target options
tar_option_set(
  packages = c(
    "tibble", "dplyr", "arrow", "qs", "lubridate", "readr", "timetk", "janitor",
    "sf", "filesstrings", "brpop", "disdata", "zonalclim"
  ),
  format = "qs",
  controller = crew::crew_controller_local(workers = 4)
)

### Run the R scripts in the R/ folder with custom functions
tar_source()

### Definitions

# Disease variables to load
important_vars <- c("DT_NOTIFIC","DT_SIN_PRI","ID_MN_RESI","COMUNINF")

# Disease diagnose labels classified as positive
labels_classifications <- c("Febre hemorrágica do dengue", "Síndrome do choque do dengue", "Dengue com sinais de alarme",
                            "Dengue clássico", "Dengue com complicações", "Dengue",
                            "Dengue grave")

# Boundaries code unique identifier
g_var <- "ID_MN_RESI"

# Boundaries code best candidate (for imputation)
g_var_candidate <- "COMUNINF"

# Boundaries code number of characters allowed
g_var_nchar <- 6

# Date variable
d_var <- "DT_SIN_PRI"

# Date variable best candidate (for imputation)
d_var_candidate <- "DT_NOTIFIC"

# Minimum date allowed
d_var_min <- as.Date("2011-01-01")

# Maximun date allowed
d_var_max <- as.Date("2021-12-31")

# Time aggregation unit
a_unit <- "week"

# Disease data files
files_disease_data <- "input_data/disease/"

# Socioeconomic data file
file_socioeconomic_data <- "input_data/socioeconomic/idhm.csv"

# Climate NetCDF files addresses
files_max_temperature_data <- list.files("input_data/climate/max_temperature/", full.names = TRUE)
files_min_temperature_data <- list.files("input_data/climate/min_temperature/", full.names = TRUE)
files_precipitation_data <- list.files("input_data/climate/precipitation/", full.names = TRUE)


### Target definitions list
list(
  ### Disease data
  # Disease data files
  tar_target(
    name = disease_data_files,
    command = files_disease_data,
    format = "file"
  ),
  # Load disease data
  tar_target(
    name = raw_disease_data,
    command = load_disease_data(disease_data_files, important_vars, labels_classifications),
    cue = tar_cue(mode = "never")
  ),
  # Imputate disease data variables
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
  # Filter valid disease data
  tar_target(
    name = valid_disease_data,
    command = filter_disease_data(imputated_disease_data)
  ),
  # Aggregate disease data
  tar_target(
    name = disease_data,
    command = agg_data(
      x = valid_disease_data,
      g_var = g_var,
      d_var = d_var,
      a_unit = a_unit
    )
  ),
  # Disease data report
  tar_quarto(
    name = disease_data_report,
    path = "reports/disease_data_report.qmd",
    execute_params = list(labels_classifications = labels_classifications)
  ),
  ### Socio economic data
  # Load socioeconomic data
  tar_target(
    name = socioeconomic_data_file,
    command = file_socioeconomic_data,
    format = "file",
    cue = tar_cue(mode = "never")
  ),
  tar_target(
    name = socioeconomic_data,
    command = load_socio_economic_data(x = socioeconomic_data_file)
  ),
  # Load population data
  tar_target(
    name = population_data,
    command = load_population_data(d_var_min, d_var_max)
  ),
  ### Climate data
  # Load max temp data
  tar_target(
    name = max_temperature_data_files,
    command = files_max_temperature_data,
    format = "file",
    cue = tar_cue(mode = "never")
  ),
  # Prepare max temp data
  tar_target(
    name = max_temperature_data,
    command = prepare_climate_data(
      files_list = max_temperature_data_files,
      zonal_list <- c("mean"),
      db_file = "output_data/max_temperature.sqlite"
    ),
    format = "file"
  ),
  # Load min temp data
  tar_target(
    name = min_temperature_data_files,
    command = files_min_temperature_data,
    format = "file",
    cue = tar_cue(mode = "never")
  ),
  # Prepare min temp data
  tar_target(
    name = min_temperature_data,
    command = prepare_climate_data(
      files_list = min_temperature_data_files,
      zonal_list <- c("mean"),
      db_file = "output_data/min_temperature.sqlite"
    ),
    format = "file"
  ),
  # Load precipitation data
  tar_target(
    name = precipitation_data_files,
    command = files_precipitation_data,
    format = "file",
    cue = tar_cue(mode = "never")
  ),
  tar_target(
    name = precipitation_data,
    command = prepare_climate_data(
      files_list = precipitation_data_files,
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
  # Export bundled data
  tar_target(
    name = export_bundled_data,
    command = write_bundled_data(
      bundled_data,
      "output_data/bundled_data.parquet"
    ),
    format = "file"
  )
)
