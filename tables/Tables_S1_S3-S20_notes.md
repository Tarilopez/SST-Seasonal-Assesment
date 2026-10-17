# Tables S1, S3–S20 — build notes

Built by `build_tables_S1_S3-S20.R` (run from this directory; reads from
the working repo above `submission/`, same as `build_table_S2.R`). Where a
manuscript table has multiple distinct sub-parts (e.g. S8's breakpoint
class / quartile / hinge model / photoperiod comparison), each part is a
separate CSV (`Table_S8a_...`, `Table_S8b_...`, etc.) rather than forcing
unlike shapes into one file.

No new statistical models were fit for any of these tables. Every number
is either a direct extract/rename from an existing, already-validated
per-site or per-region table, a simple groupby summary (median/IQR/range,
mean/SD) over one, or — in exactly two places — a region-level
DerSimonian-Laird pooling pass using the same already-validated
`pool_by_region()` code Table S2 and Figure 2 were verified with (S16's
overall trend-following-baseline MHW effect, which had no existing
"all-sites" pooled row, only by-region ones).

## Verification

Every table was checked against the corresponding published number in
`manuscript/Section2_supplementary.md` at build time (see the script's
`cat_check()` output, reproduced in full in `output/decisions.md`'s entry
for this build). All matched, with two exceptions — both small,
independently-reproducible discrepancies between two valid-but-different
prior computations over the same underlying data, not errors introduced
by this build:

| Table | This build | Manuscript text | Note |
|---|---|---|---|
| S3, amplitude trend step-adjusted (one step) | +0.0023 °C/yr [+0.0011, +0.0036] | +0.0024 °C/yr [+0.0011, +0.0036] | CI matches closely; point estimate differs by 0.0001 °C/yr. Sourced from `checkA_pooled_b1_comparison.csv`'s `step_adjusted_1step` row — the only file in the working repo holding this specific pooled estimate. |
| S3, cue reliability (region-level RE) | 0.221 [0.160, 0.283] | 0.222 [0.160, 0.283] | Same already-documented ~0.001 gap seen when this quantity was independently re-derived a third time during the R port of Figure 2 (`r_figure2/BUILD_NOTES.md`) and again in Table S2's own verification. Sourced here from `check1_pooled_comparison.csv`'s DL row, the authoritative source also used for Table S10. |

Neither was adjusted to force a match — both are reported as computed.

## Source map (table → working-repo file(s))

| Table | Source(s) |
|---|---|
| S1 | `extension/HANDOFF2.md` (prose table; never written to CSV anywhere — transcribed) |
| S3 | `extension/axes81/tables/axes81_2a_pooled.csv` + `extension/axes81/checks/tables/checkA_pooled_b1_comparison.csv` + `extension/checks/tables/check1_pooled_comparison.csv` |
| S4/S5/S6 | `extension/axes81/tables/axes81_2b_regional.csv` (filtered by `axis_label`) |
| S7 | `extension/axes81/checks/tables/phase_envelope_by_region.csv` |
| S8a–d | `extension/axes81/checks/tables/phase_envelope_by_amplitude_class_breakpoint.csv`, `phase_envelope_by_amplitude_class.csv`, `extension/axes81/tables/axes81_2d_breakpoint.csv`, `extension/axes81/photoperiod/tables/photoperiod_02d_breakpoint.csv` |
| S9/S10 | `extension/checks/tables/check1_per_region.csv`, `check1_pooled_comparison.csv` |
| S11a | `extension/checks4/tables/check4_1b_regressions.csv` (rows 1–2) + `extension/checks3/tables/check3_2a_site_level_models.csv` (rows 3–4; R² for these two derived as r² from `check3_1a_correlation_matrix.csv`, confirmed to reproduce the published 0.019/0.084 exactly) |
| S11b | `extension/checks4/tables/check4_1c_mediation.csv` |
| S11c | `extension/checks4/tables/check4_1d_meta_regression.csv` (row 1) + `extension/checks3/tables/check3_2c_meta_regression.csv` (rows 2–3) — Check 4 only redid the variance-partition moderator; the amplitude/phase-R moderators are Check 3's and were never redone in Check 4 |
| S11d | `extension/checks4/tables/check4_2c_regressions.csv` |
| S12 | `extension/tables/taskE4_latitude_regressions.csv` |
| S13a–c | `extension/axes81/checks/tables/checkA_per_site_step_models.csv` (S13c's BIC/AIC model-comparison counts computed here by per-site `which.min` over the three stored AIC/BIC columns — not previously tallied anywhere as a table) |
| S14 | `extension/tables/taskE5_changepoint_distribution.csv` |
| S15 | `extension/axes81/checks/tables/checkB_within_site_correlations.csv` (fraction-positive computed here) + `checkB_comparison_table.csv` (mean r + CI) |
| S16a | `extension/tables/taskE4_meta_analysis_by_region.csv` (fixed baseline, has an `ALL_SITES_POOLED` row already) + a new overall pool of `extension/checks/tables/check2d_moving_baseline_effects.csv`'s 81 site-level moving-baseline effects (no existing all-sites moving-baseline pooled row) |
| S16b | `taskE4_meta_analysis_by_region.csv` (fixed, by region) + `extension/checks/tables/check2d_moving_baseline_DL_pooled.csv` (moving, by region) |
| S17 | This-study row computed from `Table_S2_site_metrics.csv`'s `M_trend` column; literature comparison rows are external citations transcribed from the manuscript text, not derived from this project's data |
| S18 | `extension/tables/taskE6_original9_percentiles.csv` (median across the 9 focal sites per metric, computed here) |
| S19a/b | `extension/axes81/checks/tables/timing_consistency_global.csv`, `timing_consistency_by_amplitude_breakpoint.csv`, `timing_consistency_correlations.csv` — column/row labels renamed from `photoperiod_R` to `empirical_peak_R`, same confirmed misnomer as Table S2 |
| S20a1–5 | `extension/axes81/photoperiod/tables/photoperiod_02c_by_breakpoint_*.csv`, `_by_quartile_*.csv`, `photoperiod_02a_by_region_range.csv` |
| S20b | `extension/axes81/photoperiod/tables/photoperiod_03a_by_region.csv` |
| S20c | `extension/axes81/photoperiod/tables/photoperiod_03c_consistency.csv` |

## Notes

- **S11a/S11c span two different Check pipelines** (Check 3 and Check 4)
  because Check 4 only redid the variance-partition-related predictors;
  the amplitude and phase-R rows were never recomputed in Check 4 and are
  taken from Check 3 as-is. This mirrors the same precedence the prior
  repo inventory flagged (Check 4 supersedes Check 3 *where they overlap*,
  not entirely).
- **S19's `photoperiod_R` columns were renamed** to `empirical_peak_R` on
  the way in, identically to Table S2 — the same confirmed-misnomer source
  column feeds both.
- **S13c (BIC/AIC model-comparison counts)** and **S16a's overall
  trend-following MHW effect** are the only two genuinely new
  computations in this batch (a per-site argmin tally, and one DL pool
  call); everything else is a direct extract or a groupby summary of
  numbers that already existed. Both reproduced their published
  manuscript values exactly.
