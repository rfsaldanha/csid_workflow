# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)

# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("tibble", "dplyr", "disdata", "zonalclim"), # packages that your targets need to run
  # format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # For distributed computing in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller with 2 workers which will run as local R processes:
  #
  controller = crew::crew_controller_local(workers = 4)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package. The following
  # example is a controller for Sun Grid Engine (SGE).
  #
  #   controller = crew.cluster::crew_controller_sge(
  #     workers = 50,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.0".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# tar_make_clustermq() is an older (pre-{crew}) way to do distributed computing
# in {targets}, and its configuration for your machine is below.
# options(clustermq.scheduler = "multicore")

# tar_make_future() is an older (pre-{crew}) way to do distributed computing
# in {targets}, and its configuration for your machine is below.
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  ### Disease data
  tar_target(
    name = raw_disease_data,
    command = load_disease_data()
    # format = "feather" # efficient storage for large data frames
  ),
  tar_target(
    name = imputated_disease_data,
    command = imp_data(
      x = raw_disease_data,
      g_var = "ID_MN_RESI",
      g_var_candidate = "COMUNINF",
      g_var_nchar = 6,
      d_var = "DT_SIN_PRI",
      d_var_candidate = "DT_NOTIFIC",
      d_var_min = as.Date("2020-01-01"),
      d_var_max = as.Date("2020-12-31")
    )
  ),
  tar_target(
    name = disease_data,
    command = agg_data(
      x = imputated_disease_data,
      g_var = "ID_MN_RESI",
      d_var = "DT_SIN_PRI",
      a_unit = "week"
    ) %>%
      rename(mun = ID_MN_RESI, date = DT_SIN_PRI, cases = freq)
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
    command = load_population_data(d_var = disease_data$date)
  ),
  ### Climate data
  tar_target(
    name = max_temperature_data,
    command = prepare_climate_data(
      path = "input_data/climate/max_temperature/",
      zonal_list <- c("mean"),
      db_file = "output_data/max_temperature.sqlite"
    ),
    format = "file"
  ),
  tar_target(
    name = mean_temperature_data,
    command = prepare_climate_data(
      path = "input_data/climate/mean_temperature/",
      zonal_list <- c("mean"),
      db_file = "output_data/mean_temperature.sqlite"
    ),
    format = "file"
  ),
  tar_target(
    name = min_temperature_data,
    command = prepare_climate_data(
      path = "input_data/climate/min_temperature/",
      zonal_list <- c("mean"),
      db_file = "output_data/min_temperature.sqlite"
    ),
    format = "file"
  ),
  ### Bundle data
  tar_target(
    name = bundled_data,
    command = create_bundled_data(
      disease_data = disease_data,
      population_data = population_data,
      socioeconomic_data = socioeconomic_data,
      max_temperature_data,
      min_temperature_data,
      mean_temperature_data
    )
  ),
  tar_target(
    name = write_bundled_data,
    command = bundled_data %>% readr::write_csv2(file = "output_data/bundled_data.csv")
  )
)
