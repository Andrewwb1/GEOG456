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

# Convert the cleaned data to JSON
state_birthplace_summary_json <- toJSON(state_birthplace_summary, pretty = TRUE)

# Save directly to a JSON file
write(state_birthplace_summary_json, file = "state_birthplace_summary.json")

# Print a preview of the JSON output
head(state_birthplace_summary_json)
