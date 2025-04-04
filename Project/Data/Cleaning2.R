library(ipumsr)
library(dplyr)
library(readr)
library(tidyverse)
library(jsonlite)

# Load IPUMS data
ddi <- read_ipums_ddi("usa_00004.xml")
data <- read_ipums_micro(ddi)
summary(data)

# Load state FIPS codes
state_codes <- read_csv("~/OneDrive - University of North Carolina at Chapel Hill/Spring_25/GEOG 456/GEOG456-Workspace/HW4/bf1acd2290e15b91e6710b6fd3be0a53-11d15233327c8080c9646c7e1f23052659db251d/us-state-ansi-fips.csv") %>%
  mutate(st = as.integer(st))

# Calculate nativity for each state and year
nativity_by_state_year <- data %>%
  # Create a native-born indicator variable
  mutate(is_native = ifelse(BPL < 90 | BPL %in% c(99, 100, 105, 110, 115, 120), 1, 0)) %>%
  # Group by state and year
  group_by(STATEFIP, YEAR) %>%
  # Calculate the percentage of native-born residents
  summarize(
    native_count = sum(PERWT * is_native, na.rm = TRUE),
    total_count = sum(PERWT, na.rm = TRUE),
    native_pct = round((native_count / total_count) * 100, 2),
    .groups = "drop"
  ) %>%
  # Join with state names
  left_join(state_codes, by = c("STATEFIP" = "st")) %>%
  rename(State = stname) %>%
  select(State, YEAR, native_pct)

# Generate complete sequence of years from 1850 to 2020
years_seq <- seq(1850, 2020, by = 10)

# Create a complete grid of all states and years
all_states <- unique(nativity_by_state_year$State)
complete_grid <- expand.grid(
  State = all_states,
  YEAR = years_seq,
  stringsAsFactors = FALSE
)

# Join with actual data and fill missing values with 0
complete_nativity_data <- complete_grid %>%
  left_join(nativity_by_state_year, by = c("State", "YEAR")) %>%
  mutate(native_pct = ifelse(is.na(native_pct), 0, native_pct))

# Create nested structure: state > years > nativity
nested_nativity_data <- complete_nativity_data %>%
  group_by(State) %>%
  nest(data = c(YEAR, native_pct)) %>%
  mutate(
    # Process the nested data to transform it into a more suitable format
    data = purrr::map(data, function(df) {
      df %>%
        arrange(YEAR) %>%
        # Convert to a named list where names are years and values are percentages
        pivot_wider(names_from = YEAR, values_from = native_pct) %>%
        as.list()
    })
  )

# Convert the nested data frame to JSON
json_output <- toJSON(nested_nativity_data, pretty = TRUE)

# Write the JSON to a file
write(json_output, file = "GEOG456-Workspace/Project/Data/state_nativity_percentages.json")
