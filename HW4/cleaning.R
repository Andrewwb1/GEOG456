library(ipumsr)
library(dplyr)
library(readr)
library(tidyverse)

ddi <- read_ipums_ddi("usa_00004.xml")
data <- read_ipums_micro(ddi)
summary(data)


# Summarize population by state, birthplace, and year
state_birthplace_summary <- data %>%
  group_by(STATEFIP, BPL, YEAR) %>%
  summarize(
    Total_Pop = sum(PERWT, na.rm = TRUE)
  ) %>%
  arrange(YEAR, STATEFIP, desc(Total_Pop))

# Load state FIPS codes
state_codes <- read_csv("~/OneDrive - University of North Carolina at Chapel Hill/Spring_25/GEOG 456/GEOG456-Workspace/HW4/bf1acd2290e15b91e6710b6fd3be0a53-11d15233327c8080c9646c7e1f23052659db251d/us-state-ansi-fips.csv")

# Ensure proper formatting for merging
state_codes <- state_codes %>%
  mutate(st = as.integer(st))

# Merge state names into the summary table
state_birthplace_summary <- state_birthplace_summary %>%
  left_join(state_codes, by = c("STATEFIP" = "st")) %>%
  rename(State = stname)

# Filter non-U.S. birthplaces and unknown values
filtered_data <- state_birthplace_summary %>%
  filter(BPL > 89, BPL < 900, BPL != 99) %>%  # Keep only valid non-U.S. birthplaces
  group_by(State, YEAR) %>%
  slice_max(order_by = Total_Pop, n = 1, with_ties = FALSE) %>%  # Highest BPL per year
  ungroup() %>%
  mutate(
    recoded = case_when(
      BPL <= 200 ~ 1, #North America
      BPL > 200 & BPL <= 300 ~ 2, # South America
      BPL > 300 & BPL <= 499 ~ 3, # Europe
      BPL > 499 & BPL <= 599 ~ 4, # Asia
      BPL == 600 ~ 5, # Africa
      TRUE ~ NA_real_  # Assign NA to anything outside these ranges
    )) %>%
  select(State, YEAR, recoded)

# Reshape the data: Each state is a row, each YEAR is a column
reshaped_data <- filtered_data %>%
  pivot_wider(names_from = YEAR, values_from = recoded)


# Save to CSV
write_csv(reshaped_data, "reshaped_state_birthplace_summary.csv")
