library(tidyverse)
library(lubridate)
planes <- read_csv("cleaned_data/cleaned_data.csv")

counts_by_year <- planes %>%
    mutate(year = planes$formatted_date %>% isoyear()) %>%
    group_by(year) %>%
    count()
num_crashes_year <- ggplot(counts_by_year, aes(x = year, y = n)) +
    geom_point() +
    geom_smooth() +
    xlab("Year") +
    ylab("Number of Plane Crashes")

ggsave("figures/num_crashes_by_year.png", num_crashes_year)
