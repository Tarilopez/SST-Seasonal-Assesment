#!/usr/bin/env Rscript
# Figure S7 -- marine heatwave duration, fixed against trend-following
# baseline: scatter of per-site fixed-baseline against trend-following-
# baseline duration change, all 81 sites, with a one-to-one reference line.
source("theme_supp.R")

source("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main/figures/supplementary/R/theme_supp.R")

#d <- read.csv(here_root("extension", "checks", "tables", "check2d_fixed_vs_moving_merged.csv"), stringsAsFactors = FALSE)

d <- read.csv("tables/check2d_fixed_vs_moving_merged.csv", stringsAsFactors = FALSE)

lims <- range(c(d$fixed_baseline_effect, d$moving_baseline_effect))

p <- ggplot(d, aes(fixed_baseline_effect, moving_baseline_effect, colour = region)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey40") +
  geom_point(size = 2) +
  scale_colour_region() +
  coord_equal(xlim = lims, ylim = lims) +
  labs(x = "Fixed-Baseline duration change (days)", y = "Trend-Following-baseline duration change (days)") +
  theme(legend.position = "none", legend.key.size = unit(3, "mm"));p

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS7_mhw_fixed_vs_trend_baseline.png"),
       p, width = 150, height = 110, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS7_mhw_fixed_vs_trend_baseline.pdf"),
       p, width = 150, height = 110, units = "mm")
cat("Wrote FigureS7_mhw_fixed_vs_trend_baseline.png/.pdf\n")
