# Supplementary figures (S1–S13) — status

**All built.** 12 in R (`R/S1_*.R` … `R/S13_*.R`, run from that directory;
each sources `theme_supp.R` for a shared style matched to Figures 1/2:
Okabe-Ito palette, 8pt minimum font, 10pt bold panel letters). One in
Python (`python/S9_residual_power_spectrum.py`) — the one figure that
reuses a validated Python function (`spectral_slope()`) rather than
porting it, since it's already checked against synthetic power-law series
with a known exponent; restyled to match the other 12 as closely as a
different plotting library allows. Every figure reads from
`submission/tables/*.csv` where possible, falling back to a working-repo
source table directly only where the needed per-site raw values weren't
already in a submission table (S4, S7, S8, S11 — noted per-figure below).

| # | Description | Script | Data source |
|---|---|---|---|
| S1 | Timing precision vs. amplitude, with breakpoint | `R/S1_timing_precision_vs_amplitude.R` | Table S2 + Table S8c; hinge curve refit via the validated `grid_search_breakpoint()` and checked to reproduce Table S8c's breakpoint |
| S2 | Global map of timing precision | `R/S2_global_map_timing_precision.R` | Table S2 |
| S3 | Forest plots, 3 axes | `R/S3_forest_plots_pooled_trends.R` | Table S2 (per-site) + Tables S4-S6 (region order) |
| S4 | Cue reliability vs. variance partition | `R/S4_cue_reliability_vs_variance_partition.R` | `extension/checks4/tables/check4_1a_partition_measures.csv` (per-site, not yet in a submission table) + Table S11a for the overlay line |
| S5 | Changepoint year histograms | `R/S5_changepoint_histograms.R` | Table S2 (`cp_lag1_ac`, `cp_resid_var`, `cp_A1`) |
| S6 | Geographic changepoint maps | `R/S6_changepoint_maps.R` | Table S2 |
| S7 | MHW duration, fixed vs. trend-following baseline | `R/S7_mhw_fixed_vs_trend_baseline.R` | `extension/checks/tables/check2d_fixed_vs_moving_merged.csv` (per-site, not yet in a submission table) |
| S8 | MHW duration forest plot | `R/S8_mhw_forest_plot.R` | `extension/tables/taskE4_mhw_duration_effects.csv` (per-site) + Tables S16a/b |
| S9 | Residual power spectrum | `python/S9_residual_power_spectrum.py` | `audit/processed_corrected/harmonic_residuals.csv`, 3 focal-9 sites |
| S10 | Latitude relationships (3 panel) | `R/S10_latitude_relationships.R` | Table S2 + Table S12 for overlay lines |
| S11 | Amplitude step magnitude by region | `R/S11_amplitude_step_by_region.R` | `extension/axes81/checks/tables/checkA_per_site_step_models.csv` (per-site, not yet in a submission table) + Table S13b |
| S12 | Photoperiod vs. thermal amplitude | `R/S12_photoperiod_vs_amplitude.R` | Table S2 + Table S8c (breakpoint reference line only, not fit to this relationship) |
| S13 | Solstice-to-peak lag vs. latitude | `R/S13_solstice_lag_vs_latitude.R` | Table S2 |

## Verification

Every figure was checked against its Methods/Results description in
`manuscript/Section2_supplementary.md` after building, not just for
successful rendering:

- S1: breakpoint refit from Table S2 (1.126) matches Table S8c exactly (`stopifnot` in the script enforces this).
- S2: imprecisely-timed sites cluster near the equator/Coral Triangle, precisely-timed sites at higher latitude — matches the described pattern.
- S5: lag-1 AC and residual variance both show a dominant 2005-2010 spike; amplitude shows no dominant peak, largest bin at 1985-1990 — matches exactly.
- S6: lag-1 AC map dominated by two colours (2007/2022) in every basin; amplitude map an even mix — matches.
- S7: nearly all points fall below the 1:1 line — matches "~83% of the fixed-baseline effect...disappears."
- S9: all three sites show power rising toward ~100 days and falling toward 10 days (a band-limited peak, not a monotonic decline), with low fit R² (0.02-0.17) — matches the "mean R²=0.10, not a power law" description.
- S12: r=0.74 annotation matches Table S20's photoperiod-amplitude correlation; breakpoint line is explicitly captioned as a reference from Table S8c, not a fit to this relationship (avoids overstating it, matching Table S20's own "this is a negative result" framing).

## One bug caught and fixed during this build

The literal string `"|latitude|"` rendered as **"llatitudel"** in ggplot's
default font (the pipe glyph collapses visually with lowercase L at this
size) — caught by looking at the rendered S10 output, not assumed correct
from the code. Fixed by using `"absolute latitude (deg)"` instead, in both
S10 and S13.

## What's not yet done

- No captions written separately from the manuscript's existing
  `Section2_supplementary.md` figure-legend prose.
- S3, S6, S8 are tall/dense (81-site or dual-map layouts) and have not
  been checked against a strict single-page GCB supplementary size limit
  the way Figures 1/2 were — worth a dedicated sizing pass if the journal
  enforces one.
- Three figures (S4, S7, S11) still read a per-site table directly from
  the working repo rather than from a `submission/tables/*.csv`, because
  the tables build pass didn't need that per-site granularity for any
  published Table S1-S20. Not a correctness issue (the working-repo
  source is the same validated table used throughout), but it means these
  three figures cannot be rebuilt from `submission/` alone without the
  parent working repo, unlike the other 10.
