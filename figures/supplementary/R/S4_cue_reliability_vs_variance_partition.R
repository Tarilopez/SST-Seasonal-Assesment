#!/usr/bin/env Rscript
# Figure S4 -- cue reliability against the variance partition: two panels,
# rho vs seasonal-cycle R^2 and rho vs the interannual-peak-SD/A1 ratio,
# 1982-2006, all 81 sites coloured by region.

#source("theme_supp.R")

source("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main/figures/supplementary/R/theme_supp.R")

suppressPackageStartupMessages(library(patchwork))

partition <- read.csv(here_root("extension", "checks4", "tables", "check4_1a_partition_measures.csv"), stringsAsFactors = FALSE)
s11a <- read.csv(here_root("submission", "tables", "Table_S11a_site_level_regressions.csv"), stringsAsFactors = FALSE)

partition <- read.csv("tables/check4_1a_partition_measures.csv", stringsAsFactors = FALSE)
s11a <- read.csv("tables/Table_S11a_site_level_regressions.csv", stringsAsFactors = FALSE)

fit_line <- function(df, xcol, coef_row) {
  xs <- seq(min(df[[xcol]]), max(df[[xcol]]), length.out = 50)
  b <- coef_row$coefficient
  a <- mean(df$rho_magnitude) - b * mean(df[[xcol]])  # anchor through the mean (naive OLS line for display)
  data.frame(x = xs, y = a + b * xs)
}

p1 <- ggplot(partition, aes(harmonicR2_pre2007, rho_magnitude, colour = region)) +
  geom_line(data = fit_line(partition, "harmonicR2_pre2007", s11a[1, ]), aes(x, y), inherit.aes = FALSE, colour = "black", 
            linewidth = 0.6, linetype = "dashed") +
  geom_point(size = 2) +
  scale_colour_region(guide = "none") +
  labs(x = "Seasonal-Cycle R2 (1982-2006)", y = "Cue reliability, rho", tag = "A"); p1

p2 <- ggplot(partition, aes(ratio_ii_pre2007, rho_magnitude, colour = region)) +
  geom_line(data = fit_line(partition, "ratio_ii_pre2007", s11a[2, ]), aes(x, y), inherit.aes = FALSE, colour = "black", 
            linewidth = 0.6, linetype = "dashed") +
  geom_point(size = 2) +
  scale_colour_region(guide = guide_legend(override.aes = list(size = 2))) +
  labs(x = "Interannual peak SD / A1", y = NULL, tag = "B");p2

final <- (p1 + p2 + plot_layout(guides = "collect")) &
  theme(legend.position = "right", legend.key.size = unit(3, "mm")); final

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS4_cue_reliability_vs_variance_partition.png"),
       final, width = 169, height = 85, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS4_cue_reliability_vs_variance_partition.pdf"),
       final, width = 169, height = 85, units = "mm")
cat("Wrote FigureS4_cue_reliability_vs_variance_partition.png/.pdf\n")
