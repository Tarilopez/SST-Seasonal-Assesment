#!/usr/bin/env Rscript
# Figure S3 -- forest plots of pooled trends: one panel per axis (annual
# mean, seasonal amplitude, phase shift), one row per site grouped by
# region, with the overall pooled estimate and CI band.

region.colors.o<-c("#fcf6c4","#A8DA96","#5bd3b0","#16758b","#904653",
                   "#93B9E8","#3A71A4","#788dc9","#f37c78", "#eb5760FF", "#7b2382ff")

setwd("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main")

#source("theme_supp.R")

source("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main/figures/supplementary/R/theme_supp.R")

#suppressPackageStartupMessages(library(patchwork))

#t2 <- read.csv(here_root("submission", "tables", "Table_S2_site_metrics.csv"), stringsAsFactors = FALSE)
#s3 <- read.csv(here_root("submission", "tables", "Table_S3_pooled_estimates.csv"), stringsAsFactors = FALSE)
#s4 <- read.csv(here_root("submission", "tables", "Table_S4_mean_trend_by_region.csv"), stringsAsFactors = FALSE)

t2 <- read.csv("tables/Table_S2_site_metrics.csv",stringsAsFactors = FALSE)
s3 <- read.csv("tables/Table_S3_pooled_estimates.csv", stringsAsFactors = FALSE)
s4 <- read.csv("tables/Table_S4_mean_trend_by_region.csv", stringsAsFactors = FALSE)

library(patchwork)

region_order <- s4 %>% arrange(desc(pooled_trend)) %>% pull(region)
region_order <- c(region_order, setdiff(unique(t2$region), region_order))  # Eastern_Pacific (not pooled) at the end

site_order <- t2 %>% mutate(region = factor(region, levels = rev(region_order))) %>%
  arrange(region, desc(M_trend)) %>% pull(site_id)
t2$site_id <- factor(t2$site_id, levels = site_order)

make_forest <- function(site_col, site_lo, site_hi, overall_row, mult, xlab, letter, show_legend = FALSE) {
  overall <- s3[overall_row, ]

  ggplot(t2, aes(y = site_id, x = .data[[site_col]] * mult)) +
    annotate("rect", xmin = overall$ci_lo * mult, xmax = overall$ci_hi * mult, ymin = -Inf, ymax = Inf, fill = "grey70", alpha = 0.25) +
    geom_vline(xintercept = overall$pooled * mult, colour = "black", linewidth = 0.5) +
    geom_vline(xintercept = 0, colour = "black", linetype = "dotted", linewidth = 0.5) +
    geom_errorbar(aes(xmin = .data[[site_lo]] * mult, xmax = .data[[site_hi]] * mult, colour = region), width = 0, linewidth = 0.25, alpha = 0.6) +
    geom_point(aes(colour = region), size = 0.8) +
    scale_colour_region(guide = if (show_legend) guide_legend(override.aes = list(size = 2, linewidth = 0)) else "none") +
    #scale_colour_manual(values = region.colors.o, guide = if (show_legend)
     #                                           guide_legend(override.aes = list(size = 2, linewidth = 0)) else "none") +
     scale_y_discrete(labels = NULL) +
    labs(x = xlab, y = NULL, tag = letter) +
    theme(axis.ticks.y = element_blank())
}

p_M <- make_forest("M_trend", "M_trend_ci_lo", "M_trend_ci_hi", 1, 10,
                    expression("M trend (" * degree * C ~ decade^{-1} * ")"), "A")
p_A1 <- make_forest("A1_trend", "A1_trend_ci_lo", "A1_trend_ci_hi", 3, 10,
                     expression("A1 trend (" * degree * C ~ decade^{-1} * ")"), "B")
p_shift <- make_forest("phase_shift_days", "phase_shift_days_ci_lo", "phase_shift_days_ci_hi", 7, 1,
                        "Phase shift (days)", "C", show_legend = TRUE); p_shift

final <- (p_M + p_A1 + p_shift + plot_layout(nrow = 1, guides = "collect")) +
  plot_annotation(caption = paste(strwrap(
    "81 sites, grouped and coloured by region (see Tables S4-S6 for pooled values); dotted line = zero; solid line + grey band = overall pooled estimate and 95% CI.",
    width = 100), collapse = "\n")) &
  theme(plot.caption = element_text(size = MIN_PT, hjust = 0), legend.position = "right", legend.key.size = unit(3, "mm")); final

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS3_forest_plots_pooled_trends.png"),
       final, width = 169, height = 220, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS3_forest_plots_pooled_trends.pdf"),
       final, width = 169, height = 220, units = "mm")
cat("Wrote FigureS3_forest_plots_pooled_trends.png/.pdf\n")
