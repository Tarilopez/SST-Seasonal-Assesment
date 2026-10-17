# Table S2 — per-site metrics — data dictionary

`Table_S2_site_metrics.csv`, 81 rows (one per reef site), 56 columns.
Assembled by `build_table_S2.R` from 11 already-computed, already-validated
per-site tables in the working repo (see that script's header comments for
the full source list) — no new statistics were computed for this table,
with one exception: `daylength_roc_at_peak` (see below), which had never
been computed anywhere before this table was assembled.

Columns marked **[extra]** are not part of the manuscript's published Table
S2 column dictionary but were already computed and validated upstream, so
were retained here rather than discarded — mainly bootstrap/uncertainty
intervals for a point estimate the manuscript's dictionary lists on its
own.

| Column | Description | Units |
|---|---|---|
| `site_id` | Site identifier | — |
| `region` | Region assignment (Table S1) | — |
| `lat`, `lon` | Resolved OISST pixel centre | degrees |
| `dist_from_nominal_km` | Distance from the nominal reef coordinate | km |
| `landmask_frac_3x3` | Land fraction of the surrounding 3×3 box | proportion — **entirely NA in this build**; see note below |
| `M_mean` | Mean annual SST, full record | °C |
| `M_trend`, `_ci_lo`, `_ci_hi` | Theil–Sen slope, annual mean, full record | °C yr⁻¹ |
| `A1_mean` | Mean annual harmonic amplitude, full record | °C |
| `A1_trend`, `_ci_lo`, `_ci_hi` | Amplitude trend, naive full record | °C yr⁻¹ |
| `A1_trend_step_adj`, `_ci_lo`, `_ci_hi` **[extra CI]** | Amplitude trend, two-step-adjusted model (the recommended estimate) | °C yr⁻¹ |
| `A1_step_2007`, `A1_step_2022` | Fitted step magnitudes | °C |
| `phase_doy_mean` | Circular mean day of year of thermal maximum, full record | day |
| `phase_R` | Mean resultant length of annual phase, full record | — |
| `phase_sd_days` | Circular SD, exact expression, full record | days |
| `phase_shift_days`, `_ci_lo`, `_ci_hi` | First-to-last 15-year shift, full record | days |
| `rho_magnitude`, `_ci_lo`, `_ci_hi` | Cue reliability, peak-magnitude target | — |
| `rho_timing`, `rho_timing_p` | Cue reliability, peak-timing target (circular–linear r, permutation p) | — |
| `harmonic_R2_pre2007` | Variance explained by the seasonal cycle, 1982–2006 | proportion |
| `harmonic_R2_full` **[extra]** | Same, full record | proportion |
| `colwell_P_0p5`, `_1p0`, `_2p0` | Colwell predictability, three bin widths, full record | — |
| `mhw_freq_early`, `_late` | Marine heatwave frequency by block | events yr⁻¹ |
| `mhw_dur_early`, `_late` | Marine heatwave mean duration by block | days |
| `lag1_ac_pre2007` | Daily residual lag-1 autocorrelation, 1982–2006 | — |
| `cp_lag1_ac`, `_ci_lo`, `_ci_hi` **[extra CI]** | Detected changepoint year, daily residual lag-1 AC | year |
| `cp_A1`, `_ci_lo`, `_ci_hi` **[extra CI]** | Detected changepoint year, seasonal amplitude | year |
| `cp_resid_var`, `_ci_lo`, `_ci_hi` **[extra CI]** | Detected changepoint year, annual residual variance | year |
| `empirical_peak_R` | Timing consistency, empirical-peak estimator | — |
| `daylength_range_h` | Annual daylength range (longest minus shortest day) | hours |
| `daylength_roc_max` | Maximum rate of change of daylength, at the equinoxes | min day⁻¹ |
| `daylength_roc_at_peak` | Rate of change of daylength at the site's own climatological thermal peak date | min day⁻¹ |
| `solstice_peak_lag_days`, `_ci_lo`, `_ci_hi` | Mean signed lag between thermal peak and local summer solstice | days |

## Notes on two columns that needed special handling

**`landmask_frac_3x3`** is entirely `NA` in this build. Searched the
working repo before assembling this table: the nearest-ocean-pixel
utility (`extension/scripts/11_taskE1_nearest_ocean_pixel.py`) queries the
OISST land-sea mask point-by-point to find each site's nearest ocean
pixel, but never computes or retains a 3×3-neighbourhood ocean fraction
around it. This is a genuine gap, not an oversight in this join — filling
it would require a live re-query of the OISST land-sea mask THREDDS
endpoint (8 neighbouring points × 81 sites) and hasn't been done.

**`empirical_peak_R`** is read from `taskE3_site_metrics.csv`'s column
`photoperiod_R`, deliberately **renamed** on the way in. That source
column name is a confirmed misnomer: it holds the empirical-peak timing-
consistency estimator (Table S19), unrelated to photoperiod, per
`output/decisions.md`'s 2026-09-15 "CORRECTION" entry and
`extension/axes81/checks/TIMING_CONSISTENCY_CORRECTION.md`. The misleading
name was not carried into this table.

**`daylength_roc_at_peak`** did not exist anywhere in the working repo
before this table was built. Computed by
`extension/axes81/photoperiod/scripts/04_photoperiod_rate_at_peak.py`,
which reuses the already-validated `daylength_hours()` function
(`src/lib/photoperiod.py`, validated in `photoperiod_01_validation.csv`)
unmodified — no new daylength model was written. Sanity-checked: this
value never exceeds `daylength_roc_max` at the same site (0/81 violations,
as it must be, since `daylength_roc_max` is that site's maximum by
definition).

## Verification

Before treating this table as final, every pooled aggregate recomputable
from it was checked against the manuscript's own canonical numbers (using
the already-validated `pool_by_region()` / `grid_search_breakpoint()` code
in `../figures/main/figure2/R/`), not just spot-read:

| Check | From Table S2 | Canonical (Supplementary Tables) | Match |
|---|---|---|---|
| Pooled M trend, all 81 | 0.02222 [0.02075, 0.02369] | 0.0222 [0.0208, 0.0237] (Table S3) | yes |
| Pooled A1 trend (naive), all 81 | 0.00170 [0.00062, 0.00278] | 0.0017 [0.0006, 0.0028] (Table S3) | yes |
| Pooled phase shift, all 81 | 0.856 [-0.112, 1.824] | 0.86 [-0.11, 1.82] (Table S3) | yes |
| Regional phase shift, W. Atlantic/Caribbean | 6.070 [3.021, 9.119] | 6.07 [3.02, 9.12] (Table S6) | yes |
| Regional phase shift, W. Indian Ocean | -2.879 [-4.556, -1.203] | -2.88 [-4.56, -1.20] (Table S6) | yes |
| Breakpoint, phase_sd_days ~ A1_mean | 1.126 | 1.126 [0.974, 1.233] (Table S8) | yes |
| Pooled rho_magnitude, all 81 | 0.2279 [0.181, 0.275] | 0.222 [0.160, 0.283] (Table S3/S10) | close but not exact — see note |

The rho_magnitude discrepancy (0.228 vs. 0.222) is not a join error: it's
the same, already-documented gap between two valid region-level pooling
passes over the same per-site data (this table's numbers were independently
re-derived once before, in `r_figure2/`, with the identical result and the
same explanation — see that build's `BUILD_NOTES.md`). All per-site
`rho_magnitude` values themselves are a direct, unmodified copy from
`taskE3_site_metrics.csv`.
