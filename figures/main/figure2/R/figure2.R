#!/usr/bin/env Rscript
# =============================================================================
# Figure 2 -- R port of the Python/matplotlib original.
#
# Four axes of seasonal thermal structure across 81 reef sites (mean trend,
# amplitude trend, phase shift, timing-precision-vs-amplitude threshold,
# regional shift-vs-envelope calibration, cue reliability).
#
# Inputs are the per-SITE derived metrics already computed and validated by
# this project's Python pipeline (harmonic fitting, bootstrap trend tests,
# circular statistics -- see ../README.md for exactly which upstream Python
# scripts produced each input file). This script performs, in R, everything
# from that point forward: region-level random-effects pooling
# (DerSimonian-Laird), the breakpoint model (grid-search + bootstrap CI,
# validated against synthetic data first), the panel E derived join, and
# the figure itself.
#
# Usage: Rscript R/figure2.R   (run from the r_figure2/ project root)
# =============================================================================

setwd("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main/figures/main/figure2")

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(patchwork)
  library(ggrepel)
  library(scales)
})

here <- function(...) file.path(getwd(), ...)
source(here("R", "pooling.R"))
source(here("R", "breakpoint.R"))

MIN_PT <- 14
theme_set(
  theme_bw(base_size = MIN_PT) +
    theme(
      panel.grid = element_blank(),
      axis.text = element_text(size = MIN_PT, colour = "black"),
      axis.title = element_text(size = MIN_PT, colour = "black"),
      plot.title = element_blank()
    )
)

BLUE <- "#025F9B"    # Okabe-Ito; matches figure2's SINGLE_COLOR / below-breakpoint inset trace
PURP <- "#837AAE"  # Okabe-Ito; matches figure2's above-breakpoint inset trace
GREEN <- "#5bd3b0"   # Okabe-Ito; matches figure2 panel F


REGION_LABELS <- c(
  Western_Atlantic_Caribbean_Brazil = "Western Atlantic & Caribbean",
  Red_Sea_Persian_Gulf = "Red Sea & Persian Gulf",
  Coral_Triangle_SE_Asia = "Coral Triangle & SE Asia",
  South_Central_Pacific_Polynesia = "South Central Pacific",
  Eastern_Atlantic_West_Africa = "Eastern Atlantic & West Africa",
  Western_Central_Pacific = "Western & Central Pacific",
  Central_Indian_Ocean = "Central Indian Ocean",
  Western_Indian_Ocean = "Western Indian Ocean",
  Australia = "Australia",
  Eastern_Pacific = "Eastern Pacific",
  ORIGINAL_9 = "Focal subset"
)

publication_theme <- theme_classic() +
  theme(text = element_text(family = "Helvetica", size = 12),
        axis.title = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12),
        legend.title = element_text(size = 10, face = "bold"),
        legend.text = element_text(size = 10),
        strip.text = element_text(size = 12, face = "bold"),
        plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = "black", linewidth = 0.5))

# ============================================================================
# 1. Validate the breakpoint estimator before trusting it on real data
# ============================================================================
bp_validation <- validate_breakpoint_method()
stopifnot("breakpoint method failed synthetic validation" = bp_validation$passed)

# ============================================================================
# 2. Load per-site data and pool by region (panels A, B, C, F)
# ============================================================================
trends <- read.csv(here("data", "site_trends_M_A1.csv"), stringsAsFactors = FALSE)
shift <- read.csv(here("data", "site_phase_shift.csv"), stringsAsFactors = FALSE)
phase_sd <- read.csv(here("data", "site_phase_sd_A1.csv"), stringsAsFactors = FALSE)
rho <- read.csv(here("data", "site_rho.csv"), stringsAsFactors = FALSE)

prep <- function(df, effect_col, lo_col, hi_col) {
  out <- df[, c("site_id", "region", effect_col, lo_col, hi_col)]
  names(out) <- c("site_id", "region", "effect", "ci_lo", "ci_hi")
  out
}

m_site <- prep(trends[trends$axis == "M", ], "slope", "slope_ci_lo", "slope_ci_hi")
a1_site <- prep(trends[trends$axis == "A1", ], "slope", "slope_ci_lo", "slope_ci_hi")
shift_site <- prep(shift, "shift_days", "shift_ci_lo", "shift_ci_hi")
rho_site <- prep(rho, "rho_magnitude", "rho_magnitude_ci_lo", "rho_magnitude_ci_hi")

pool_M <- pool_by_region(m_site)
pool_A1 <- pool_by_region(a1_site)
pool_shift <- pool_by_region(shift_site)
pool_rho <- pool_by_region(rho_site)

cat(sprintf("Pooled M trend (all 81 sites, deg C/yr): %.5f [%.5f, %.5f]\n",
            pool_M$overall$pooled, pool_M$overall$ci_lo, pool_M$overall$ci_hi))
cat(sprintf("Pooled A1 trend, naive (all 81 sites, deg C/yr): %.5f [%.5f, %.5f]\n",
            pool_A1$overall$pooled, pool_A1$overall$ci_lo, pool_A1$overall$ci_hi))
cat(sprintf("Pooled phase shift (all 81 sites, days): %.4f [%.4f, %.4f]\n",
            pool_shift$overall$pooled, pool_shift$overall$ci_lo, pool_shift$overall$ci_hi))
cat(sprintf("Pooled rho (all 81 sites): %.4f [%.4f, %.4f]\n",
            pool_rho$overall$pooled, pool_rho$overall$ci_lo, pool_rho$overall$ci_hi))

# Row order for panels A-C: by panel A's (M) pooled regional estimate,
# descending, EXCLUDING Eastern_Pacific (n=2, cannot be pooled -- dropped
# from A-C entirely per the approved design; retained in panel F where
# Check 1's own rho estimator gives it a valid CI even at n=2).
order_ABC <- pool_M$by_region %>%
  filter(region != "Eastern_Pacific") %>%
  arrange(desc(pooled)) %>%
  pull(region)

make_forest_panel <- function(region_df, overall, order, mult = 1, xlab, letter) {
  df <- region_df %>%
    filter(region %in% order) %>%
    mutate(region_label = REGION_LABELS[region],
           region_f = factor(region, levels = rev(order)),
           pooled = pooled * mult, ci_lo = ci_lo * mult, ci_hi = ci_hi * mult)
  band <- data.frame(ci_lo = overall$ci_lo * mult, ci_hi = overall$ci_hi * mult)

  ggplot(df, aes(y = region_f, x = pooled)) +
    geom_rect(data = band, inherit.aes = FALSE,
              aes(xmin = ci_lo, xmax = ci_hi, ymin = -Inf, ymax = Inf),
              fill = "grey70", alpha = 0.3) +
    geom_vline(xintercept = overall$pooled * mult, colour = "black", linewidth = 0.4) +
    geom_vline(xintercept = 0, colour = "black", linewidth = 0.55, linetype = "dotted") +
    geom_errorbar(aes(xmin = ci_lo, xmax = ci_hi), width = 0, orientation = "y", colour = PURP, linewidth = 0.45) +
    geom_point(colour = PURP, size = 1.6) +
    scale_y_discrete(labels = function(r) REGION_LABELS[r]) +
    labs(x = xlab, y = NULL, tag = letter) + publication_theme +
    theme(plot.tag = element_text(size = 10, face = "bold"),
          plot.tag.position = c(0.02, 0.98))
}

panel_A <- make_forest_panel(pool_M$by_region, pool_M$overall, order_ABC, mult = 10,
                              xlab = expression("M trend (" * degree * C ~ decade^{-1} * ")"), letter = "A")
panel_B <- make_forest_panel(pool_A1$by_region, pool_A1$overall, order_ABC, mult = 10,
                              xlab = expression("A1 trend, naive (" * degree * C ~ decade^{-1} * ")"), letter = "B") +
  theme(axis.text.y = element_blank())
panel_C <- make_forest_panel(pool_shift$by_region, pool_shift$overall, order_ABC, mult = 1,
                              xlab = "phase shift, first vs\nlast 15 yr (days)", letter = "C") +
  theme(axis.text.y = element_blank())

# ============================================================================
# 3. Panel D: timing precision (circular SD) vs seasonal amplitude, with the
#    validated breakpoint model, and a climatology inset
# ============================================================================
bp_fit <- grid_search_breakpoint(phase_sd$mean_A1, phase_sd$phase_sd_days)
bp_ci <- bootstrap_breakpoint_ci(phase_sd$mean_A1, phase_sd$phase_sd_days, n_boot = 2000)
cat(sprintf("\nReal-data breakpoint (A1, deg C): %.3f [%.3f, %.3f]\n",
            bp_fit$breakpoint, bp_ci$ci_lo, bp_ci$ci_hi))

hinge_curve <- data.frame(x = exp(seq(log(min(phase_sd$mean_A1)), log(max(phase_sd$mean_A1)), length.out = 400))) %>%
  mutate(y = bp_fit$coef[1] + bp_fit$coef[2] * x + bp_fit$coef[3] * pmax(x - bp_fit$breakpoint, 0))

phase_sd <- phase_sd %>% mutate(unstable = phase_R < 0.8)
n_unstable <- sum(phase_sd$unstable)

INSET_BELOW <- "South_Central_Pacific_Polynesia_03"
INSET_ABOVE <- "Western_Indian_Ocean_01"
inset_meta <- phase_sd %>% filter(site_id %in% c(INSET_BELOW, INSET_ABOVE))

load_climatology <- function(site_id) {
  daily <- read.csv(here("data", "inset_climatology", paste0(site_id, "_daily.csv")), stringsAsFactors = FALSE)
  daily$date <- as.Date(daily$date)
  daily$doy <- as.numeric(format(daily$date, "%j"))
  daily %>% group_by(doy) %>% summarise(sst = mean(sst, na.rm = TRUE), .groups = "drop")
}
clim_below <- load_climatology(INSET_BELOW) %>% mutate(site_id = INSET_BELOW, colour = BLUE)
clim_above <- load_climatology(INSET_ABOVE) %>% mutate(site_id = INSET_ABOVE, colour = PURP)
clim_all <- bind_rows(clim_below, clim_above)

a1_below <- round(inset_meta$mean_A1[inset_meta$site_id == INSET_BELOW], 2)
a1_above <- round(inset_meta$mean_A1[inset_meta$site_id == INSET_ABOVE], 2)

inset_plot <- ggplot(clim_all, aes(doy, sst, colour = site_id)) +
  geom_line(linewidth = 0.5) +
  scale_colour_manual(values = c(setNames(BLUE, INSET_BELOW), setNames(PURP, INSET_ABOVE)), guide = "none") +
  annotate("text", x = 15, y = max(clim_below$sst), label = paste0("A1=", a1_below),
           colour = BLUE, hjust = 0, vjust = 0, fontface = "bold", size = (MIN_PT - 2.5) / .pt) +
  annotate("text", x = 350, y = min(clim_above$sst), label = paste0("A1=", a1_above),
           colour = PURP, hjust = 1, vjust = 1, fontface = "bold", size = (MIN_PT - 2.5) / .pt) +
  scale_x_continuous(breaks = c(1, 182, 365), labels = c("Jan", "Jul", "Dec")) +
  scale_y_continuous(expand = expansion(mult = c(0.18, 0.18))) +
  labs(x = NULL, y = NULL) +
  theme_bw(base_size = MIN_PT - 2) + 
  theme(panel.grid = element_blank(), plot.background = element_rect(colour = "black", linewidth = 0.4),
        plot.margin = margin(2, 2, 2, 2)) + publication_theme

panel_D_main <- ggplot(phase_sd, aes(mean_A1, phase_sd_days)) +
  annotate("rect", xmin = bp_ci$ci_lo, xmax = bp_ci$ci_hi, ymin = -Inf, ymax = Inf, fill = "grey70", alpha = 0.3) +
  geom_vline(xintercept = bp_fit$breakpoint, linetype = "dashed", colour = "grey40") +
  geom_line(data = hinge_curve, aes(x, y), inherit.aes = FALSE, linewidth = 0.6) +
  geom_point(data = filter(phase_sd, !unstable), colour = PURP, size = 1.3) +
  geom_point(data = filter(phase_sd, unstable), shape = 21, colour = PURP, fill = NA, size = 2, stroke = 0.9) +
  annotate("text", x = min(phase_sd$mean_A1) * 1.05, y = 8, hjust = 0, vjust = 1, size = MIN_PT / .pt,
           label = sprintf("breakpoint %.2f\n[%.2f,%.2f] ºC", bp_fit$breakpoint, bp_ci$ci_lo, bp_ci$ci_hi)) +
  scale_x_log10(breaks = c(0.3, 0.5, 1, 2, 5), labels = scales::label_number(drop0trailing = TRUE)) +
  labs(x = "A1 (ºC)", y = "Phase circular SD (days)", tag = "D") +
  theme(plot.tag = element_text(size = 10, face = "bold"), plot.tag.position = c(0.02, 0.98),
        plot.margin = margin(t = 5.5, r = 5.5, b = 16, l = 5.5)) + publication_theme

panel_D <- panel_D_main +
  inset_element(inset_plot, left = 0.35, bottom = 0.42, right = 0.98, top = 0.98) +
  plot_annotation(caption = sprintf("open markers: R<0.8, n=%d", n_unstable)) &
  theme(plot.caption = element_text(size = MIN_PT, hjust = 0, face = "italic")); panel_D

# ============================================================================
# 4. Panel E: regional phase shift vs regional median timing envelope
# ============================================================================
envelope <- phase_sd %>% group_by(region) %>% summarise(median_envelope = median(phase_sd_days), .groups = "drop")

# Shortened labels for panel E only, where space is tight and full region
# names ("Western Atlantic & Caribbean & Brazil") don't fit next to a point.
SHORT_REGION_LABELS <- c(
  Western_Atlantic_Caribbean_Brazil = "W Atlantic/Caribbean",
  Coral_Triangle_SE_Asia = "Coral Triangle",
  Eastern_Atlantic_West_Africa = "E Atlantic/W Africa",
  Western_Indian_Ocean = "W Indian Ocean"
)

panelE_df <- pool_shift$by_region %>%
  left_join(envelope, by = "region") %>%
  mutate(abs_shift = abs(pooled),
         excl_zero = !is.na(ci_lo) & ((ci_lo > 0) | (ci_hi < 0)),
         ratio = abs_shift / median_envelope,
         region_label = ifelse(region %in% names(SHORT_REGION_LABELS),
                                SHORT_REGION_LABELS[region], REGION_LABELS[region]))

cat("\nPanel E: shift-to-envelope ratios, significant regions --\n")
panelE_df %>% filter(excl_zero) %>% arrange(desc(ratio)) %>%
  transmute(region, abs_shift = round(abs_shift, 3), median_envelope = round(median_envelope, 3),
            ratio = round(ratio, 3)) %>% print(row.names = FALSE)
cat("All regions below the 1:1 line:", all(panelE_df$abs_shift < panelE_df$median_envelope), "\n")

xmax_e <- max(panelE_df$median_envelope) * 1.25
ymax_e <- max(panelE_df$abs_shift) * 1.25

panel_E <- ggplot(panelE_df, aes(median_envelope, abs_shift)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  geom_point(data = filter(panelE_df, !excl_zero), colour = "grey60", size = 1.1) +
  geom_point(data = filter(panelE_df, excl_zero), colour = "black", size = 2) +
  geom_text_repel(data = filter(panelE_df, excl_zero),
                   aes(label = paste0(region_label, "\nratio=", round(ratio, 2))),
                   size = (MIN_PT - 1) / .pt, segment.size = 0.3, min.segment.length = 0, seed = 1,
                   box.padding = 0.4, force = 3, max.overlaps = Inf,
                   xlim = c(0, xmax_e), ylim = c(0, ymax_e)) +
  coord_cartesian(xlim = c(0, xmax_e), ylim = c(0, ymax_e)) +
  labs(x = "Median timing envelope (days)", y = "Abs regional phase shift (days)", tag = "E") +
  theme(plot.tag = element_text(size = 10, face = "bold"), plot.tag.position = c(0.02, 0.98)) + publication_theme

# ============================================================================
# 5. Panel F: cue reliability by region, independently ordered, with an r^2
#    secondary axis (rho -> rho^2*100, a genuinely non-linear mapping)
# ============================================================================
order_F <- pool_rho$by_region %>% arrange(desc(pooled)) %>% pull(region)

panel_F <- pool_rho$by_region %>%
  mutate(region_f = factor(region, levels = rev(order_F))) %>%
  ggplot(aes(y = region_f, x = pooled)) +
  annotate("rect", xmin = pool_rho$overall$ci_lo, xmax = pool_rho$overall$ci_hi,
           ymin = -Inf, ymax = Inf, fill = "grey70", alpha = 0.3) +
  geom_vline(xintercept = pool_rho$overall$pooled, colour = "black", linewidth = 0.4) +
  geom_vline(xintercept = 0, colour = "grey50", linetype = "dashed", linewidth = 0.4) +
  geom_errorbar(aes(xmin = ci_lo, xmax = ci_hi), width = 0, orientation = "y", colour = GREEN, linewidth = 0.45) +
  geom_point(colour = GREEN, size = 1.6) +
  scale_y_discrete(labels = function(r) REGION_LABELS[r]) +
  # A few regional Wald-type CIs dip slightly below zero (small-sample
  # approximation artifact -- rho itself cannot be negative), so the
  # primary axis genuinely spans negative-to-positive values and
  # rho -> r^2 = rho^2*100 is not monotonic over that full range, which
  # ggplot2's secondary-axis machinery requires in order to invert it and
  # place breaks. Use the signed-square variant sign(rho)*rho^2*100
  # instead: strictly monotonic everywhere, and identical to rho^2*100
  # (the only biologically meaningful branch) for rho >= 0, which is the
  # only region where break labels (0/10/20%) are ever placed.
  scale_x_continuous(
    sec.axis = sec_axis(~ sign(.) * (.)^2 * 100, name = "r^2 (%)", breaks = c(0, 10, 20))
  ) +
  labs(x = "cue reliability, rho", y = NULL, tag = "F") +
  theme(plot.tag = element_text(size = 10, face = "bold"), plot.tag.position = c(0.02, 0.98)) + publication_theme; panel_F

# computed (not eyeballed) confirmation the r^2 secondary axis is non-linear
r2_ticks <- c(0, 10, 20)
rho_at_ticks <- sqrt(r2_ticks / 100)
gaps <- diff(rho_at_ticks)
cat(sprintf("\nPanel F r^2 axis check: r^2=%s%% -> rho=%s; gaps=%s; strictly narrowing: %s\n",
            paste(r2_ticks, collapse = "/"), paste(round(rho_at_ticks, 4), collapse = "/"),
            paste(round(gaps, 4), collapse = "/"), all(diff(gaps) < 0)))

# ============================================================================
# 6. Assemble and export
# ============================================================================
top_row <- panel_A + panel_B + panel_C + plot_layout(widths = c(1, 1, 1))
bottom_row <- panel_D + panel_E + panel_F + plot_layout(widths = c(1, 1, 1))
figure2 <- top_row / bottom_row + plot_layout(heights = c(0.85, 1.15));figure2

bottom_row2 <- panel_F + panel_D + panel_E + plot_layout(widths = c(1, 1, 1))

dir.create(here("figures"), showWarnings = FALSE)
ggsave(here("figures", "figure2.pdf"), figure2, width = 169, height = 225, units = "mm", device = cairo_pdf)
ggsave(here("figures", "figure2_600dpi.png"), figure2, width = 169, height = 225, units = "mm", dpi = 600)
cat("\nWrote figures/figure2.pdf and figures/figure2_600dpi.png\n")
