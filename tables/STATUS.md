# Supplementary tables (S1–S20) — status

**All built.** S2 via `build_table_S2.R`; S1 and S3–S20 via
`build_tables_S1_S3-S20.R`. Full source map, verification results, and the
two small flagged discrepancies are in `Tables_S1_S3-S20_notes.md`
(S2's own notes are in `Table_S2_data_dictionary.md`).

| # | Description | Output file(s) |
|---|---|---|
| S1 | Site selection by region | `Table_S1_site_selection.csv` |
| S2 | Per-site metrics (full, 56 cols) | `Table_S2_site_metrics.csv` |
| S3 | Pooled estimates, 4 axes | `Table_S3_pooled_estimates.csv` |
| S4 | Mean trend by region | `Table_S4_mean_trend_by_region.csv` |
| S5 | Amplitude trend by region | `Table_S5_amplitude_trend_by_region.csv` |
| S6 | Phase shift by region | `Table_S6_phase_shift_by_region.csv` |
| S7 | Timing precision by region | `Table_S7_timing_precision_by_region.csv` |
| S8 | Timing precision by amplitude | `Table_S8a-d_*.csv` (breakpoint class / quartile / hinge model / photoperiod comparison) |
| S9 | Cue reliability by region | `Table_S9_cue_reliability_by_region.csv` |
| S10 | Pooling-method sensitivity | `Table_S10_pooling_method_sensitivity.csv` |
| S11 | What predicts cue reliability | `Table_S11a-d_*.csv` (site-level regressions / mediation / meta-regression / climate-mode coupling) |
| S12 | Latitude relationships | `Table_S12_latitude_relationships.csv` |
| S13 | Amplitude step model | `Table_S13a-c_*.csv` (overall / by region / model comparison) |
| S14 | Changepoint clustering | `Table_S14_changepoint_clustering.csv` |
| S15 | Spurious-relationship artefact | `Table_S15_spurious_relationship_artefact.csv` |
| S16 | Marine heatwave metrics | `Table_S16a_mhw_pooled_overall.csv`, `Table_S16b_mhw_by_region.csv` |
| S17 | Warming rate in context | `Table_S17_warming_rate_in_context.csv` |
| S18 | Focal-subset representativeness | `Table_S18_focal_subset_representativeness.csv` |
| S19 | Timing-precision cross-estimator agreement | `Table_S19a-b_*.csv` |
| S20 | Photoperiod as a cue | `Table_S20a1-5_*.csv`, `Table_S20b_*.csv`, `Table_S20c_*.csv` |

## What's not yet done

- Neither build script has been re-run from a completely clean checkout
  (they depend on the working repo above `submission/`, which is
  intentionally not itself part of this submission repo — see each
  script's header comment).
- Table captions/titles as they'll appear in the manuscript supplement
  haven't been written separately from `manuscript/Section2_supplementary.md`'s
  existing prose descriptions — the CSVs are the data, not yet formatted
  supplementary-table objects (e.g. as Word/LaTeX tables).
- Two small numeric discrepancies against the manuscript text remain
  unresolved (not blocking, both explicitly flagged in
  `Tables_S1_S3-S20_notes.md` and `Table_S2_data_dictionary.md`): the
  amplitude one-step trend point estimate (0.0023 vs 0.0024) and the
  region-level-RE pooled rho (0.221 vs 0.222).
