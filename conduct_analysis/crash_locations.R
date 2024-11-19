library(maps)
library(ggplot2)
library(tidyverse)

planes <- read_csv("cleaned_data/cleaned_data.csv") %>%
    mutate(decade = (year(formatted_date) %/% 10) * 10)
planes$decade <- as.factor(planes$decade)

world_map <- map_data("world")


map_plot <- ggplot() +
    # Plot the world map
    geom_map(
        data = world_map, map = world_map, aes(map_id = region),
        fill = "gray90", color = "gray50"
    ) +
    # Plot the crash locations
    geom_point(
        data = planes, aes(x = longitude, y = latitude),
        alpha = 0.5, color = "blue"
    ) +
    # Facet by decade
    facet_wrap(~decade, ncol = 3)

ggsave("figures/map_crashes.png", map_plot, height = 30, width = 35, dpi = 300)
