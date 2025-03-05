library(ipumsr)
library(dplyr)
library(readr)
library(tidyverse)

ddi <- read_ipums_ddi("usa_00004.xml")
data <- read_ipums_micro(ddi)


# Summarize population by state, birthplace, and year
state_birthplace_summary <- data %>%
  group_by(STATEFIP, BPL, YEAR) %>%
  summarize(Total_Pop = sum(PERWT, na.rm = TRUE), .groups = "drop") %>%
  arrange(YEAR, STATEFIP, desc(Total_Pop))


# Load state FIPS codes
state_codes <- read_csv("~/OneDrive - University of North Carolina at Chapel Hill/Spring_25/GEOG 456/GEOG456-Workspace/HW4/bf1acd2290e15b91e6710b6fd3be0a53-11d15233327c8080c9646c7e1f23052659db251d/us-state-ansi-fips.csv")

# Ensure proper formatting for merging
state_codes <- state_codes %>%
  mutate(st = as.integer(st))

# Merge state names into the summary table
state_birthplace_summary <- state_birthplace_summary %>%
  mutate(STATEFIP = as.integer(STATEFIP)) %>%
  left_join(state_codes, by = c("STATEFIP" = "st")) %>%
  rename(State = stname)

# Filter non-U.S. birthplaces and unknown values
filtered_data <- state_birthplace_summary %>%
  filter(BPL > 89, BPL < 900, BPL != 99) %>%  # Keep only valid non-U.S. birthplaces
  group_by(State, YEAR) %>%
  slice_max(order_by = Total_Pop, n = 5, with_ties = FALSE) %>%  # Keep top 5 per year
  mutate(Rank = row_number()) %>%  # Assign rank from 1 to 5
  ungroup()

filtered_data <- filtered_data %>%
  mutate(
    recoded = case_when(
      Rank == 1 & BPL <= 200 ~ 1,  # North America
      Rank == 1 & BPL > 200 & BPL <= 300 ~ 2,  # South America
      Rank == 1 & BPL > 300 & BPL <= 499 ~ 3,  # Europe
      Rank == 1 & BPL > 499 & BPL <= 599 ~ 4,  # Asia
      Rank == 1 & BPL == 600 ~ 5,  # Africa
      Rank == 1 ~ NA_real_,  # Assign NA for anything outside these ranges
      TRUE ~ NA_real_  # Other ranks get NA for recoded
    )
  )

# Reshape the data: Each state is a row, each YEAR is a column
reshaped_data <- filtered_data %>%
  pivot_wider(names_from = Rank, values_from = c(BPL, Total_Pop), 
              names_glue = "{.value}_Rank{Rank}")  # Creates BPL_Rank1, Total_Pop_Rank1, etc.

reshaped_data <- reshaped_data %>%
  select(State, YEAR, recoded, everything())

# Save to CSV
write_csv(reshaped_data, "reshaped_state_birthplace_summary.csv")
