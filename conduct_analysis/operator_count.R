library(tidyverse)
library(lubridate)
planes <- read_csv("cleaned_data/cleaned_data.csv")


top_operator_by_year <- planes %>%
    mutate(decade = (year(formatted_date) %/% 10) * 10) %>%
    count(Operator, decade, name = "total_count") %>% # Get counts per operator and decade
    group_by(decade) %>% # Group by decade only
    slice_max(order_by = total_count, n = 1) %>% # Pick top operator per decade
    ungroup() %>%
    filter(decade != 2020) %>%
    filter(!is.na(Operator))

top_operators_plot <- ggplot(top_operator_by_year, aes(x = as.factor(decade), y = total_count, fill = Operator)) +
    geom_bar(stat = "identity", show.legend = FALSE) + # Bar plot without legend
    geom_text(aes(label = str_wrap(Operator)),
        position = position_stack(vjust = 0.5),
        color = "black", size = 2
    ) +
    labs(
        x = "Decade",
        y = "Number of Fatal Accidents"
    ) +
    scale_y_continuous(expand = c(0, 0), limits = c(0, 85))

ggsave("figures/operators_most_crashes.png", top_operators_plot)
