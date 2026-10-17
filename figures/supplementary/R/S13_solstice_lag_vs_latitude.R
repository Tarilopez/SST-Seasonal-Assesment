#!/usr/bin/env Rscript
# Figure S13 -- solstice-to-peak lag against absolute latitude: mean
# signed lag between the thermal maximum and the local summer solstice,
# all 81 sites, coloured by region, with bootstrap intervals.
source("theme_supp.R")

t2 <- read.csv(here_root("submission", "tables", "Table_S2_site_metrics.csv"), stringsAsFactors = FALSE)
t2$abs_lat <- abs(t2$lat)

p <- ggplot(t2, aes(abs_lat, solstice_peak_lag_days, colour = region)) +
  geom_hline(yintercept = 0, linetype = "dotted", colour = "black") +
  geom_errorbar(aes(ymin = solstice_peak_lag_ci_lo, ymax = solstice_peak_lag_ci_hi), width = 0, linewidth = 0.3, alpha = 0.6) +
  geom_point(size = 1.8) +
  scale_colour_region() +
  labs(x = "absolute latitude (deg)", y = "solstice-to-peak lag (days)") +
  theme(legend.position = "right", legend.key.size = unit(3, "mm"))

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS13_solstice_lag_vs_latitude.png"),
       p, width = 150, height = 105, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS13_solstice_lag_vs_latitude.pdf"),
       p, width = 150, height = 105, units = "mm")
cat("Wrote FigureS13_solstice_lag_vs_latitude.png/.pdf\n")
