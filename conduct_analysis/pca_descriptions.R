library(tidyverse)
descriptions <- read_csv("cleaned_data/plane_description_counts.csv")
planes <- read_csv("cleaned_data/cleaned_data.csv")

planes_smaller <- planes %>%
    mutate(decade = (year(formatted_date) %/% 10) * 10) %>%
    select("...1", Operator, decade)
full_info <- descriptions %>% left_join(planes_smaller,
    by = join_by(Crash_NUM == "...1")
)
d_matrix <- full_info %>%
    select(-Crash_NUM, -Operator, -decade) %>%
    as.matrix()

pca <- prcomp(d_matrix, center = T)

pca_decade <- ggplot(pca$x %>% as_tibble(), aes(PC1, PC2)) +
    geom_point(aes(color = factor(full_info$decade))) +
    scale_color_discrete(name = "Decade")

ggsave("figures/pca_decade.png", pca_decade)
