#!/usr/bin/env Rscript
# Figure S1 -- timing precision (circular SD of thermal peak day) vs
# seasonal amplitude, all 81 sites, coloured by region, with the fitted
# breakpoint model and its 95% CI band.
#
# Refits the hinge curve directly from Table S2's own A1_mean/phase_sd_days
# via the already-validated grid_search_breakpoint() (same code Figure 2
# panel D and Table S8c were built with) rather than reconstructing it from
# summary stats alone, since the stored breakpoint table doesn't carry the
# fitted intercept -- refitting guarantees the plotted curve is exactly
# consistent with Table S2's own data.
source("theme_supp.R")
source(here_root("submission", "figures", "main", "figure2", "R", "breakpoint.R"))

t2 <- read.csv(here_root("submission", "tables", "Table_S2_site_metrics.csv"), stringsAsFactors = FALSE)
hinge_ref <- read.csv(here_root("submission", "tables", "Table_S8c_fitted_hinge_model.csv"), stringsAsFactors = FALSE)

fit <- grid_search_breakpoint(t2$A1_mean, t2$phase_sd_days)
stopifnot(abs(fit$breakpoint - hinge_ref$breakpoint) < 0.01)  # consistency check against Table S8c

xs1 <- seq(min(t2$A1_mean), fit$breakpoint, length.out = 100)
xs2 <- seq(fit$breakpoint, max(t2$A1_mean), length.out = 100)
curve <- rbind(
  data.frame(x = xs1, y = fit$coef[1] + fit$coef[2] * xs1),
  data.frame(x = xs2, y = fit$coef[1] + fit$coef[2] * xs2 + fit$coef[3] * (xs2 - fit$breakpoint))
)

t2$unstable <- t2$phase_R < 0.8

p <- ggplot(t2, aes(A1_mean, phase_sd_days, colour = region)) +
  annotate("rect", xmin = hinge_ref$ci_lo, xmax = hinge_ref$ci_hi, ymin = -Inf, ymax = Inf, fill = "grey70", alpha = 0.25) +
  geom_vline(xintercept = fit$breakpoint, linetype = "dashed", colour = "grey40") +
  geom_line(data = curve, aes(x, y), inherit.aes = FALSE, colour = "black", linewidth = 0.7) +
  geom_point(data = filter(t2, !unstable), size = 1.8) +
  geom_point(data = filter(t2, unstable), aes(colour = region), shape = 21, fill = NA, size = 2.6, stroke = 1) +
  scale_x_log10(breaks = c(0.3, 0.5, 1, 2, 5)) +
  scale_colour_region() +
  annotate("text", x = min(t2$A1_mean) * 1.05, y = max(t2$phase_sd_days) * 0.95, hjust = 0, vjust = 1,
           size = MIN_PT / .pt, label = sprintf("breakpoint %.2f\n[%.2f,%.2f] degC", fit$breakpoint, hinge_ref$ci_lo, hinge_ref$ci_hi)) +
  labs(x = "A1 (degC)", y = "phase circular SD (days)",
       caption = sprintf("open markers: phase_R<0.8, n=%d", sum(t2$unstable))) +
  theme(plot.caption = element_text(size = MIN_PT, hjust = 0, face = "italic"), legend.position = "right")

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS1_timing_precision_vs_amplitude.png"),
       p, width = 169, height = 110, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS1_timing_precision_vs_amplitude.pdf"),
       p, width = 169, height = 110, units = "mm")
cat("Wrote FigureS1_timing_precision_vs_amplitude.png/.pdf\n")
