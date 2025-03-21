library(ipumsr)
library(dplyr)
library(readr)
library(tidyverse)
library(jsonlite)

ddi <- read_ipums_ddi("usa_00004.xml")
data <- read_ipums_micro(ddi)
summary(data)

# --- 1. Summarize and merge state information ---

state_birthplace_summary <- data %>%
  group_by(STATEFIP, BPL, YEAR) %>%
  summarize(
    Total_Pop = sum(PERWT, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(YEAR, STATEFIP, desc(Total_Pop))

# Load state FIPS codes and merge state names
state_codes <- read_csv("~/OneDrive - University of North Carolina at Chapel Hill/Spring_25/GEOG 456/GEOG456-Workspace/HW4/bf1acd2290e15b91e6710b6fd3be0a53-11d15233327c8080c9646c7e1f23052659db251d/us-state-ansi-fips.csv") %>%
  mutate(st = as.integer(st))
state_birthplace_summary <- state_birthplace_summary %>%
  left_join(state_codes, by = c("STATEFIP" = "st")) %>%
  rename(State = stname)

# --- 2. Create the lookup table for non-U.S. BPL codes (BPL < 800) ---
bpl_lookup <- tribble(
  ~BPL, ~Country,
  150, "Canada",
  155, "St. Pierre and Miquelon",
  160, "Atlantic Islands",
  199, "North America, ns",
  200, "Mexico",
  210, "Central America",
  250, "Cuba",
  260, "West Indies",
  299, "Americas, n.s.",
  300, "SOUTH AMERICA",
  400, "Denmark",
  401, "Finland",
  402, "Iceland",
  403, "Lapland, n.s.",
  404, "Norway",
  405, "Sweden",
  410, "England",
  411, "Scotland",
  412, "Wales",
  413, "United Kingdom, ns",
  414, "Ireland",
  419, "Northern Europe, ns",
  420, "Belgium",
  421, "France",
  422, "Liechtenstein",
  423, "Luxembourg",
  424, "Monaco",
  425, "Netherlands",
  426, "Switzerland",
  429, "Western Europe, ns",
  430, "Albania",
  431, "Andorra",
  432, "Gibraltar",
  433, "Greece",
  434, "Italy",
  435, "Malta",
  436, "Portugal",
  437, "San Marino",
  438, "Spain",
  439, "Vatican City",
  440, "Southern Europe, ns",
  450, "Austria",
  451, "Bulgaria",
  452, "Czechoslovakia",
  453, "Germany",
  454, "Hungary",
  455, "Poland",
  456, "Romania",
  457, "Yugoslavia",
  458, "Central Europe, ns",
  459, "Eastern Europe, ns",
  460, "Estonia",
  461, "Latvia",
  462, "Lithuania",
  463, "Baltic States, ns",
  465, "Other USSR/Russia",
  499, "Europe, ns",
  500, "China",
  501, "Japan",
  502, "Korea",
  509, "East Asia, ns",
  510, "Brunei",
  511, "Cambodia (Kampuchea)",
  512, "Indonesia",
  513, "Laos",
  514, "Malaysia",
  515, "Philippines",
  516, "Singapore",
  517, "Thailand",
  518, "Vietnam",
  519, "Southeast Asia, ns",
  520, "Afghanistan",
  521, "India",
  522, "Iran",
  523, "Maldives",
  524, "Nepal",
  530, "Bahrain",
  531, "Cyprus",
  532, "Iraq",
  533, "Iraq/Saudi Arabia",
  534, "Israel/Palestine",
  535, "Jordan",
  536, "Kuwait",
  537, "Lebanon",
  538, "Oman",
  539, "Qatar",
  540, "Saudi Arabia",
  541, "Syria",
  542, "Turkey",
  543, "United Arab Emirates",
  544, "Yemen Arab Republic (North)",
  545, "Yemen, PDR (South)",
  546, "Persian Gulf States, n.s.",
  547, "Middle East, ns",
  548, "Southwest Asia, nec/ns",
  549, "Asia Minor, ns",
  550, "South Asia, nec",
  599, "Asia, nec/ns"
)

# --- 3. Recode BPL to country and filter out BPL values >= 800 ---
recoded_data <- state_birthplace_summary %>%
  filter(BPL < 800) %>%
  mutate(country = case_when(
    # U.S. birthplaces: typical codes for the U.S. (BPL < 90) and specific territory codes
    BPL < 90 ~ "Native Born",
    BPL %in% c(99, 100, 105, 110, 115, 120) ~ "Native Born",
    # Non-U.S. birthplaces: use the lookup table to get the country name
    TRUE ~ as.character(bpl_lookup$Country[match(BPL, bpl_lookup$BPL)])
  ))

# --- 4. Aggregate data: keep every state, year, and country entry with its population ---
final_summary <- recoded_data %>%
  group_by(State, YEAR, country) %>%
  summarize(Population = sum(Total_Pop, na.rm = TRUE), .groups = "drop") %>%
  arrange(State, YEAR, desc(Population))

# --- 5. Nest the data so that each row is a state with all its associated data ---
state_data_nested <- final_summary %>%
  group_by(State) %>%
  nest(data = c(YEAR, country, Population))

# --- 6. Convert the nested data frame to JSON ---
json_output <- toJSON(state_data_nested, pretty = TRUE)

# write the JSON to a file
write(json_output, file = "state_birthplace_nested.json")

