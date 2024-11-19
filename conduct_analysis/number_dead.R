library(tidyverse)
planes <- read_csv("cleaned_data/cleaned_data.csv")

# First, get proportions of passenger/crew/total fatalities vs aboard
perc_dead_info <- planes %>%
    mutate(
        perc_dead = total_fatalities / total_aboard,
        perc_passengers_dead = passengers_fatalities / passengers_aboard,
        perc_crew_dead = crew_fatalities / crew_aboard,
        diff_perc = perc_passengers_dead - perc_crew_dead
    ) %>%
    select("formatted_date", "perc_dead", "perc_passengers_dead", "perc_crew_dead", "diff_perc") %>%
    pivot_longer(cols = c("perc_dead", "perc_passengers_dead", "perc_crew_dead", "diff_perc")) %>%
    filter(value <= 1) %>%
    mutate(
        name = factor(name, levels = c("perc_dead", "perc_passengers_dead", "perc_crew_dead")),

        # Rename the labels to be more descriptive
        name = recode(name,
            perc_dead = "Percentage Aboard Dead",
            perc_passengers_dead = "Percentage of Passengers Dead",
            perc_crew_dead = "Percentage of Crew Dead"
        )
    )

perc_dead_plot <- perc_dead_info %>%
    filter(!is.na(name)) %>%
    ggplot(aes(y = value, x = name)) +
    geom_violin() +
    xlab("Fatality Statistic") +
    ylab("Percentage Dead")

diff_perc_dead <- perc_dead_info %>%
    filter(is.na(name)) %>%
    mutate(name = "") %>%
    ggplot(aes(y = value, x = name)) +
    geom_violin() +
    xlab("") +
    ylab("Difference in Percentage Between Passenger and Crew Deaths")

max_killed <- max(planes$Ground, na.rm = TRUE)
planes$highlight <- ifelse(planes$Ground == max_killed, "highlight", "normal")
planes$highlight <- planes$highlight
textdf <- planes[planes$Ground == max_killed, ] %>% drop_na()
mycolours <- c("highlight" = "red", "normal" = "grey50")

number_killed_ground_plot <- ggplot(planes, aes(y = Ground, x = formatted_date)) +
    geom_point(size = 3, aes(colour = highlight)) +
    scale_color_manual("Status", values = mycolours) +
    geom_text(data = textdf, aes(x = formatted_date, y = Ground - 50, label = "September 11 Attacks")) +
    theme(legend.position = "none") +
    ylab("Number of People Killed on the Ground") +
    xlab("Date")

ggsave("figures/perc_dead_plot.png", perc_dead_plot)
ggsave("figures/number_killed_ground_plot.png", number_killed_ground_plot)
ggsave("figures/diff_perc_death.png", diff_perc_dead)
