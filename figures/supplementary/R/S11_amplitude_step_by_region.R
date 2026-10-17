#!/usr/bin/env Rscript
# Figure S11 -- amplitude step magnitude by region: one row per region
# sorted by mean fitted step at 2007, individual site values shown, with
# regional means and a zero reference line.
source("theme_supp.R")

step_site <- read.csv(here_root("extension", "axes81", "checks", "tables", "checkA_per_site_step_models.csv"), stringsAsFactors = FALSE)
region_mean <- read.csv(here_root("submission", "tables", "Table_S13b_amplitude_step_by_region.csv"), stringsAsFactors = FALSE)

region_order <- region_mean %>% arrange(mean_step_degC) %>% pull(region)
step_site$region <- factor(step_site$region, levels = region_order)
region_mean$region <- factor(region_mean$region, levels = region_order)

p <- ggplot(step_site, aes(x = step1_b2, y = region, colour = region)) +
  geom_vline(xintercept = 0, linetype = "dotted", colour = "black") +
  geom_jitter(height = 0.15, size = 1.4, alpha = 0.7) +
  geom_point(data = region_mean, aes(x = mean_step_degC, y = region), inherit.aes = FALSE,
             shape = 18, size = 3.5, colour = "black") +
  scale_colour_region(guide = "none") +
  scale_y_discrete(labels = function(r) REGION_LABELS[as.character(r)]) +
  labs(x = "fitted step magnitude at 2007 (degC)", y = NULL,
       caption = "small points: individual sites; black diamond: regional mean.") +
  theme(plot.caption = element_text(size = MIN_PT, hjust = 0))

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS11_amplitude_step_by_region.png"),
       p, width = 150, height = 110, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS11_amplitude_step_by_region.pdf"),
       p, width = 150, height = 110, units = "mm")
cat("Wrote FigureS11_amplitude_step_by_region.png/.pdf\n")
