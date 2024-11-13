library(tidyverse)
library(lubridate)
library(tidygeocoder)

plane_data <- read_csv("data/plane_data.csv")

# Make sure there are no duplicates (there aren't.)
plane_data <- plane_data %>% distinct()

# format dates and times
plane_data$formatted_date <- mdy(plane_data$Date)
plane_data$formatted_time <- str_replace(as.character(plane_data$Time), "^c:{0,1}\\s{0,1}", "")
plane_data$formatted_time <- str_replace(as.character(plane_data$formatted_time), "Z", "")
plane_data$formatted_time <- str_replace(as.character(plane_data$formatted_time), ";", ":")
plane_data$formatted_time <- str_replace(as.character(plane_data$formatted_time), "\\.0", "")
plane_data$formatted_time <- plane_data$formatted_time %>%
  as.character() %>%
  # Pad with leading zeros to ensure all times are 4 characters long
  str_pad(width = 4, side = "left", pad = "0") %>%
  # Insert a colon between hours and minutes
  str_replace("(\\d{2})(\\d{2})", "\\1:\\2") %>%
  # force a fix on 3 problematic times
  str_replace("^00:7$", "07:00") %>%
  str_replace("01:75", "17:50") %>%
  str_replace("^11:3$", "11:30") %>%
  # Parse as time in 24-hour format
  parse_time(format = "%H:%M")

# Format the aboard information
plane_data <- plane_data %>%
  mutate(
    # Extract the total number before the parentheses
    total_aboard = as.numeric(str_extract(Aboard, "^\\d+")),
    # Extract the passengers count
    passengers_aboard = as.numeric(str_extract(Aboard, "(?<=passengers:)\\d+")),
    # Extract the crew count
    crew_aboard = as.numeric(str_extract(Aboard, "(?<=crew:)\\d+"))
  )

# Format the fatalities information
plane_data <- plane_data %>%
  mutate(
    # Extract the total number before the parentheses
    total_fatalities = as.numeric(str_extract(Fatalities, "^\\d+")),
    # Extract the passengers count
    passengers_fatalities = as.numeric(str_extract(Fatalities, "(?<=passengers:)\\d+")),
    # Extract the crew count
    crew_fatalities = as.numeric(str_extract(Fatalities, "(?<=crew:)\\d+"))
  )

# Get lat/lons as much as possible for locations
# replace terms like "near, over, off, X miles" to try to get estimates
plane_data$fixed_location <- plane_data$Location %>%
  str_replace("O{0,1}o{0,1}ff{0,1}", "") %>%
  str_replace("N{0,1}n{0,1}ear", "") %>%
  str_replace("O{0,1}o{0,1}ver", "") %>%
  str_replace("^\\d\\,{0,1}\\d{1,3} (?:miles){0,1}(?:nm){0,1} [A-X]{0,3}", "") %>%
  str_squish()

# only locations left as na are from the ussr
plane_data <- plane_data %>%
  geocode(Location, method = "arcgis", lat = latitude, long = longitude)

# Now, just run the "fixed" locations for lat/lons that were not found originally
na_location <- plane_data %>%
  filter(is.na(latitude)) %>%
  select(-latitude, -longitude) %>%
  geocode(fixed_location, method = "arcgis", lat = latitude, long = longitude) %>%
  select(c(latitude, longitude, Date, Location))

df_filled <- plane_data %>%
  left_join(na_location, by = c("Date", "Location"), suffix = c("", "_filled_data")) %>%
  mutate(
    latitude = if_else(is.na(latitude), latitude_filled_data, latitude),
    longitude = if_else(is.na(longitude), longitude_filled_data, longitude)
  ) %>%
  select(-latitude_filled_data, -longitude_filled_data)

dir.create("/home/rstudio/work/cleaned_data", showWarnings = FALSE)
write.csv(df_filled, "cleaned_data/cleaned_data.csv")
