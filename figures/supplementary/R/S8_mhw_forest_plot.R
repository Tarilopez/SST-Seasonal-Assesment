#!/usr/bin/env Rscript
# Figure S8 -- marine heatwave duration forest plot: one row per site
# grouped by region, with regional and global pooled estimates (fixed
# 1982-2011 baseline, Hobday convention).
source("theme_supp.R")

site_eff <- read.csv(here_root("extension", "tables", "taskE4_mhw_duration_effects.csv"), stringsAsFactors = FALSE)
region_eff <- read.csv(here_root("submission", "tables", "Table_S16b_mhw_by_region.csv"), stringsAsFactors = FALSE)
overall <- read.csv(here_root("submission", "tables", "Table_S16a_mhw_pooled_overall.csv"), stringsAsFactors = FALSE)[1, ]

region_order <- region_eff %>% arrange(desc(fixed_baseline_days)) %>% pull(region)
site_order <- site_eff %>% mutate(region = factor(region, levels = rev(region_order))) %>%
  arrange(region, desc(effect)) %>% pull(site_id)
site_eff$site_id <- factor(site_eff$site_id, levels = site_order)

p <- ggplot(site_eff, aes(y = site_id, x = effect, colour = region)) +
  annotate("rect", xmin = overall$ci_lo, xmax = overall$ci_hi, ymin = -Inf, ymax = Inf, fill = "grey70", alpha = 0.25) +
  geom_vline(xintercept = overall$pooled_effect_days, colour = "black", linewidth = 0.4) +
  geom_vline(xintercept = 0, colour = "black", linetype = "dotted", linewidth = 0.4) +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0, linewidth = 0.25, alpha = 0.6) +
  geom_point(size = 0.9) +
  scale_colour_region(guide = guide_legend(override.aes = list(size = 2, linewidth = 0))) +
  scale_y_discrete(labels = NULL) +
  labs(x = "MHW duration change, first vs last block (days)", y = NULL,
       caption = "81 sites, grouped and coloured by region; fixed 1982-2011 baseline (Hobday convention).") +
  theme(axis.ticks.y = element_blank(), legend.position = "right", legend.key.size = unit(3, "mm"),
        plot.caption = element_text(size = MIN_PT, hjust = 0))

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS8_mhw_forest_plot.png"),
       p, width = 140, height = 200, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS8_mhw_forest_plot.pdf"),
       p, width = 140, height = 200, units = "mm")
cat("Wrote FigureS8_mhw_forest_plot.png/.pdf\n")
