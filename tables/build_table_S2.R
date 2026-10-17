#!/usr/bin/env Rscript
# =============================================================================
# Build Table S2 -- the full per-site metrics table -- by joining 11 source
# tables from the working repo on site_id. This table did not exist as a
# single file anywhere before this script (confirmed by search); this is
# a pure consolidation of already-computed, already-validated per-site
# results, no new statistics beyond one previously-missing derived column
# (daylength_roc_at_peak -- see extension/axes81/photoperiod/scripts/
# 04_photoperiod_rate_at_peak.py, which reuses the validated daylength
# model unmodified rather than re-deriving it).
#
# This is a BUILD-TIME script: it reads from the working repo (paths above
# submission/), which intentionally is not itself part of the submission
# repo. Re-running it requires the full working repo, not just
# submission/. The OUTPUT (Table_S2_site_metrics.csv) is what ships.
#
# Run from submission/tables/.
# =============================================================================

suppressPackageStartupMessages(library(dplyr))

ROOT <- normalizePath(file.path(getwd(), "..", ".."))
ax <- function(...) file.path(ROOT, "extension", "axes81", "tables", ...)
pp <- function(...) file.path(ROOT, "extension", "axes81", "photoperiod", "tables", ...)
ex <- function(...) file.path(ROOT, "extension", "tables", ...)
ck4 <- function(...) file.path(ROOT, "extension", "checks4", "tables", ...)
ckA <- function(...) file.path(ROOT, "extension", "axes81", "checks", "tables", ...)

# ---------------------------------------------------------------------------
# 1. Base: site_id, region, resolved pixel coordinates, distance from nominal
# ---------------------------------------------------------------------------
base <- read.csv(ex("taskE1_site_selection.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id, region, lat = pixel_lat, lon = pixel_lon,
            dist_from_nominal_km = pixel_distance_km,
            # Never computed anywhere in the working pipeline (confirmed by
            # search before writing this script) -- the nearest-ocean-pixel
            # utility (extension/scripts/11_taskE1_nearest_ocean_pixel.py)
            # queries individual mask points to find the nearest ocean
            # pixel, but never retains a 3x3-neighbourhood ocean fraction.
            # Left NA rather than fabricated; would need a live re-query of
            # the OISST land-sea mask THREDDS endpoint at 8 neighbouring
            # points per site to fill in.
            landmask_frac_3x3 = NA_real_)
stopifnot(nrow(base) == 81, !anyDuplicated(base$site_id))

# ---------------------------------------------------------------------------
# 2. Mean and amplitude trends (naive, full record)
# ---------------------------------------------------------------------------
trends <- read.csv(ax("axes81_1b_trends.csv"), stringsAsFactors = FALSE)
trends_full <- trends %>% filter(period == "full")

M_trend <- trends_full %>% filter(axis == "M") %>%
  transmute(site_id, M_trend = slope, M_trend_ci_lo = slope_ci_lo, M_trend_ci_hi = slope_ci_hi)
A1_trend <- trends_full %>% filter(axis == "A1") %>%
  transmute(site_id, A1_trend = slope, A1_trend_ci_lo = slope_ci_lo, A1_trend_ci_hi = slope_ci_hi)

# M_mean, A1_mean: mean annual SST / amplitude, full record -- from taskE3
means <- read.csv(ex("taskE3_site_metrics.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id, M_mean = M, A1_mean = A1)

# ---------------------------------------------------------------------------
# 3. Amplitude step-adjusted trend (S1.8's trend-plus-step model, two-step
#    version -- the recommended estimate per Table S3's footnote)
# ---------------------------------------------------------------------------
step <- read.csv(ckA("checkA_per_site_step_models.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id,
            A1_trend_step_adj = step2_b1, A1_trend_step_adj_ci_lo = step2_b1_lo, A1_trend_step_adj_ci_hi = step2_b1_hi,
            A1_step_2007 = step2_b2, A1_step_2022 = step2_b3)

# ---------------------------------------------------------------------------
# 4. Phase: circular mean/SD/R (full record levels), phase shift (full record)
# ---------------------------------------------------------------------------
levels <- read.csv(ax("axes81_1c_levels.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id, phase_doy_mean = mean_phase_doy, phase_R, phase_sd_days,
            colwell_P_0p5 = colwell_P_bin0.5, colwell_P_1p0 = colwell_P_bin1.0, colwell_P_2p0 = colwell_P_bin2.0)

shift <- read.csv(ax("axes81_1b_phase_block_shift.csv"), stringsAsFactors = FALSE) %>%
  filter(period == "full") %>%
  transmute(site_id, phase_shift_days = shift_days, phase_shift_days_ci_lo = shift_ci_lo, phase_shift_days_ci_hi = shift_ci_hi)

# ---------------------------------------------------------------------------
# 5. Cue reliability (magnitude + timing targets), harmonic R^2,
#    marine-heatwave block metrics, diagnostic-only lag-1 AC, changepoints,
#    and empirical-peak timing consistency (renamed from its stored,
#    confirmed-misnomer column name photoperiod_R -- see
#    output/decisions.md, 2026-09-15 "CORRECTION" entry, and
#    extension/axes81/checks/TIMING_CONSISTENCY_CORRECTION.md)
# ---------------------------------------------------------------------------
e3 <- read.csv(ex("taskE3_site_metrics.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id,
            rho_magnitude, rho_magnitude_ci_lo, rho_magnitude_ci_hi,
            rho_timing, rho_timing_p = rho_timing_perm_p,
            mhw_freq_early = freq_early, mhw_freq_late = freq_late,
            mhw_dur_early = dur_early, mhw_dur_late = dur_late,
            cp_lag1_ac = changepoint_lag1ac, cp_lag1_ac_ci_lo = changepoint_lag1ac_ci_lo, cp_lag1_ac_ci_hi = changepoint_lag1ac_ci_hi,
            cp_resid_var = changepoint_residvar, cp_resid_var_ci_lo = changepoint_residvar_ci_lo, cp_resid_var_ci_hi = changepoint_residvar_ci_hi,
            cp_A1 = changepoint_A1, cp_A1_ci_lo = changepoint_A1_ci_lo, cp_A1_ci_hi = changepoint_A1_ci_hi,
            empirical_peak_R = photoperiod_R)

harmonic_r2 <- read.csv(ck4("check4_1a_partition_measures.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id, harmonic_R2_pre2007 = harmonicR2_pre2007, harmonic_R2_full = harmonicR2_full)

# Prefer axes81_3b's lag1_ac_pre2007 over taskE3's column of the same
# meaning, which is explicitly named ..._DIAGNOSTIC_ONLY in its source file.
lag1ac <- read.csv(ax("axes81_3b_axis_table.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id, lag1_ac_pre2007)

# ---------------------------------------------------------------------------
# 6. Photoperiod: daylength range/rate, solstice-to-peak lag
# ---------------------------------------------------------------------------
daylength <- read.csv(pp("photoperiod_02_per_site_amplitude.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id, daylength_range_h = daylength_range_hours, daylength_roc_max = max_rate_min_per_day)

daylength_at_peak <- read.csv(pp("photoperiod_02e_rate_at_peak.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id, daylength_roc_at_peak = daylength_roc_at_peak_min_per_day)

solstice <- read.csv(pp("photoperiod_03a_per_site_lag.csv"), stringsAsFactors = FALSE) %>%
  transmute(site_id, solstice_peak_lag_days = mean_lag_days,
            solstice_peak_lag_ci_lo = mean_lag_ci_lo, solstice_peak_lag_ci_hi = mean_lag_ci_hi)

# ---------------------------------------------------------------------------
# Join everything on site_id (inner joins throughout -- every source table
# was confirmed to share the identical 81-site_id set before this script
# was written, so an inner join changes nothing but guards against silent
# row loss if that ever stops being true)
# ---------------------------------------------------------------------------
tables <- list(base, M_trend, A1_trend, means, step, levels, shift, e3,
               harmonic_r2, lag1ac, daylength, daylength_at_peak, solstice)

table_s2 <- Reduce(function(x, y) inner_join(x, y, by = "site_id"), tables)
stopifnot(nrow(table_s2) == 81, !anyDuplicated(table_s2$site_id))

# Column order matching the manuscript's Table S2 dictionary, with the
# additional (not in the published dictionary, but already computed and
# validated, so retained rather than discarded) uncertainty/full-record
# columns grouped right after the column they extend.
col_order <- c(
  "site_id", "region", "lat", "lon", "dist_from_nominal_km", "landmask_frac_3x3",
  "M_mean", "M_trend", "M_trend_ci_lo", "M_trend_ci_hi",
  "A1_mean", "A1_trend", "A1_trend_ci_lo", "A1_trend_ci_hi",
  "A1_trend_step_adj", "A1_trend_step_adj_ci_lo", "A1_trend_step_adj_ci_hi",
  "A1_step_2007", "A1_step_2022",
  "phase_doy_mean", "phase_R", "phase_sd_days",
  "phase_shift_days", "phase_shift_days_ci_lo", "phase_shift_days_ci_hi",
  "rho_magnitude", "rho_magnitude_ci_lo", "rho_magnitude_ci_hi",
  "rho_timing", "rho_timing_p",
  "harmonic_R2_pre2007", "harmonic_R2_full",
  "colwell_P_0p5", "colwell_P_1p0", "colwell_P_2p0",
  "mhw_freq_early", "mhw_freq_late", "mhw_dur_early", "mhw_dur_late",
  "lag1_ac_pre2007",
  "cp_lag1_ac", "cp_lag1_ac_ci_lo", "cp_lag1_ac_ci_hi",
  "cp_A1", "cp_A1_ci_lo", "cp_A1_ci_hi",
  "cp_resid_var", "cp_resid_var_ci_lo", "cp_resid_var_ci_hi",
  "empirical_peak_R",
  "daylength_range_h", "daylength_roc_max", "daylength_roc_at_peak",
  "solstice_peak_lag_days", "solstice_peak_lag_ci_lo", "solstice_peak_lag_ci_hi"
)
stopifnot(setequal(col_order, names(table_s2)))
table_s2 <- table_s2[, col_order]
table_s2 <- table_s2[order(table_s2$region, table_s2$site_id), ]

write.csv(table_s2, "Table_S2_site_metrics.csv", row.names = FALSE, na = "")

cat(sprintf("Wrote Table_S2_site_metrics.csv: %d rows, %d columns\n", nrow(table_s2), ncol(table_s2)))
cat("Regions:\n"); print(table(table_s2$region))
cat(sprintf("\nColumns entirely NA: %s\n",
            paste(names(table_s2)[sapply(table_s2, function(x) all(is.na(x)))], collapse = ", ")))
cat(sprintf("Any other unexpected NAs (excluding landmask_frac_3x3)? %d\n",
            sum(is.na(table_s2[, setdiff(names(table_s2), "landmask_frac_3x3")]))))
