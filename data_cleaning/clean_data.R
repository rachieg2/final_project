library(tidyverse)
library(lubridate)
library(tidygeocoder)

plane_data <- read_csv("data/plane_data.csv")

# format dates and times
plane_data$formatted_date <- mdy(plane_data$Date)
plane_data$formatted_time <- plane_data$Time %>%
  as.numeric() %>%
  as.character() %>%
  # Pad with leading zeros to ensure all times are 4 characters long
  str_pad(width = 4, side = "left", pad = "0") %>%
  # Insert a colon between hours and minutes
  str_replace("(\\d{2})(\\d{2})", "\\1:\\2") %>%
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
plane_data <- plane_data %>%
  geocode(Location, method = "osm", lat = latitude, long = longitude)

write.csv(plane_data, "cleaned_data/cleaned_data.csv")
