#!/usr/bin/env Rscript
# Figure S12 -- photoperiod signal strength against seasonal thermal
# amplitude: annual daylength range vs A1, all 81 sites coloured by
# region, with the thermal timing-precision breakpoint marked.
source("theme_supp.R")

source("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main/figures/supplementary/R/theme_supp.R")

#t2 <- read.csv(here_root("submission", "tables", "Table_S2_site_metrics.csv"), stringsAsFactors = FALSE)
#hinge <- read.csv(here_root("submission", "tables", "Table_S8c_fitted_hinge_model.csv"), stringsAsFactors = FALSE)
#r_amp <- read.csv(here_root("extension", "axes81", "photoperiod", "tables", "photoperiod_02b_correlation_with_A1.csv"), stringsAsFactors = FALSE)

t2 <- read.csv("tables/Table_S2_site_metrics.csv", stringsAsFactors = FALSE)
hinge <- read.csv("tables/Table_S8c_fitted_hinge_model.csv", stringsAsFactors = FALSE)
r_amp <- read.csv("tables/photoperiod_02b_correlation_with_A1.csv", stringsAsFactors = FALSE)

p12 <- ggplot(t2, aes(A1_mean, daylength_range_h, colour = region)) +
  annotate("rect", xmin = hinge$ci_lo, xmax = hinge$ci_hi, ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.4) +
  geom_vline(xintercept = hinge$breakpoint, linetype = "dashed", colour = "black") +
  geom_point(size = 2) +
  scale_colour_region() +
  annotate("text", x = min(t2$A1_mean), y = max(t2$daylength_range_h), hjust = 0, vjust = 1, size = MIN_PT / .pt,
           label = sprintf("r=%.2f", r_amp$r)) +
  labs(x = "Amplitude, A1 (ºC)", y = "Annual daylength range (hours)")+
       #caption = "dashed line = thermal timing-precision breakpoint (Table S8c), not a threshold fit to this relationship.") +
  theme(legend.position = "right", legend.key.size = unit(3, "mm"), plot.caption = element_text(size = MIN_PT, hjust = 0));p12

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS12_photoperiod_vs_amplitude.png"),
       p, width = 150, height = 105, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS12_photoperiod_vs_amplitude.pdf"),
       p, width = 150, height = 105, units = "mm")
cat("Wrote FigureS12_photoperiod_vs_amplitude.png/.pdf\n")


final <- (p + p12 + plot_layout(guides = "collect")); final

