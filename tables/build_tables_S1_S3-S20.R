#!/usr/bin/env Rscript
# =============================================================================
# Build Supplementary Tables S1, S3-S20 (S2 built separately, see
# build_table_S2.R). Each table is extracted, summarized, or (for a few
# rows in S11/S16/S17) computed from already-validated per-site tables in
# the working repo -- no new statistical models are fit here beyond simple
# groupby summaries and, in a couple of places, region-level DerSimonian-
# Laird pooling via the already-validated pool_by_region() from
# ../figures/main/figure2/R/pooling.R (the same code Table S2 and Figure 2
# were built and verified with).
#
# BUILD-TIME script: reads from the working repo above submission/, which
# is intentionally not itself part of the submission repo. Run from
# submission/tables/.
# =============================================================================

suppressPackageStartupMessages(library(dplyr))
source("../figures/main/figure2/R/pooling.R")

ROOT <- normalizePath(file.path(getwd(), "..", ".."))
ax <- function(...) file.path(ROOT, "extension", "axes81", "tables", ...)
axck <- function(...) file.path(ROOT, "extension", "axes81", "checks", "tables", ...)
pp <- function(...) file.path(ROOT, "extension", "axes81", "photoperiod", "tables", ...)
ex <- function(...) file.path(ROOT, "extension", "tables", ...)
ck <- function(...) file.path(ROOT, "extension", "checks", "tables", ...)
ck3 <- function(...) file.path(ROOT, "extension", "checks3", "tables", ...)
ck4 <- function(...) file.path(ROOT, "extension", "checks4", "tables", ...)

r5 <- function(x) round(x, 5)
cat_check <- function(label, got, expect) cat(sprintf("  [check] %-55s got=%-28s expect~%s\n", label, got, expect))

# =============================================================================
# S1 -- Site selection by region
# Source: extension/HANDOFF2.md (prose table, section on Task E1 site
# selection) -- these counts (raw candidate pool size, count after 100km
# distance-declustering) were never written to a CSV anywhere in the
# working repo, only printed/recorded in that document. Transcribed
# directly, not recomputed (recomputing would require re-running the
# region-box candidate query against the live WCMC layer).
# =============================================================================
s1 <- data.frame(
  region = c("Australia", "Central Indian Ocean", "Coral Triangle and SE Asia",
             "Eastern Atlantic and West Africa", "Eastern Pacific", "Red Sea and Persian Gulf",
             "South Central Pacific and Polynesia", "Western Atlantic, Caribbean and Brazil",
             "Western Central Pacific", "Western Indian Ocean", "Focal subset (retained, not re-selected)"),
  raw_candidates = c(1655, 6496, 4451, 13, 8, 857, 334, 917, 1367, 1370, NA),
  after_100km_declustering = c(54, 55, 295, 7, 2, 52, 60, 108, 95, 87, NA),
  accepted = c(8, 8, 8, 6, 2, 8, 8, 8, 8, 8, 9),
  rejected_landmask = c(0, 0, 1, 1, 0, 0, 0, 0, 0, 0, NA)
)
stopifnot(sum(s1$accepted) == 81)
write.csv(s1, "Table_S1_site_selection.csv", row.names = FALSE, na = "")
cat("Wrote Table_S1_site_selection.csv\n")
cat_check("total accepted", sum(s1$accepted), "81")

# =============================================================================
# S3 -- Pooled estimates, four axes
# =============================================================================
pooled4 <- read.csv(ax("axes81_2a_pooled.csv"), stringsAsFactors = FALSE)
step_cmp <- read.csv(axck("checkA_pooled_b1_comparison.csv"), stringsAsFactors = FALSE)
rho_cmp <- read.csv(ck("check1_pooled_comparison.csv"), stringsAsFactors = FALSE)

pick <- function(df, key, keycol = "label") df[df[[keycol]] == key, ]
rho_dl <- pick(rho_cmp, "iii_region_random_effects_DL", "method")

s3 <- data.frame(
  quantity = c("Mean trend, full record", "Mean trend, 1982-2006",
               "Amplitude trend, naive full record", "Amplitude trend, 1982-2006",
               "Amplitude trend, step-adjusted (one step)", "Amplitude trend, step-adjusted (two steps)",
               "Phase shift, first-to-last 15 yr, full record", "Phase shift, 1982-2006",
               "Cue reliability (magnitude), region-level RE"),
  pooled = c(pick(pooled4, "M_full")$pooled, pick(pooled4, "M_pre2007")$pooled,
             pick(pooled4, "A1_full")$pooled, pick(pooled4, "A1_pre2007")$pooled,
             pick(step_cmp, "step_adjusted_1step")$pooled, pick(step_cmp, "step_adjusted_2step")$pooled,
             pick(pooled4, "phase_shift_days_full")$pooled, pick(pooled4, "phase_shift_days_pre2007")$pooled,
             rho_dl$pooled),
  ci_lo = c(pick(pooled4, "M_full")$ci_lo, pick(pooled4, "M_pre2007")$ci_lo,
            pick(pooled4, "A1_full")$ci_lo, pick(pooled4, "A1_pre2007")$ci_lo,
            pick(step_cmp, "step_adjusted_1step")$ci_lo, pick(step_cmp, "step_adjusted_2step")$ci_lo,
            pick(pooled4, "phase_shift_days_full")$ci_lo, pick(pooled4, "phase_shift_days_pre2007")$ci_lo,
            rho_dl$ci_lo),
  ci_hi = c(pick(pooled4, "M_full")$ci_hi, pick(pooled4, "M_pre2007")$ci_hi,
            pick(pooled4, "A1_full")$ci_hi, pick(pooled4, "A1_pre2007")$ci_hi,
            pick(step_cmp, "step_adjusted_1step")$ci_hi, pick(step_cmp, "step_adjusted_2step")$ci_hi,
            pick(pooled4, "phase_shift_days_full")$ci_hi, pick(pooled4, "phase_shift_days_pre2007")$ci_hi,
            rho_dl$ci_hi),
  tau2 = c(pick(pooled4, "M_full")$tau2, pick(pooled4, "M_pre2007")$tau2,
           pick(pooled4, "A1_full")$tau2, pick(pooled4, "A1_pre2007")$tau2,
           pick(step_cmp, "step_adjusted_1step")$tau2, pick(step_cmp, "step_adjusted_2step")$tau2,
           pick(pooled4, "phase_shift_days_full")$tau2, pick(pooled4, "phase_shift_days_pre2007")$tau2, NA),
  I2 = c(pick(pooled4, "M_full")$I2, pick(pooled4, "M_pre2007")$I2,
         pick(pooled4, "A1_full")$I2, pick(pooled4, "A1_pre2007")$I2,
         pick(step_cmp, "step_adjusted_1step")$I2, pick(step_cmp, "step_adjusted_2step")$I2,
         pick(pooled4, "phase_shift_days_full")$I2, pick(pooled4, "phase_shift_days_pre2007")$I2, NA)
)
write.csv(s3, "Table_S3_pooled_estimates.csv", row.names = FALSE, na = "")
cat("\nWrote Table_S3_pooled_estimates.csv\n")
cat_check("Mean trend full", sprintf("%.4f [%.4f,%.4f]", s3$pooled[1], s3$ci_lo[1], s3$ci_hi[1]), "0.0222 [0.0208,0.0237]")
cat_check("Amplitude step-adj 1-step", sprintf("%.4f [%.4f,%.4f]", s3$pooled[5], s3$ci_lo[5], s3$ci_hi[5]), "0.0024 [0.0011,0.0036]")
cat_check("Amplitude step-adj 2-step", sprintf("%.4f [%.4f,%.4f]", s3$pooled[6], s3$ci_lo[6], s3$ci_hi[6]), "0.0020 [0.0007,0.0034]")
cat_check("Phase shift full", sprintf("%.2f [%.2f,%.2f]", s3$pooled[7], s3$ci_lo[7], s3$ci_hi[7]), "0.86 [-0.11,1.82]")
cat_check("rho region-RE", sprintf("%.3f [%.3f,%.3f]", s3$pooled[9], s3$ci_lo[9], s3$ci_hi[9]), "0.222 [0.160,0.283]")
if (round(s3$pooled[5], 4) != 0.0024) {
  cat("  [NOTE] step-adjusted one-step point estimate rounds to 0.0023 here vs 0.0024 in the\n")
  cat("         manuscript text -- CI matches closely; flagged, not silently corrected.\n")
}

# =============================================================================
# S4, S5, S6 -- Mean / amplitude / phase-shift trend by region
# =============================================================================
regional <- read.csv(ax("axes81_2b_regional.csv"), stringsAsFactors = FALSE)

make_region_table <- function(axis_label_val, mult = 1) {
  d <- regional %>% filter(axis_label == axis_label_val) %>%
    transmute(region, n_sites, pooled_trend = pooled * mult, ci_lo = ci_lo * mult, ci_hi = ci_hi * mult) %>%
    arrange(desc(pooled_trend))
  d
}

s4 <- make_region_table("M_full")
write.csv(s4, "Table_S4_mean_trend_by_region.csv", row.names = FALSE, na = "")
s5 <- make_region_table("A1_full")
write.csv(s5, "Table_S5_amplitude_trend_by_region.csv", row.names = FALSE, na = "")
s6 <- make_region_table("phase_shift_days_full")
write.csv(s6, "Table_S6_phase_shift_by_region.csv", row.names = FALSE, na = "")
cat("\nWrote Table_S4/S5/S6 (mean/amplitude/phase-shift by region)\n")
cat_check("S4 top region (Red Sea)", sprintf("%.4f", s4$pooled_trend[s4$region == "Red_Sea_Persian_Gulf"]), "0.0325")
cat_check("S6 W.Atlantic/Caribbean", sprintf("%.2f [%.2f,%.2f]", s6$pooled_trend[s6$region == "Western_Atlantic_Caribbean_Brazil"],
          s6$ci_lo[s6$region == "Western_Atlantic_Caribbean_Brazil"], s6$ci_hi[s6$region == "Western_Atlantic_Caribbean_Brazil"]), "6.07 [3.02,9.12]")

# =============================================================================
# S7 -- Timing precision by region (circular SD, median/IQR/range)
# =============================================================================
s7 <- read.csv(axck("phase_envelope_by_region.csv"), stringsAsFactors = FALSE) %>% arrange(median)
write.csv(s7, "Table_S7_timing_precision_by_region.csv", row.names = FALSE)
cat("\nWrote Table_S7_timing_precision_by_region.csv\n")
cat_check("Red Sea median", sprintf("%.2f", s7$median[s7$region == "Red_Sea_Persian_Gulf"]), "5.65")

# =============================================================================
# S8 -- Timing precision by amplitude (breakpoint class, quartile, hinge)
# =============================================================================
bp_class <- read.csv(axck("phase_envelope_by_amplitude_class_breakpoint.csv"), stringsAsFactors = FALSE)
quartile <- read.csv(axck("phase_envelope_by_amplitude_class.csv"), stringsAsFactors = FALSE)
hinge <- read.csv(ax("axes81_2d_breakpoint.csv"), stringsAsFactors = FALSE)
photo_hinge <- read.csv(pp("photoperiod_02d_breakpoint.csv"), stringsAsFactors = FALSE)

write.csv(bp_class, "Table_S8a_timing_precision_by_breakpoint_class.csv", row.names = FALSE)
write.csv(quartile, "Table_S8b_timing_precision_by_amplitude_quartile.csv", row.names = FALSE)
s8c <- data.frame(predictor = hinge$predictor, breakpoint = hinge$breakpoint, ci_lo = hinge$ci_lo, ci_hi = hinge$ci_hi,
                   slope_before = hinge$slope_before, slope_after = hinge$slope_after,
                   r_sd_vs_abs_latitude = hinge$corr_with_abs_lat)
write.csv(s8c, "Table_S8c_fitted_hinge_model.csv", row.names = FALSE)
write.csv(photo_hinge, "Table_S8d_photoperiod_hinge_comparison.csv", row.names = FALSE)
cat("\nWrote Table_S8a-d (timing precision by amplitude)\n")
cat_check("breakpoint", sprintf("%.3f [%.3f,%.3f]", hinge$breakpoint, hinge$ci_lo, hinge$ci_hi), "1.126 [0.974,1.233]")
cat_check("below-bp median", sprintf("%.2f", bp_class$median[grepl("below", bp_class$amp_class_breakpoint)]), "19.36")
cat_check("photoperiod hinge bp (no threshold in thermal cycle)", sprintf("%.3f", photo_hinge$breakpoint), "3.07")

# =============================================================================
# S9, S10 -- Cue reliability by region; pooling-method sensitivity
# =============================================================================
s9 <- read.csv(ck("check1_per_region.csv"), stringsAsFactors = FALSE) %>%
  transmute(region, n_sites, mean_rho, ci_lo, ci_hi, r_squared,
            sites_individually_significant = sprintf("%d/%d", n_individually_significant, n_sites)) %>%
  arrange(desc(mean_rho))
write.csv(s9, "Table_S9_cue_reliability_by_region.csv", row.names = FALSE)
write.csv(rho_cmp, "Table_S10_pooling_method_sensitivity.csv", row.names = FALSE)
cat("\nWrote Table_S9/S10 (cue reliability by region; pooling sensitivity)\n")
cat_check("W.Atlantic/Caribbean rho", sprintf("%.3f", s9$mean_rho[s9$region == "Western_Atlantic_Caribbean_Brazil"]), "0.401")

# =============================================================================
# S11 -- What predicts cue reliability (site-level regressions, mediation,
# meta-regression, climate-mode coupling)
# =============================================================================
c4_1b <- read.csv(ck4("check4_1b_regressions.csv"), stringsAsFactors = FALSE)
c3_site <- read.csv(ck3("check3_2a_site_level_models.csv"), stringsAsFactors = FALSE)
c3_corr <- read.csv(ck3("check3_1a_correlation_matrix.csv"), stringsAsFactors = FALSE)
r2_of <- function(v2) { row <- c3_corr[c3_corr$var1 == "rho_magnitude" & c3_corr$var2 == v2, ]; row$r^2 }

s11a <- data.frame(
  model = c("rho ~ seasonal-cycle R2 (1982-2006)", "rho ~ interannual peak SD / A1",
            "rho ~ amplitude (A1)", "rho ~ timing precision (phase R)"),
  coefficient = c(c4_1b$coef[c4_1b$measure == "harmonicR2_pre2007"],
                  c4_1b$coef[c4_1b$measure == "ratio_ii_pre2007"],
                  c3_site$coef[c3_site$model == "i_rho~A1"],
                  c3_site$coef[c3_site$model == "ii_rho~phaseR"]),
  ci_lo = c(c4_1b$cluster_ci_lo[c4_1b$measure == "harmonicR2_pre2007"],
            c4_1b$cluster_ci_lo[c4_1b$measure == "ratio_ii_pre2007"],
            c3_site$cluster_ci_lo[c3_site$model == "i_rho~A1"],
            c3_site$cluster_ci_lo[c3_site$model == "ii_rho~phaseR"]),
  ci_hi = c(c4_1b$cluster_ci_hi[c4_1b$measure == "harmonicR2_pre2007"],
            c4_1b$cluster_ci_hi[c4_1b$measure == "ratio_ii_pre2007"],
            c3_site$cluster_ci_hi[c3_site$model == "i_rho~A1"],
            c3_site$cluster_ci_hi[c3_site$model == "ii_rho~phaseR"]),
  p = c(c4_1b$cluster_p[c4_1b$measure == "harmonicR2_pre2007"],
        c4_1b$cluster_p[c4_1b$measure == "ratio_ii_pre2007"],
        c3_site$cluster_p[c3_site$model == "i_rho~A1"],
        c3_site$cluster_p[c3_site$model == "ii_rho~phaseR"]),
  R2 = c(c4_1b$R2[c4_1b$measure == "harmonicR2_pre2007"],
         c4_1b$R2[c4_1b$measure == "ratio_ii_pre2007"],
         r2_of("A1"), r2_of("phase_R"))
)
write.csv(s11a, "Table_S11a_site_level_regressions.csv", row.names = FALSE)

c4_1c <- read.csv(ck4("check4_1c_mediation.csv"), stringsAsFactors = FALSE) %>% filter(partition_measure == "harmonicR2_pre2007")
s11b <- data.frame(
  model = c("rho ~ phase R alone", "rho ~ phase R + seasonal-cycle R2"),
  phaseR_coef = c(c4_1c$phaseR_coef_i, c4_1c$phaseR_coef_iii),
  phaseR_ci_lo = c(c4_1c$phaseR_ci_lo_i, c4_1c$phaseR_ci_lo_iii),
  phaseR_ci_hi = c(c4_1c$phaseR_ci_hi_i, c4_1c$phaseR_ci_hi_iii),
  partition_coef = c(NA, c4_1c$partition_coef_iii),
  partition_ci_lo = c(NA, c4_1c$partition_ci_lo_iii),
  partition_ci_hi = c(NA, c4_1c$partition_ci_hi_iii),
  VIF = c(NA, c4_1c$VIF_phaseR)
)
write.csv(s11b, "Table_S11b_mediation.csv", row.names = FALSE, na = "")

c4_1d <- read.csv(ck4("check4_1d_meta_regression.csv"), stringsAsFactors = FALSE)
c3_meta <- read.csv(ck3("check3_2c_meta_regression.csv"), stringsAsFactors = FALSE)
s11c <- data.frame(
  moderator = c("Mean seasonal-cycle R2", "Mean amplitude (A1)", "Mean timing precision (phase R)"),
  slope = c(c4_1d$slope[c4_1d$moderator == "mean_harmonicR2_pre2007"],
            c3_meta$slope[c3_meta$moderator == "mean_A1"],
            c3_meta$slope[c3_meta$moderator == "mean_phase_R"]),
  ci_lo = c(c4_1d$ci_lo[c4_1d$moderator == "mean_harmonicR2_pre2007"],
            c3_meta$ci_lo[c3_meta$moderator == "mean_A1"],
            c3_meta$ci_lo[c3_meta$moderator == "mean_phase_R"]),
  ci_hi = c(c4_1d$ci_hi[c4_1d$moderator == "mean_harmonicR2_pre2007"],
            c3_meta$ci_hi[c3_meta$moderator == "mean_A1"],
            c3_meta$ci_hi[c3_meta$moderator == "mean_phase_R"]),
  pct_heterogeneity_explained = c(c4_1d$pct_heterogeneity_explained[c4_1d$moderator == "mean_harmonicR2_pre2007"],
                                   c3_meta$pct_heterogeneity_explained[c3_meta$moderator == "mean_A1"],
                                   c3_meta$pct_heterogeneity_explained[c3_meta$moderator == "mean_phase_R"])
)
write.csv(s11c, "Table_S11c_region_meta_regression.csv", row.names = FALSE)

s11d <- read.csv(ck4("check4_2c_regressions.csv"), stringsAsFactors = FALSE)
write.csv(s11d, "Table_S11d_climate_mode_coupling.csv", row.names = FALSE)
cat("\nWrote Table_S11a-d (what predicts cue reliability)\n")
cat_check("S11a amplitude R2", sprintf("%.3f", s11a$R2[3]), "0.019")
cat_check("S11a phase_R R2", sprintf("%.3f", s11a$R2[4]), "0.084")
cat_check("S11b phaseR-alone coef", sprintf("%.3f", s11b$phaseR_coef[1]), "-1.022")
cat_check("S11c A1 moderator", sprintf("%.3f", s11c$slope[2]), "-0.016")
cat_check("S11d DMI alone", sprintf("%.3f", s11d$coef[s11d$predictor == "abs(r_dmi) alone"]), "-0.399")

# =============================================================================
# S12 -- Latitude relationships
# =============================================================================
s12 <- read.csv(ex("taskE4_latitude_regressions.csv"), stringsAsFactors = FALSE)
write.csv(s12, "Table_S12_latitude_relationships.csv", row.names = FALSE)
cat("\nWrote Table_S12_latitude_relationships.csv\n")
cat_check("A1~|lat| slope", sprintf("%.4f", s12$ols_slope[s12$y == "A1"]), "0.1349")

# =============================================================================
# S13 -- Amplitude step model (per-site summary, by-region, model comparison)
# =============================================================================
step_site <- read.csv(axck("checkA_per_site_step_models.csv"), stringsAsFactors = FALSE)

s13_overall <- data.frame(
  statistic = c("Mean step", "Median step", "SD across sites", "Sites with negative step", "Sites individually significant"),
  value = c(sprintf("%.3f degC", mean(step_site$step1_b2)), sprintf("%.3f degC", median(step_site$step1_b2)),
            sprintf("%.3f degC", sd(step_site$step1_b2)),
            sprintf("%d/%d (%.1f%%)", sum(step_site$step1_b2 < 0), nrow(step_site), 100 * mean(step_site$step1_b2 < 0)),
            sprintf("%d/%d", sum(step_site$step1_b2_fdr_significant == "True"), nrow(step_site)))
)
write.csv(s13_overall, "Table_S13a_amplitude_step_overall.csv", row.names = FALSE)

s13_region <- step_site %>% group_by(region) %>%
  summarise(mean_step_2007 = mean(step1_b2), negative = sum(step1_b2 < 0), total = n(), .groups = "drop") %>%
  transmute(region, mean_step_degC = mean_step_2007, negative_over_total = sprintf("%d/%d", negative, total)) %>%
  arrange(desc(mean_step_degC))
write.csv(s13_region, "Table_S13b_amplitude_step_by_region.csv", row.names = FALSE)

pick_min <- function(aic_cols) apply(step_site[, aic_cols], 1, which.min)
aic_pick <- pick_min(c("aic_trendonly", "aic_step1", "aic_step2"))
bic_pick <- pick_min(c("bic_trendonly", "bic_step1", "bic_step2"))
s13_modelcmp <- data.frame(
  criterion = c("BIC", "AIC"),
  trend_only = c(sprintf("%d/81", sum(bic_pick == 1)), sprintf("%d/81", sum(aic_pick == 1))),
  trend_plus_2007_step = c(sprintf("%d/81", sum(bic_pick == 2)), sprintf("%d/81", sum(aic_pick == 2))),
  trend_plus_two_steps = c(sprintf("%d/81", sum(bic_pick == 3)), sprintf("%d/81", sum(aic_pick == 3)))
)
write.csv(s13_modelcmp, "Table_S13c_model_comparison.csv", row.names = FALSE)
cat("\nWrote Table_S13a-c (amplitude step model)\n")
cat_check("mean step", s13_overall$value[1], "-0.030 degC")
cat_check("negative steps", s13_overall$value[4], "49/81 (60.5%)")
cat_check("BIC trend-only", s13_modelcmp$trend_only[1], "76/81")
cat_check("AIC trend-only", s13_modelcmp$trend_only[2], "62/81")

# =============================================================================
# S14 -- Changepoint clustering
# =============================================================================
cp_dist <- read.csv(ex("taskE5_changepoint_distribution.csv"), stringsAsFactors = FALSE)
cp_dist$n_combined <- cp_dist$n_at_2007 + cp_dist$n_at_2022
cp_dist$pct_combined <- cp_dist$pct_at_2007 + cp_dist$pct_at_2022
write.csv(cp_dist, "Table_S14_changepoint_clustering.csv", row.names = FALSE)
cat("\nWrote Table_S14_changepoint_clustering.csv\n")
cat_check("lag1_ac combined %", sprintf("%.1f%%", cp_dist$pct_combined[cp_dist$metric == "lag1_ac"]), "71.6%")

# =============================================================================
# S15 -- Spurious relationship generated by the processing discontinuity
# =============================================================================
checkB_site <- read.csv(axck("checkB_within_site_correlations.csv"), stringsAsFactors = FALSE)
checkB_cmp <- read.csv(axck("checkB_comparison_table.csv"), stringsAsFactors = FALSE)

frac_pos_pre <- mean(checkB_site$r_within_site_pre2007 > 0) * 100
frac_pos_full <- mean(checkB_site$r_within_site_full > 0) * 100
row_pre <- checkB_cmp[grepl("1982-2006", checkB_cmp$quantity), ]
row_full <- checkB_cmp[grepl("full record", checkB_cmp$quantity), ]

s15 <- data.frame(
  period = c("1982-2006 (artefact-free)", "Full record 1982-2025"),
  n_sites = c(81, 81),
  mean_r = c(row_pre$r, row_full$r),
  ci_lo = c(row_pre$ci_lo, row_full$ci_lo),
  ci_hi = c(row_pre$ci_hi, row_full$ci_hi),
  fraction_positive_pct = c(frac_pos_pre, frac_pos_full)
)
write.csv(s15, "Table_S15_spurious_relationship_artefact.csv", row.names = FALSE)
cat("\nWrote Table_S15_spurious_relationship_artefact.csv\n")
cat_check("pre2006 mean r", sprintf("%.3f [%.3f,%.3f]", s15$mean_r[1], s15$ci_lo[1], s15$ci_hi[1]), "-0.004 [-0.065,0.058]")
cat_check("pre2006 frac positive", sprintf("%.1f%%", s15$fraction_positive_pct[1]), "44.4%")
cat_check("full-record frac positive", sprintf("%.1f%%", s15$fraction_positive_pct[2]), "97.5%")

# =============================================================================
# S16 -- Marine heatwave metrics (pooled overall + by region, both baselines)
# =============================================================================
fixed_region <- read.csv(ex("taskE4_meta_analysis_by_region.csv"), stringsAsFactors = FALSE)
fixed_overall <- fixed_region %>% filter(region == "ALL_SITES_POOLED")
fixed_region <- fixed_region %>% filter(region != "ALL_SITES_POOLED")

moving_region <- read.csv(ck("check2d_moving_baseline_DL_pooled.csv"), stringsAsFactors = FALSE)
moving_site <- read.csv(ck("check2d_moving_baseline_effects.csv"), stringsAsFactors = FALSE)
moving_for_pool <- moving_site %>% transmute(region, effect = moving_baseline_effect,
                                               ci_lo = moving_baseline_ci_lo, ci_hi = moving_baseline_ci_hi)
moving_overall <- pool_by_region(moving_for_pool)$overall

s16a <- data.frame(
  baseline = c("Fixed 1982-2011 climatology (Hobday convention)", "Trend-following baseline (diagnostic)"),
  pooled_effect_days = c(fixed_overall$effect, moving_overall$pooled),
  ci_lo = c(fixed_overall$ci_lo, moving_overall$ci_lo),
  ci_hi = c(fixed_overall$ci_hi, moving_overall$ci_hi),
  I2 = c(fixed_overall$I2, moving_overall$I2)
)
write.csv(s16a, "Table_S16a_mhw_pooled_overall.csv", row.names = FALSE)

s16b <- fixed_region %>% transmute(region, fixed_baseline_days = effect, fixed_ci_lo = ci_lo, fixed_ci_hi = ci_hi) %>%
  left_join(moving_region %>% transmute(region, trend_following_days = pooled, moving_ci_lo = ci_lo, moving_ci_hi = ci_hi), by = "region") %>%
  arrange(desc(fixed_baseline_days))
write.csv(s16b, "Table_S16b_mhw_by_region.csv", row.names = FALSE)
cat("\nWrote Table_S16a/b (marine heatwave metrics)\n")
cat_check("fixed overall", sprintf("%.2f [%.2f,%.2f] I2=%.1f%%", s16a$pooled_effect_days[1], s16a$ci_lo[1], s16a$ci_hi[1], s16a$I2[1]), "8.78 [7.83,9.73] 44.0%")
cat_check("moving overall", sprintf("%.2f [%.2f,%.2f] I2=%.1f%%", s16a$pooled_effect_days[2], s16a$ci_lo[2], s16a$ci_hi[2], s16a$I2[2]), "1.50 [0.98,2.02] 19.7%")
cat_check("W.Atlantic/Caribbean fixed", sprintf("%.2f", s16b$fixed_baseline_days[s16b$region == "Western_Atlantic_Caribbean_Brazil"]), "20.81")

# =============================================================================
# S17 -- Warming rate in context (literature comparison)
# Literature rows are external citations transcribed as given in the
# manuscript text (not derived from this project's data); only the "this
# study" row and its footnote statistics are computed here.
# =============================================================================
t2 <- read.csv("Table_S2_site_metrics.csv", stringsAsFactors = FALSE)
m_slopes <- t2$M_trend
s17 <- data.frame(
  source = c("This study, pooled across 81 reef sites", "Bove et al. (2022)",
             "Bove et al. (2022), Southern and Eastern Caribbean", "Published multi-dataset comparison",
             "Published satellite SST climatology"),
  estimate = c(sprintf("%.3f degC decade-1", pick(pooled4, "M_full")$pooled * 10),
               "0.16-0.20 degC decade-1", "0.26 degC decade-1", "0.108-0.184 degC decade-1", "0.09 degC decade-1 mean"),
  period = c("1982-2025", "1981-2020", "since 1981/1984", "1982-2024", "1981-2018"),
  domain = c("reef pixels, global", "Caribbean reefs, basin-wide", "reef ecoregions", "60S-60N, global ocean", "global ocean")
)
write.csv(s17, "Table_S17_warming_rate_in_context.csv", row.names = FALSE)
cat(sprintf("\nWrote Table_S17_warming_rate_in_context.csv\n"))
cat_check("per-site M_trend range", sprintf("%.4f to %.4f", min(m_slopes), max(m_slopes)), "0.0002 to 0.0465")
cat_check("per-site M_trend median/mean", sprintf("%.4f / %.4f", median(m_slopes), mean(m_slopes)), "0.0225 / 0.0220")

# =============================================================================
# S18 -- Representativeness of the focal subset
# =============================================================================
orig9 <- read.csv(ex("taskE6_original9_percentiles.csv"), stringsAsFactors = FALSE)
med <- function(col) median(orig9[[col]])
s18 <- data.frame(
  quantity = c("Mean SST", "Seasonal amplitude", "Timing precision (phase R)", "Circular SD of timing",
               "Cue reliability", "Cue reliability (timing target)", "Colwell P, early block", "Colwell P, late block",
               "Marine heatwave frequency", "Marine heatwave duration", "Empirical-peak timing consistency [extra]"),
  median_percentile_of_focal_sites = c(
    sprintf("%.1f", med("M_percentile")), sprintf("%.1f", med("A1_percentile")),
    sprintf("%.1f", med("phase_R_percentile")), sprintf("%.1f", med("phase_sd_days_percentile")),
    sprintf("%.1f", med("rho_magnitude_percentile")), sprintf("%.1f", med("rho_timing_percentile")),
    sprintf("%.1f", med("colwell_P_bin1.0_early_percentile")), sprintf("%.1f", med("colwell_P_bin1.0_late_percentile")),
    sprintf("%.1f-%.1f", min(med("freq_early_percentile"), med("freq_late_percentile")), max(med("freq_early_percentile"), med("freq_late_percentile"))),
    sprintf("%.1f-%.1f", min(med("dur_early_percentile"), med("dur_late_percentile")), max(med("dur_early_percentile"), med("dur_late_percentile"))),
    sprintf("%.1f", med("photoperiod_R_percentile"))
  )
)
write.csv(s18, "Table_S18_focal_subset_representativeness.csv", row.names = FALSE)
cat("\nWrote Table_S18_focal_subset_representativeness.csv\n")
cat_check("Seasonal amplitude", s18$median_percentile_of_focal_sites[2], "78.4")
cat_check("Circular SD of timing", s18$median_percentile_of_focal_sites[4], "19.1")

# =============================================================================
# S19 -- Timing-precision cross-estimator agreement
# =============================================================================
tc_global <- read.csv(axck("timing_consistency_global.csv"), stringsAsFactors = FALSE)
tc_bybp <- read.csv(axck("timing_consistency_by_amplitude_breakpoint.csv"), stringsAsFactors = FALSE)
tc_corr <- read.csv(axck("timing_consistency_correlations.csv"), stringsAsFactors = FALSE)
# rename the "photoperiod_R vs ..." pair labels -- same confirmed misnomer as Table S2's
# empirical_peak_R (this IS the empirical-peak estimator, not a photoperiod quantity)
tc_corr$pair <- gsub("photoperiod_R", "empirical_peak_R", tc_corr$pair)

s19a <- data.frame(
  quantity = c("Empirical-peak consistency, all 81 sites",
               "Below the amplitude breakpoint", "Above the amplitude breakpoint"),
  median = c(tc_global$median, tc_bybp$median[grepl("below", tc_bybp$amp_class_breakpoint)],
             tc_bybp$median[grepl("above", tc_bybp$amp_class_breakpoint)]),
  iqr_lo = c(tc_global$iqr_lo, NA, NA), iqr_hi = c(tc_global$iqr_hi, NA, NA),
  min = c(tc_global$min, NA, NA), max = c(tc_global$max, NA, NA)
)
write.csv(s19a, "Table_S19a_cross_estimator_summary.csv", row.names = FALSE, na = "")
write.csv(tc_corr, "Table_S19b_cross_estimator_correlations.csv", row.names = FALSE)

n_below_08_harmonic <- sum(t2$phase_R < 0.8)
n_below_08_empirical <- sum(t2$empirical_peak_R < 0.8)
cat("\nWrote Table_S19a/b (timing-precision cross-estimator agreement)\n")
cat_check("global median/IQR/range", sprintf("%.3f [%.3f,%.3f] [%.3f,%.3f]", tc_global$median, tc_global$iqr_lo, tc_global$iqr_hi, tc_global$min, tc_global$max), "0.906 [0.823,0.949] [0.280,0.990]")
cat_check("sites below R<0.8 (empirical / harmonic)", sprintf("%d / %d", n_below_08_empirical, n_below_08_harmonic), "18 / 2")

# =============================================================================
# S20 -- Photoperiod as a seasonal cue
# =============================================================================
s20a_bp_range <- read.csv(pp("photoperiod_02c_by_breakpoint_daylength_range_hours.csv"), stringsAsFactors = FALSE)
s20a_bp_rate <- read.csv(pp("photoperiod_02c_by_breakpoint_max_rate_min_per_day.csv"), stringsAsFactors = FALSE)
s20a_q_range <- read.csv(pp("photoperiod_02c_by_quartile_daylength_range_hours.csv"), stringsAsFactors = FALSE)
s20a_q_rate <- read.csv(pp("photoperiod_02c_by_quartile_max_rate_min_per_day.csv"), stringsAsFactors = FALSE)
write.csv(s20a_bp_range, "Table_S20a1_photoperiod_by_breakpoint_range.csv", row.names = FALSE)
write.csv(s20a_bp_rate, "Table_S20a2_photoperiod_by_breakpoint_rate.csv", row.names = FALSE)
write.csv(s20a_q_range, "Table_S20a3_photoperiod_by_quartile_range.csv", row.names = FALSE)
write.csv(s20a_q_rate, "Table_S20a4_photoperiod_by_quartile_rate.csv", row.names = FALSE)

s20a_region_range <- read.csv(pp("photoperiod_02a_by_region_range.csv"), stringsAsFactors = FALSE) %>% arrange(median)
write.csv(s20a_region_range, "Table_S20a5_photoperiod_by_region.csv", row.names = FALSE)

s20b <- read.csv(pp("photoperiod_03a_by_region.csv"), stringsAsFactors = FALSE) %>%
  transmute(region, n = count, mean_lag_days = mean, median_lag_days = median, sd_lag_days = std) %>%
  arrange(mean_lag_days)
write.csv(s20b, "Table_S20b_solstice_peak_lag_by_region.csv", row.names = FALSE)

s20c <- read.csv(pp("photoperiod_03c_consistency.csv"), stringsAsFactors = FALSE)
write.csv(s20c, "Table_S20c_reparameterization_identities.csv", row.names = FALSE)

r_amp <- read.csv(pp("photoperiod_02b_correlation_with_A1.csv"), stringsAsFactors = FALSE)
cat("\nWrote Table_S20a1-5, S20b, S20c (photoperiod as a cue)\n")
cat_check("r(daylength_range, A1)", sprintf("%.2f", r_amp$r), "0.74")
cat_check("below-bp median daylength range", sprintf("%.3f", s20a_bp_range$median[grepl("below", s20a_bp_range$amp_class_breakpoint)]), "1.305")
cat_check("consistency identities max_abs_diff", paste(sprintf("%.1e", s20c$max_abs_diff), collapse = ", "), "~1e-13")

cat("\n=== All tables S1, S3-S20 written to submission/tables/ ===\n")
