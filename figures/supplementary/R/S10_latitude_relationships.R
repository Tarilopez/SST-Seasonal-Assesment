#!/usr/bin/env Rscript
# Figure S10 -- latitude relationships: three panels, timing precision vs
# |latitude|, amplitude vs |latitude|, timing precision vs amplitude, all
# coloured by region.
source("theme_supp.R")
source("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main/figures/supplementary/R/theme_supp.R")

suppressPackageStartupMessages(library(patchwork))

t2 <- read.csv(here_root("submission", "tables", "Table_S2_site_metrics.csv"), stringsAsFactors = FALSE)
t2$abs_lat <- abs(t2$lat)
s12 <- read.csv(here_root("submission", "tables", "Table_S12_latitude_relationships.csv"), stringsAsFactors = FALSE)

t2 <- read.csv("tables/Table_S2_site_metrics.csv", stringsAsFactors = FALSE)
t2$abs_lat <- abs(t2$lat)

s12 <- read.csv("tables/Table_S12_latitude_relationships.csv", stringsAsFactors = FALSE)

fit_line <- function(xcol, ycol, row) {
  xs <- seq(min(t2[[xcol]]), max(t2[[xcol]]), length.out = 50)
  data.frame(x = xs, y = row$ols_slope * xs + (mean(t2[[ycol]]) - row$ols_slope * mean(t2[[xcol]])))
}

p1 <- ggplot(t2, aes(abs_lat, phase_R, colour = region)) +
  geom_line(data = fit_line("abs_lat", "phase_R", s12[s12$y == "phase_R" & s12$x == "abs_lat", ]), aes(x, y), inherit.aes = FALSE, colour = "black") +
  geom_point(size = 2) + scale_colour_region(guide = "none") +
  labs(x = "Absolute latitude (deg)", y = "Timing precision (phase R)", tag = "A")

p2 <- ggplot(t2, aes(abs_lat, A1_mean, colour = region)) +
  geom_line(data = fit_line("abs_lat", "A1_mean", s12[s12$y == "A1" & s12$x == "abs_lat", ]), aes(x, y), inherit.aes = FALSE, colour = "black") +
  geom_point(size = 2) + scale_colour_region(guide = "none") +
  labs(x = "Absolute latitude (deg)", y = "Amplitude, A1 (degC)", tag = "B")

p3 <- ggplot(t2, aes(A1_mean, phase_R, colour = region)) +
  geom_line(data = fit_line("A1_mean", "phase_R", s12[s12$y == "phase_R" & s12$x == "A1", ]), aes(x, y), inherit.aes = FALSE, colour = "black") +
  geom_point(size = 2) + scale_colour_region(guide = guide_legend(override.aes = list(size = 2))) +
  labs(x = "Amplitude, A1 (degC)", y = "Timing precision (phase R)", tag = "C")

final <- (p1 + p2 + p3 + plot_layout(nrow = 1, guides = "collect")) &
  theme(legend.position = "right", legend.key.size = unit(3, "mm")); final

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS10_latitude_relationships.png"),
       final, width = 169, height = 80, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS10_latitude_relationships.pdf"),
       final, width = 169, height = 80, units = "mm")
cat("Wrote FigureS10_latitude_relationships.png/.pdf\n")
