library(ipumsr)
library(dplyr)
library(readr)
library(jsonlite)

ddi <- read_ipums_ddi("usa_00003.xml")
data <- read_ipums_micro(ddi)
summary(data)

state_birthplace_summary <- data %>%
  group_by(STATEFIP, BPL, YEAR) %>%
  summarize(
    Total_Pop = sum(PERWT, na.rm = TRUE)
  ) %>%
  arrange(YEAR, STATEFIP, desc(Total_Pop))

# Load state FIPS codes from the corrected source
state_codes <- read_csv("~/OneDrive - University of North Carolina at Chapel Hill/Spring_25/GEOG 456/GEOG456-Workspace/HW4/bf1acd2290e15b91e6710b6fd3be0a53-11d15233327c8080c9646c7e1f23052659db251d/us-state-ansi-fips.csv")

# Ensure the FIPS codes are correctly formatted (convert to integer for matching)
state_codes <- state_codes %>%
  mutate(st = as.integer(st))

# Merge state names into the summary table using the correct column 'stname'
state_birthplace_summary <- state_birthplace_summary %>%
  left_join(state_codes, by = c("STATEFIP" = "st")) %>%
  rename(State = stname)  # Rename 'stname' to 'State'

filtered_data <- state_birthplace_summary %>%
  filter(BPL > 89) %>%  # Keep only BPL > 89 not born in US states
  filter(BPL < 900) %>%  # Keep only BPL < 900 bad entries/unknown
  group_by(State, YEAR) %>%  # Group by state and year
  slice_max(order_by = BPL, n = 1, with_ties = FALSE) %>%  # Select the row with the highest BPL
  ungroup() %>%  # Ungroup after selection
  select(-stusps)  # Remove 'stusps' column


write_csv(filtered_data, "filtered_state_birthplace_summary.csv")
