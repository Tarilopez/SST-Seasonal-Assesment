#!/usr/bin/env Rscript
# Figure S5 -- changepoint year distributions: three histogram panels for
# daily residual autocorrelation, annual residual variance, and seasonal
# amplitude.
source("theme_supp.R")
suppressPackageStartupMessages(library(patchwork))

#t2 <- read.csv(here_root("submission", "tables", "Table_S2_site_metrics.csv"), stringsAsFactors = FALSE)
#bins <- c(1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025)

setwd("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main")

source("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main/figures/supplementary/R/theme_supp.R")

t2 <- read.csv("tables/Table_S2_site_metrics.csv",stringsAsFactors = FALSE)
bins <- c(1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025)

make_hist <- function(col, title, letter, hist_color) {
  ggplot(t2, aes(x = .data[[col]])) +
    geom_histogram(breaks = bins, fill = hist_color, colour = "white", linewidth = 0.2) +
    scale_x_continuous(breaks = bins) +
    labs(x = "Changepoint year", y = "n sites", tag = letter, subtitle = title) +
    theme(plot.subtitle = element_text(size = MIN_PT, face = "bold"), axis.text.x = element_text(angle = 0, hjust = 1))
}

p1 <- make_hist("cp_lag1_ac", "Daily residual lag-1 AC", "A", "#CCE9F6")
p2 <- make_hist("cp_resid_var", "Annual residual variance", "B", "#93B9E8")
p3 <- make_hist("cp_A1", "Seasonal amplitude", "C","#3A71A4")

final <- p1 + p2 + p3 + plot_layout(nrow = 1); final

ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS5_changepoint_histograms.png"),
       final, width = 169, height = 75, units = "mm", dpi = 300)
ggsave(here_root("submission", "figures", "supplementary", "figures", "FigureS5_changepoint_histograms.pdf"),
       final, width = 169, height = 75, units = "mm")
cat("Wrote FigureS5_changepoint_histograms.png/.pdf\n")
