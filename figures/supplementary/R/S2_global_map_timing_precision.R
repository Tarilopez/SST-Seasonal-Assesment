#!/usr/bin/env Rscript
# Figure S2 -- global map of timing precision: all 81 sites by longitude
# and latitude, coloured by circular SD of thermal peak timing.

source("theme_supp.R")

publication_theme <- theme_minimal() +
  theme(text = element_text(family = "Helvetica", size = 12),
        axis.title = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12),
        legend.title = element_text(size = 10, face = "bold"),
        legend.text = element_text(size = 10),
        strip.text = element_text(size = 12, face = "bold"),
        plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = "black", linewidth = 0.5))

setwd("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main")

t2 <- read.csv(here_root("submission", "tables", "Table_S2_site_metrics.csv"), stringsAsFactors = FALSE)

t2 <- read.csv("tables/Table_S2_site_metrics.csv",stringsAsFactors = FALSE)
t2$lon180 <- ifelse(t2$lon > 180, t2$lon - 360, t2$lon)

world <- map_data("world")

p <- ggplot() +
  geom_polygon(data = world, aes(long, lat, group = group), fill = "grey92", colour = "grey80", linewidth = 0.1) +
  geom_point(data = t2, aes(lon180, lat, colour = phase_sd_days), size = 2.5) +
  scale_colour_viridis_c(name = "Circular SD\n(days)", option = "mako", direction = -1, trans = "log10",
                          breaks = c(3, 6, 12, 24, 48)) +
  coord_quickmap(xlim = c(-180, 180), ylim = c(-45, 45)) +
  labs(y = "Latitude", x = "Longitude") +
  theme(panel.grid = element_line(colour = "grey95", linewidth = 0.4), legend.position = "right") + publication_theme; p

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS2_global_map_timing_precision.png"),
       p, width = 169, height = 95, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS2_global_map_timing_precision.pdf"),
       p, width = 169, height = 95, units = "mm")
cat("Wrote FigureS2_global_map_timing_precision.png/.pdf\n")
