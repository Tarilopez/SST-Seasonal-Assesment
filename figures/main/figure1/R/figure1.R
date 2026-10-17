#!/usr/bin/env Rscript
# =============================================================================
# Figure 1 (conceptual) -- FINAL build.
#
# Defines the four axes of seasonal thermal structure (mean, amplitude,
# phase, cue reliability) and where each acts mechanistically. Precedes the
# empirical Figure 2 (../figure2/) and reads as a pair with it: same
# palette, font, line weights, and panel-letter convention.
#
# Panels A and B are SCHEMATIC (idealized sinusoids, deliberately exaggerated
# so the mechanism is visible -- the real observed changes are far too small
# to see at annual-cycle scale). Panel C uses REAL climatology data, because
# it contrasts two *reefs* rather than two *periods*, and that contrast is
# large enough to see directly.
#
# Round 2 (this file) resolves every item flagged in round 1
# (figure1_draft.R / BUILD_NOTES.md "Known issues"): every in-panel
# annotation is now >=8pt (GCB minimum, matching Figure 2), built and
# exported at true final size (169mm width, vector PDF + 600dpi PNG), with
# label content shortened/repositioned rather than shrunk to fit -- see
# BUILD_NOTES.md "Round 2" for the collision-by-collision record.
# =============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(patchwork)
  library(scales)
})

here <- function(...) file.path(getwd(), ...)
set.seed(20260916)

# ---------------------------------------------------------------------------
# Style, matched to extension/figure2 (see BUILD_NOTES.md "Style matching")
# ---------------------------------------------------------------------------
MIN_PT <- 8
theme_set(
  theme_bw(base_size = MIN_PT) +
    theme(
      panel.grid = element_blank(),
      axis.text = element_text(size = MIN_PT, colour = "black"),
      axis.title = element_text(size = MIN_PT, colour = "black"),
      plot.title = element_blank(),
      strip.background = element_blank(),
      strip.text = element_text(size = MIN_PT, face = "bold")
    )
)

BLUE <- "#025F9B"    # Okabe-Ito; matches figure2's SINGLE_COLOR / below-breakpoint inset trace
PURP <- "#837AAE"  # Okabe-Ito; matches figure2's above-breakpoint inset trace
GREEN <- "#5bd3b0"   # Okabe-Ito; matches figure2 panel F
GREY <- "grey45"
HIST_COL <- "black"

tag_theme <- function() theme(plot.tag = element_text(size = 12, face = "bold"), plot.tag.position = c(0.02, 0.95))
ann8 <- MIN_PT / .pt  # every in-panel annotation uses this -- no exceptions in the final build

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

sst_curve <- function(doy, M, A, peak_doy, period = 365) M + A * cos(2 * pi * (doy - peak_doy) / period)

# ---------------------------------------------------------------------------
# Baseline idealized reef (used across panel A and B)
# ---------------------------------------------------------------------------
M0 <- 27; A0 <- 3; PEAK0 <- 220
BLEACH_THRESH <- M0 + A0 + 1.5
ENVELOPE_HALFWIDTH <- 0.4
doy_seq <- seq(1, 365, by = 1)
Y_LIM <- c(19.5, 34.5)  # widened slightly vs round 1 to give 8pt labels headroom

# ============================================================================
# PANEL A1 -- MEAN
# ============================================================================
A1_SHIFT <- 1.2
hist_curve <- data.frame(doy = doy_seq, sst = sst_curve(doy_seq, M0, A0, PEAK0))
alt_curve_A1 <- data.frame(doy = doy_seq, sst = sst_curve(doy_seq, M0 + A1_SHIFT, A0, PEAK0))

panel_A1 <- ggplot() +
  geom_ribbon(data = hist_curve, aes(doy, ymin = sst - ENVELOPE_HALFWIDTH, ymax = sst + ENVELOPE_HALFWIDTH),
              fill = GREY, alpha = 0.18) +
  geom_hline(yintercept = BLEACH_THRESH, linetype = "dashed", colour = GREY, linewidth = 0.5) +
  geom_line(data = hist_curve, aes(doy, sst), colour = HIST_COL, linewidth = 0.8) +
  geom_line(data = alt_curve_A1, aes(doy, sst), colour = BLUE, linewidth = 0.8) +
  annotate("segment", x = PEAK0, xend = PEAK0,y = max(hist_curve$sst), yend = max(alt_curve_A1$sst),
           arrow = arrow(length = unit(0.08, "cm"), ends = "last", type = "closed"), colour = BLUE, linewidth = 0.4) +
  annotate("segment", x = PEAK0 + 50, xend = PEAK0 + 50, y = max(alt_curve_A1$sst), yend = BLEACH_THRESH,
           arrow = arrow(length = unit(0.08, "cm"), ends = "both", type = "closed"), colour = GREY, linewidth = 0.4) +
  annotate("text", x = PEAK0 + 57, y = (max(alt_curve_A1$sst) + BLEACH_THRESH) / 2, label = "Margin", size = ann8, hjust = 0) +
  coord_cartesian(ylim = Y_LIM, xlim = c(1, 400)) +
  scale_x_continuous(breaks = c(1, 182, 365), labels = c("Jan", "Jul", "Dec")) +
  labs(x = NULL, y = "SST (degC)", subtitle = "MEAN", tag = "A") +
  theme(plot.subtitle = element_text(size = MIN_PT, face = "bold")) + publication_theme;panel_A1 

# ============================================================================
# PANEL A2 -- AMPLITUDE
# ============================================================================
A_BIG <- 4.5; A_SMALL <- 1.8
alt_big <- data.frame(doy = doy_seq, sst = sst_curve(doy_seq, M0, A_BIG, PEAK0))
alt_small <- data.frame(doy = doy_seq, sst = sst_curve(doy_seq, M0, A_SMALL, PEAK0))

ramp_days <- function(A, band = 0.5) {
  rise <- data.frame(doy = seq(PEAK0 - 182, PEAK0, by = 0.1))
  rise$sst <- sst_curve(rise$doy, M0, A, PEAK0)
  sum(abs(rise$sst - M0) <= band) * 0.1
}
ramp_base <- ramp_days(A0); ramp_big <- ramp_days(A_BIG); ramp_small <- ramp_days(A_SMALL)

panel_A2 <- ggplot() +
  geom_ribbon(data = hist_curve, aes(doy, ymin = sst - ENVELOPE_HALFWIDTH, ymax = sst + ENVELOPE_HALFWIDTH),
              fill = GREY, alpha = 0.18) +
  geom_hline(yintercept = BLEACH_THRESH, linetype = "dashed", colour = GREY, linewidth = 0.5) +
  geom_line(data = hist_curve, aes(doy, sst), colour = HIST_COL, linewidth = 0.8) +
  geom_line(data = alt_big, aes(doy, sst), colour = BLUE, linewidth = 0.8) +
  geom_line(data = alt_small, aes(doy, sst), colour = PURP, linewidth = 0.8) +
  annotate("segment", x = PEAK0, xend = PEAK0, y = max(alt_small$sst), yend = max(alt_big$sst),
           arrow = arrow(length = unit(0.08, "cm"), ends = "both", type = "closed"), colour = "black", linewidth = 0.5) +
  # short, colour-coded ramp-length labels (day counts only), placed beside each
  # curve's own peak (which are vertically separated by construction) rather
  # than stacked together -- avoids the round-1 collision where all three
  # sentences overlapped in one corner
  annotate("text", x = PEAK0 + 14, y = max(alt_big$sst), label = sprintf("%.0fd", ramp_big), size = ann8, hjust = 0, colour = BLUE, fontface = "bold") +
  annotate("text", x = PEAK0 + 14, y = max(hist_curve$sst), label = sprintf("%.0fd", ramp_base), size = ann8, hjust = 0, colour = HIST_COL, fontface = "bold") +
  annotate("text", x = PEAK0 + 14, y = max(alt_small$sst), label = sprintf("%.0fd", ramp_small), size = ann8, hjust = 0, colour = PURP, fontface = "bold") +
  coord_cartesian(ylim = Y_LIM, xlim = c(1, 400)) +
  scale_x_continuous(breaks = c(1, 182, 365), labels = c("Jan", "Jul", "Dec")) +
  labs(x = NULL, y = NULL, subtitle = "AMPLITUDE", tag = NULL) +
  theme(plot.subtitle = element_text(size = MIN_PT, face = "bold"), axis.text.y = element_blank()) + publication_theme;panel_A2

# ============================================================================
# PANEL A3 -- PHASE
# ============================================================================
SOLSTICE <- 172
PEAK_EARLY <- PEAK0 - 25
PEAK_LATE <- PEAK0 + 30
alt_early <- data.frame(doy = doy_seq, sst = sst_curve(doy_seq, M0, A0, PEAK_EARLY))
alt_late <- data.frame(doy = doy_seq, sst = sst_curve(doy_seq, M0, A0, PEAK_LATE))
lag_hist <- PEAK0 - SOLSTICE; lag_early <- PEAK_EARLY - SOLSTICE; lag_late <- PEAK_LATE - SOLSTICE

panel_A3 <- ggplot() +
  geom_ribbon(data = hist_curve, aes(doy, ymin = sst - ENVELOPE_HALFWIDTH, ymax = sst + ENVELOPE_HALFWIDTH),
              fill = GREY, alpha = 0.18) +
  geom_hline(yintercept = BLEACH_THRESH, linetype = "dashed", colour = GREY, linewidth = 0.5) +
  geom_vline(xintercept = SOLSTICE, linetype = "dashed", colour = GREEN, linewidth = 0.5) +
  geom_line(data = hist_curve, aes(doy, sst), colour = HIST_COL, linewidth = 0.8) +
  geom_line(data = alt_early, aes(doy, sst), colour = PURP, linewidth = 0.8) +
  geom_line(data = alt_late, aes(doy, sst), colour = BLUE, linewidth = 0.8) +
  annotate("segment", x = PEAK_EARLY, xend = PEAK_LATE, y = M0 + A0 + 1.3, yend = M0 + A0 + 1.3,
           arrow = arrow(length = unit(0.08, "cm"), ends = "both", type = "closed"), colour = "black", linewidth = 0.4) +
  annotate("text", x = SOLSTICE - 6, y = Y_LIM[1] + 0.5, label = "Solstice", size = ann8, colour = GREEN, hjust = 1, fontface = "bold") +
  # lags as a compact colour-coded key in the empty upper-left corner, instead
  # of round 1's three separate in-plot labels crowding the peaks together
  annotate("text", x = 5, y = 35, label = "Lag to solstice:", size = ann8, colour = "grey20", hjust = 0) +
  annotate("text", x = 5, y = 34.5, label = sprintf("%d d", lag_early), size = ann8, colour = PURP, hjust = 0, fontface = "bold") +
  annotate("text", x = 5, y = 34, label = sprintf("%d d (hist.)", lag_hist), size = ann8, colour = HIST_COL, hjust = 0, fontface = "bold") +
  annotate("text", x = 5, y = 33.5, label = sprintf("%d d", lag_late), size = ann8, colour = BLUE, hjust = 0, fontface = "bold") +
  coord_cartesian(ylim = Y_LIM, xlim = c(1, 400)) +
  scale_x_continuous(breaks = c(1, 182, 365), labels = c("Jan", "Jul", "Dec")) +
  labs(x = NULL, y = NULL, subtitle = "PHASE (Timing)", tag = NULL) +
  theme(plot.subtitle = element_text(size = MIN_PT, face = "bold"), axis.text.y = element_blank()) + publication_theme;panel_A3

# ============================================================================
# PANEL A4 -- CUE RELIABILITY (built from scratch)
# ============================================================================
TIMING_SD_REAL <- 8.85
HEIGHT_SD_REAL <- 0.40
EXAGGERATION <- 3
TIMING_SD_USED <- TIMING_SD_REAL * EXAGGERATION
HEIGHT_SD_USED <- HEIGHT_SD_REAL * EXAGGERATION

n_years <- 8
peak_doy_i <- PEAK0 + rnorm(n_years, 0, TIMING_SD_USED)
height_off_i <- rnorm(n_years, 0, HEIGHT_SD_USED)
year_curves <- lapply(seq_len(n_years), function(i) {
  data.frame(doy = doy_seq, sst = sst_curve(doy_seq, M0, A0 + height_off_i[i], peak_doy_i[i]), yr = i)
})
year_curves <- bind_rows(year_curves)

peak_heights <- M0 + A0 + height_off_i
timing_band <- range(peak_doy_i)
height_band <- range(peak_heights)

Cue.colors.o<-c("#fbd65e","#A8DA96","#5bd3b0","#16758b","#904653", "#97d4ce","#abc4e2","#3A71A4", "#93B9E8")

panel_A4 <- ggplot() +
  geom_line(data = year_curves, aes(doy, sst, group = yr, colour = factor(yr)), alpha = 0.55, linewidth = 0.5) +
  scale_colour_manual(values = Cue.colors.o) +
  geom_line(data = hist_curve, aes(doy, sst), colour = HIST_COL, linewidth = 0.8) +
  annotate("segment", x = timing_band[1], xend = timing_band[2], y = Y_LIM[2] - 0.8, yend = Y_LIM[2] - 0.8,
           arrow = arrow(length = unit(0.06, "cm"), ends = "both", type = "closed"), colour = "black", linewidth = 0.5) +
  annotate("text", x = PEAK0, y = Y_LIM[2] - 1.9, label = "predictable", size = ann8, fontface = "italic") +
  annotate("segment", x = PEAK0 + 42, xend = PEAK0 + 42, y = height_band[1], yend = height_band[2],
           arrow = arrow(length = unit(0.06, "cm"), ends = "both", type = "closed"), colour = "black", linewidth = 0.5) +
  # "weakly predictable" (the magnitude-spread label) doesn't fit anywhere in
  # this crowded panel without overlapping either the "predictable" timing
  # label or the curve peaks themselves -- moved into the panel's caption
  # instead of forced into the plot area (see obs_caption below), with just
  # the vertical arrow left in-panel to mark where the spread is measured
  coord_cartesian(ylim = Y_LIM, xlim = c(1, 400)) +
  scale_x_continuous(breaks = c(1, 182, 365), labels = c("Jan", "Jul", "Dec")) +
  labs(x = NULL, y = NULL, subtitle = "CUE RELIABILITY", tag = NULL) + publication_theme +
  theme(plot.subtitle = element_text(size = MIN_PT, face = "bold"), axis.text.y = element_blank(),
        legend.position = "none"); panel_A4


# ---- Observed-magnitude annotations (checked against Figure 2 / Supplementary
# Tables S4-S6, S9-S10 -- see BUILD_NOTES.md for the check) ----
obs_caption <- function(txt) labs(caption = paste(strwrap(txt, width = 60), collapse = "\n"))
ann_theme <- theme(plot.caption = element_text(size = MIN_PT, face = "italic", hjust = 0, colour = "grey20"))

panel_A1 <- panel_A1 + obs_caption("observed: +0.08 to +0.33 degC decade-1 (all regions positive)") + ann_theme
panel_A2 <- panel_A2 + obs_caption("observed: -0.03 to +0.08 degC decade-1 (regionally divergent)") + ann_theme
panel_A3 <- panel_A3 + obs_caption("observed: -2.9 to +6.1 days (regionally divergent)") + ann_theme
panel_A4 <- panel_A4 + obs_caption("magnitude weakly predictable (arrow). observed: pooled rho = 0.22, ~5% of variance in peak magnitude") + ann_theme

panel_A <- panel_A1 + panel_A2 + panel_A3 + panel_A4 + plot_layout(nrow = 1);panel_A 

# ============================================================================
# PANEL B -- where each axis acts
# ============================================================================
big_curve <- data.frame(doy = doy_seq, sst = sst_curve(doy_seq, M0, A0, PEAK0))
trough_doy <- (PEAK0 + 182) %% 365
if (trough_doy == 0) trough_doy <- 365

panel_B <- ggplot() +
  geom_ribbon(data = big_curve, aes(doy, ymin = sst - ENVELOPE_HALFWIDTH, ymax = sst + ENVELOPE_HALFWIDTH),
              fill = GREY, alpha = 0.18) +
  geom_hline(yintercept = BLEACH_THRESH, linetype = "dashed", colour = GREY, linewidth = 0.5) +
  geom_vline(xintercept = SOLSTICE, linetype = "dashed", colour = GREEN, linewidth = 0.5) +
  geom_line(data = big_curve, aes(doy, sst), colour = HIST_COL, linewidth = 0.9) +
  annotate("segment", x = PEAK0 - 70, xend = PEAK0 - 70, y = max(big_curve$sst), yend = BLEACH_THRESH,
           arrow = arrow(length = unit(0.08, "cm"), ends = "both", type = "closed"), colour = "black", linewidth = 0.5) +
  annotate("text", x = PEAK0 - 75, y = (max(big_curve$sst) + BLEACH_THRESH) / 2,
           label = "Safety margin\n(Mean)", size = MIN_PT/.pt, hjust = 1, lineheight = 0.9) +
  annotate("segment", x = trough_doy, xend = PEAK0, y = M0 - A0 - 1.3, yend = M0 - A0 - 1.3,
           arrow = arrow(length = unit(0.08, "cm"), ends = "both", type = "closed"), colour = "black", linewidth = 0.5) +
  annotate("text", x = mean(c(trough_doy, PEAK0 + 365) %% 365), y = M0 - A0 - 2.3,
           label = "Acclimation ramp\n(Amplitude)", size = MIN_PT/.pt) +
  # cue-response alignment: moved well clear of the curve line itself (which
  # passes through y~27-29 across this x-range) down into the open space
  # beneath the rising limb, rather than sitting on top of the curve
  annotate("segment", x = SOLSTICE, xend = PEAK0, y = 22.5, yend = 22.5,
           arrow = arrow(length = unit(0.08, "cm"), ends = "both", type = "closed"), colour = "black", linewidth = 0.5) +
  annotate("text", x = (SOLSTICE + PEAK0) / 2, y = 23.4,
           label = "Cue-response\nalignment (Phase)", size = MIN_PT/.pt) +
  annotate("segment", x = PEAK0 + 45, xend = PEAK0 + 45, y = max(big_curve$sst) - 1, yend = max(big_curve$sst) + 1,
           arrow = arrow(length = unit(0.08, "cm"), ends = "both", type = "closed"), colour = "black", linewidth = 0.5) +
  annotate("text", x = PEAK0 + 51, y = max(big_curve$sst),
           label = "Preparation calibration\n(Cue reliability)", size = MIN_PT/.pt, hjust = 0, lineheight = 0.9) +
  annotate("text", x = SOLSTICE - 6, y = 20, label = "Solstice", size = ann8, colour = GREEN, hjust = 1, fontface = "bold") +
  coord_cartesian(ylim = c(Y_LIM[1] - 1, Y_LIM[2]), xlim = c(1, 400)) +
  scale_x_continuous(breaks = c(1, 91, 182, 273, 365), labels = c("Jan", "Apr", "Jul", "Oct", "Dec")) +
  labs(x = NULL, y = "SST (degC)", tag = "B") + tag_theme() + publication_theme; panel_B

# ============================================================================
# PANEL C -- two real cue regimes (same two sites as Figure 2 panel D inset)
# ============================================================================

setwd("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main/figures/main/figure1")

INSET_BELOW <- "South_Central_Pacific_Polynesia_03"
INSET_ABOVE <- "Western_Indian_Ocean_01"

load_site_daily <- function(site_id) read.csv(here("data", paste0(site_id, "_daily.csv")), stringsAsFactors = FALSE)
daily_c <- bind_rows(load_site_daily(INSET_BELOW), load_site_daily(INSET_ABOVE))
daily_c$date <- as.Date(daily_c$date)
daily_c$doy <- as.numeric(format(daily_c$date, "%j"))

raw_clim <- daily_c %>% group_by(site_id, doy) %>% summarise(sst = mean(sst, na.rm = TRUE), .groups = "drop")

smooth_clim <- function(df, k = 15) {
  df <- df[order(df$doy), ]
  n <- nrow(df)
  wrapped <- c(df$sst[(n - k + 1):n], df$sst, df$sst[1:k])
  sm <- stats::filter(wrapped, rep(1 / (2 * k + 1), 2 * k + 1), sides = 2)
  sm <- as.numeric(sm)[(k + 1):(k + n)]
  data.frame(doy = df$doy, sst = sm)
}
smoothed <- raw_clim %>% group_by(site_id) %>% group_modify(~ smooth_clim(.x)) %>% ungroup()

phase_meta <- read.csv(here("data", "site_phase_sd_A1.csv"), stringsAsFactors = FALSE)
phase_meta <- phase_meta[phase_meta$site_id %in% c(INSET_BELOW, INSET_ABOVE), ]

make_panelC <- function(site, colour, letter_note) {
  raw_s <- raw_clim[raw_clim$site_id == site, ]
  sm_s <- smoothed[smoothed$site_id == site, ]
  meta_s <- phase_meta[phase_meta$site_id == site, ]
  peak_doy <- sm_s$doy[which.max(sm_s$sst)]  # from this panel's own smoothed curve (self-contained: site_phase_sd_A1.csv here doesn't carry mean_phase_doy)
  sd_days <- meta_s$phase_sd_days
  yrange <- diff(range(sm_s$sst, na.rm = TRUE))
  band_y <- max(sm_s$sst, na.rm = TRUE) + 0.42 * yrange

  ggplot() +
    geom_line(data = raw_s, aes(doy, sst), colour = colour, alpha = 0.5, linewidth = 0.4) +
    geom_line(data = sm_s, aes(doy, sst), colour = colour, linewidth = 0.9) +
    annotate("segment", x = peak_doy - sd_days, xend = peak_doy + sd_days, y = band_y, yend = band_y,
             arrow = arrow(length = unit(0.06, "cm"), ends = "both", type = "closed"), colour = colour, linewidth = 0.5) +
    annotate("text", x = 183, y = band_y + 0.16 * yrange,
             label = "Interannual peak-timing spread", size = ann8, colour = colour, hjust = 0.5) +
    annotate("text", x = 10, y = min(sm_s$sst, na.rm = TRUE),
             label = sprintf("A1=%.2f degC\ncircular SD=%.1f d", meta_s$mean_A1, sd_days),
             size = MIN_PT/.pt, hjust = 0, vjust = 0, fontface = "bold", colour = colour, lineheight = 0.95) +
    annotate("text", x = 355, y = min(sm_s$sst, na.rm = TRUE) + 0.06 * yrange,
             label = letter_note, size = ann8, hjust = 1, fontface = "italic") +
    scale_y_continuous(expand = expansion(mult = c(0.06, 0.22))) +
    scale_x_continuous(breaks = c(1, 182, 365), labels = c("Jan", "Jul", "Dec")) +
    labs(x = NULL, y = "SST (degC)")
}

panel_C1 <- make_panelC(INSET_BELOW, BLUE, "Diffuse seasonal calendar") +
  labs(subtitle = "Low amplitude", tag = "C") +
  theme(plot.subtitle = element_text(size = MIN_PT, face = "bold")) + tag_theme()+ publication_theme; panel_C1

panel_C2 <- make_panelC(INSET_ABOVE, PURP, "Repeatable seasonal calendar") +
  labs(subtitle = "High amplitude", tag = NULL) +
  theme(plot.subtitle = element_text(size = MIN_PT, face = "bold")) + tag_theme()+ publication_theme; panel_C2

panel_C <- panel_C1 + panel_C2 + plot_layout(nrow = 1); panel_C

# ============================================================================
# Assemble and export at TRUE FINAL SIZE (matching Figure 2's 169mm width;
# vector PDF + 600dpi PNG)
# ============================================================================
figure1 <- panel_A / panel_B / panel_C + plot_layout(heights = c(0.85, 1, 1.05))

FIG_WIDTH_MM <- 169
FIG_HEIGHT_MM <- 230

dir.create(here("figures"), showWarnings = FALSE, recursive = TRUE)
ggsave(here("figures", "figure1.pdf"), figure1, width = FIG_WIDTH_MM, height = FIG_HEIGHT_MM,
       units = "mm", device = cairo_pdf)
ggsave(here("figures", "figure1_600dpi.png"), figure1, width = FIG_WIDTH_MM, height = FIG_HEIGHT_MM,
       units = "mm", dpi = 600)

cat("Wrote figures/figure1.pdf and figure1_600dpi.png at", FIG_WIDTH_MM, "x", FIG_HEIGHT_MM, "mm\n")
cat(sprintf("\nA2 ramp days -- base: %.1f, larger A: %.1f, smaller A: %.1f\n", ramp_base, ramp_big, ramp_small))
cat(sprintf("A3 lags -- early: %d d, hist: %d d, late: %d d\n", lag_early, lag_hist, lag_late))
cat(sprintf("A4 -- real timing SD: %.2f d, used (x%d): %.2f d\n", TIMING_SD_REAL, EXAGGERATION, TIMING_SD_USED))
cat(sprintf("A4 -- real height SD: %.2f degC, used (x%d): %.2f degC\n", HEIGHT_SD_REAL, EXAGGERATION, HEIGHT_SD_USED))
cat(sprintf("Panel C -- %s: A1=%.2f, circSD=%.2f d | %s: A1=%.2f, circSD=%.2f d\n",
            INSET_BELOW, phase_meta$mean_A1[phase_meta$site_id==INSET_BELOW], phase_meta$phase_sd_days[phase_meta$site_id==INSET_BELOW],
            INSET_ABOVE, phase_meta$mean_A1[phase_meta$site_id==INSET_ABOVE], phase_meta$phase_sd_days[phase_meta$site_id==INSET_ABOVE]))
