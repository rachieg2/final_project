library(tidyverse)
library(lubridate)
planes <- read_csv("cleaned_data/cleaned_data.csv")

counts_by_year <- planes %>%
    mutate(
        year_month = floor_date(formatted_date, "month")
    ) %>%
    group_by(year_month) %>%
    count()

heatmap_over_time <- counts_by_year %>%
    mutate(year = year(year_month), month = month(year_month)) %>%
    ggplot(aes(x = year, y = month, fill = n)) +
    geom_tile() +
    scale_fill_gradient(low = "white", high = "red") +
    labs(x = "Year", y = "Month") +
    scale_y_continuous(expand = c(0, 0), limits = c(0, 13))



counts_by_year <- planes %>%
    mutate(
        year = year(formatted_date)
    ) %>%
    group_by(year) %>%
    count()

num_crashes_year <- ggplot(counts_by_year, aes(x = year, y = n)) +
    geom_point() +
    geom_smooth() +
    xlab("Year") +
    ylab("Number of Plane Crashes") +
    scale_y_continuous(expand = c(0, 0), limits = c(0, 90))

ggsave("figures/num_crashes_by_year.png", num_crashes_year)
ggsave("figures/heatmap_over_time.png", heatmap_over_time)
