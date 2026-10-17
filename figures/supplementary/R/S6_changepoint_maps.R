#!/usr/bin/env Rscript
# Figure S6 -- geographic distribution of changepoint years: two world
# maps, sites coloured by detected changepoint year for daily residual
# autocorrelation and for seasonal amplitude.
source("theme_supp.R")
suppressPackageStartupMessages(library(patchwork))

t2 <- read.csv(here_root("submission", "tables", "Table_S2_site_metrics.csv"), stringsAsFactors = FALSE)
t2$lon180 <- ifelse(t2$lon > 180, t2$lon - 360, t2$lon)
world <- map_data("world")

make_map <- function(col, title, letter) {
  ggplot() +
    geom_polygon(data = world, aes(long, lat, group = group), fill = "grey92", colour = "grey80", linewidth = 0.1) +
    geom_point(data = t2, aes(lon180, lat, colour = factor(.data[[col]])), size = 1.8) +
    scale_colour_manual(values = c("1987" = "#56B4E9", "1992" = "#009E73", "1997" = "#F0E442", "2002" = "#E69F00",
                                    "2007" = "#D55E00", "2012" = "#CC79A7", "2017" = "#000000", "2022" = "#0072B2"),
                         name = "changepoint\nyear") +
    coord_quickmap(xlim = c(-180, 180), ylim = c(-45, 45)) +
    labs(x = NULL, y = NULL, tag = letter, subtitle = title) +
    theme(panel.grid = element_line(colour = "grey95", linewidth = 0.2), legend.position = "right",
          plot.subtitle = element_text(size = MIN_PT, face = "bold"), legend.key.size = unit(3, "mm"))
}

p1 <- make_map("cp_lag1_ac", "daily residual lag-1 AC", "A")
p2 <- make_map("cp_A1", "seasonal amplitude", "B")

final <- p1 / p2

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS6_changepoint_maps.png"),
       final, width = 169, height = 150, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS6_changepoint_maps.pdf"),
       final, width = 169, height = 150, units = "mm")
cat("Wrote FigureS6_changepoint_maps.png/.pdf\n")
