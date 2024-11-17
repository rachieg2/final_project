library(maps)
library(ggplot2)
library(tidyverse)

planes <- read_csv("cleaned_data/cleaned_data.csv") %>%
    mutate(decade = (year(formatted_date) %/% 10) * 10)
planes$decade <- as.factor(planes$decade)

world_map <- map_data("world")

p <- ggplot() +
    coord_fixed() +
    xlab("") +
    ylab("")

# Add map to base plot
base_world_messy <- p + geom_polygon(
    data = world_map, aes(x = long, y = lat, group = group),
    colour = "black", fill = "white"
)

cleanup <-
    theme(
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white", colour = "white"),
        axis.line = element_line(colour = "white"), legend.position = "none",
        axis.ticks = element_blank(), axis.text.x = element_blank(),
        axis.text.y = element_blank()
    )

base_world <- base_world_messy + cleanup

map_data <-
    base_world +
    geom_point(
        data = planes,
        aes(x = longitude, y = latitude, fill = decade, color = decade, size = total_fatalities), pch = 21, alpha = I(0.7)
    )

ggsave("figures/map_crashes.png", map_data)
