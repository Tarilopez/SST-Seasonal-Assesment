---
output:
  word_document: default
  html_document: default
  pdf_document: default
---
# Supplementary Material 

This document contains the supplementary methods, tables, and figure captions supporting Section 2.

---

# Supplementary Methods

## S1.1 Data source and retrieval

Daily sea surface temperature was obtained from the NOAA Optimum Interpolation SST product, version 2.1, at 0.25° resolution (Reynolds et al. 2007; Banzon et al. 2016; Huang et al. 2021), for 1 January 1982 to 31 December 2025 (44 complete calendar years).

Retrieval used daily global files from the NOAA NCEI archive, downloaded one year at a time, with all site pixels extracted from each day's file before the raw file was deleted. This staged approach was adopted after an aggregation endpoint was found to return HTTP 200 with well-formed but silently incomplete data for long time-span queries, omitting 28% of days in 1993–1998 in a manner reproducible across repeated identical requests. That artefact was identified by comparison against two independent access paths and against the per-day archive, and is documented in the project decision log.

Coverage was verified per site-year by day count. All 3,564 site-years (81 sites × 44 years) reached at least 99% daily coverage; no site-year was excluded.

## S1.2 Site selection

Candidate reef locations were drawn from the UNEP-WCMC Global Distribution of Warm-Water Coral Reefs, version 4.1 (UNEP-WCMC et al. 2021), polygon layer (17,504 features). The accompanying point layer was inspected first and rejected: it contains 925 features, all within the Eastern Pacific and Gulf of California, and is not a global sample. Each polygon was represented by the mean of its exterior-ring vertices, which is adequate for site sampling but not for area or shape analysis.

Candidates were assigned to ten geographic regions defined by bounding boxes. Within each region, candidates were shuffled and then declustered at a 100 km minimum separation, and up to eight sites were accepted per region. Thirty-six candidate points (0.2%) fell outside all region boxes and were excluded.

Each accepted candidate was mapped to the nearest valid ocean pixel using the OISST land–sea mask, rejecting any candidate whose nearest ocean pixel lay more than 50 km from the nominal coordinate. The nearest-ocean-pixel utility was validated by confirming that it reproduced, exactly, nine previously and independently verified site pixels, including one site where the nominal coordinate falls on land at this resolution and required a 14 km correction.

The final set comprises 72 newly selected sites plus nine retained focal sites, for 81 total (Table S1). Two regions yielded fewer than the target eight sites because their candidate pools are genuinely small.

Site coordinates are reported in Table S2. Under the UNEP-WCMC General Data Licence (excluding WDPA), publication of derived, non-downloadable content is permitted with attribution, while redistribution of the source layer is not. The downloadable per-site metrics file is therefore keyed by site identifier.

## S1.3 Harmonic decomposition

For each site and each calendar year, daily SST was fitted by ordinary least squares to

SST(t) = M + A₁cos(2πt − φ₁) + A₂cos(4πt − φ₂) + ε(t),

implemented in linear form as SST ~ 1 + cos(2πt) + sin(2πt) + cos(4πt) + sin(4πt), with t the fractional year computed with explicit leap-year handling.

M is the annual mean, A₁ = √(b_cos² + b_sin²) the amplitude of the annual cycle, and φ₁ the phase, converted to the day of year of the fitted annual maximum. The semi-annual term captures departures from a pure sinusoid. A comparison of one-, two-, and three-harmonic fits by AIC showed mean AIC decreasing monotonically with harmonic order, which is expected given autocorrelated daily residuals and does not by itself endorse the higher-order model; the marginal improvement from one to two harmonics substantially exceeded that from two to three, and the two-harmonic model specified a priori was retained.

Residual autocorrelation means that naive standard errors from this fit are not usable. All uncertainty is therefore bootstrap-based (S1.8).

## S1.4 Phase and circular statistics

Phase is a circular quantity, and arithmetic means, standard deviations, ordinary regression, and Pearson correlation are inappropriate for it. All phase quantities use circular methods.

Interannual consistency of timing is summarized by the mean resultant length R of the per-year phase angles. R is converted to a circular standard deviation in days using the exact wrapped-normal expression σ = √(−2 ln R). The small-dispersion approximation σ ≈ √(2(1 − R)) was computed alongside and agrees to within 0.2% at most sites, but diverges materially at low R; the exact expression is used throughout. Sites where R falls below 0.8 are flagged, since expressing timing dispersion as a standard deviation in days becomes unstable in that regime.

Phase trends were tested by circular–linear correlation against year with a 10,000-permutation test. Directional shift is additionally expressed as the difference in circular mean phase between the first and last 15 non-overlapping years of the record, in days, with a bootstrap confidence interval. Pooled and regional phase quantities were never computed by arithmetic averaging of day-of-year values.

### S1.5 Photoperiod

Daylength was computed from latitude and day of year using the CBM model of Forsythe et al. (1995), with a daylength coefficient of p = 0.8333° accounting for the solar disc and atmospheric refraction. The implementation was validated before use against known values: daylength at the equator is near-constant at approximately 12.1 hours; the tropics show the expected solstitial extremes; daylength reaches 24 hours at high northern latitude on the June solstice; and the annual maximum falls in December at southern sites, confirming correct hemisphere handling. At 66.5°N on the December solstice the model returns 2.24 hours rather than zero, which is correct behaviour for a refraction-corrected model: the polar-night boundary under this convention lies near 67.4°N rather than at the geometric Arctic Circle, and daylength reaches exactly zero at and above that latitude.

Three quantities were derived per site. Annual daylength range is the difference between the longest and shortest day. Maximum rate of change of daylength is evaluated at the equinoxes. Rate of change at the peak is evaluated at the site's own climatological thermal peak date, which differs from the maximum because sites peaking near a solstice sit where daylength is momentarily flat while sites peaking nearer an equinox sit where it changes fastest.

The solstice-to-peak lag is the signed circular difference in days between each year's thermal peak and the local summer solstice, using a fixed nominal solstice day of year per hemisphere. Sub-day astronomical precision is not used elsewhere in this analysis and is not warranted here.

Because the solstice is astronomically fixed, several photoperiod-referenced quantities are exact reparameterizations of results reported elsewhere. Subtracting a fixed date from every year's peak changes the circular mean of the resulting lag but not its circular spread, so the interannual standard deviation of the solstice-to-peak lag is identical to the circular standard deviation of phase (Table S7), and the change in mean lag over the record is identical to the phase shift (Table S6). Both were computed independently and agreed with the previously reported values to floating-point precision, which serves as a verification of the new code rather than as an additional result. They are reported as such in Table S20.

## S1.6 Cue reliability

Cue reliability ρ is the correlation between an early-season environmental cue and a later seasonal target, and is the parameter governing whether anticipatory plasticity is adaptive in formal models of plasticity under environmental uncertainty (Tufto 2000; Reed et al. 2010; Chevin et al. 2010; Bonamour et al. 2019; Botero et al. 2015).

The cue is the mean detrended SST anomaly over a 30-day window centred 90 days before each site's own climatological peak. Defining the window relative to local phase rather than by fixed calendar months makes sites with different seasonal timing comparable. Sensitivity to this choice was tested across offsets of 60, 90, and 120 days and widths of 15, 30, and 45 days, and across two biologically motivated alternative cues (the rate of spring warming, and the preceding winter minimum), with results reported both per window and under multiplicity correction.

Two targets were used. Peak magnitude is the annual maximum of a 7-day rolling mean, detrended. Peak timing is the day of year of that maximum, for which circular–linear correlation with a permutation test is used, because the circular–linear statistic is non-negative by construction and a bootstrap interval on it does not straddle zero even under a true null.

A peak-search-independent alternative target, the mean anomaly over a fixed 30-day window centred on each site's climatological peak day, was computed as a robustness check on attenuation by imprecise peak identification.

## S1.7 Colwell predictability

Colwell's (1974) predictability index P, with its decomposition into constancy C and contingency M, was computed on monthly-aggregated, detrended SST at three state-bin widths (0.5, 1.0, and 2.0 °C). P is sensitive to the discretization used; all three bin widths are reported rather than a single value, and the within-site spread across bin widths is reported as a measure of that sensitivity.

## S1.8 Trend estimation

Trends in annual quantities were estimated by Theil–Sen slope with both the original Mann–Kendall test and the Hamed and Rao (1998) modification for serial autocorrelation, with both raw and corrected p-values reported. Multiplicity was controlled by the Benjamini–Hochberg procedure within each family of 81 site-level tests, applied separately by axis and by period rather than pooled.

Moving-window trend tests were not used. An earlier analysis using 15-year windows stepped by one year was found, by phase-randomized surrogate simulation preserving the residual autocorrelation structure, to have an empirical false-positive rate of 43–49% at a nominal 5% level, because consecutive windows overlap by 93% and the effective sample size is approximately 3–6 rather than the nominal 30. All trend results reported here use annual series.

Because amplitude showed possible sensitivity to a documented change in the satellite product (S1.9), amplitude trends were additionally estimated from an explicit trend-plus-step model,

A₁(year) = b₀ + b₁·year + b₂·I(year ≥ 2007) + b₃·I(year ≥ 2022),

fitted by OLS with year-level bootstrap confidence intervals, and validated against synthetic series with known slope and step magnitudes before application.

## S1.9 Pooling, spatial dependence, and uncertainty

Reef sites are spatially autocorrelated, so detection counts across sites are not informative and per-site tests are individually underpowered. All summary estimates are therefore random-effects pooled estimates (DerSimonian–Laird), reported globally and by region, with τ² and I².

Spatial dependence was quantified directly. Moran's I on cue reliability across the 81 sites is 0.313 (p = 0.001, 999 permutations). Between-region correlations are substantially stronger than within-region correlations for latitude-associated quantities. A conservative floor on the number of effectively independent locations, taken as the number of regions with at least two sites, is 11. Region-clustered standard errors are used for site-level regressions, with the caveat that 11 clusters is below the range conventionally considered adequate for cluster-robust inference; naive and cluster-robust results are reported side by side throughout.

Confidence intervals are bootstrap intervals with a fixed random seed. Year-level case resampling (n = 5,000) is used for year-level quantities. A moving-block bootstrap was tested for lag-1 autocorrelation and found to fail validation (0% coverage of the true value on synthetic AR(1) series, with large negative bias), because concatenating short blocks introduces one artificial near-zero-correlation pair per seam and lag-1 autocorrelation is an adjacency-defined statistic; it was not used. Year-level resampling for that statistic shows coverage of 83–89% against a nominal 95%, with negligible bias, so point estimates are sound and intervals are somewhat optimistic; an analytic alternative (Anderson 1942) achieving 91–95% coverage is reported alongside.

Statistical power was estimated by simulation using the observed noise structure. With 15 years per block, the block-comparison design reliably detects only large changes in cue reliability (approximately 0.9 correlation units at 80% power), changes in amplitude of about 0.3 °C, and shifts in phase of about 7–8 days at typical sites. Null results from that design are reported as underpowered rather than as evidence of stability.

## S1.10 Changepoint detection and the artefact screen

Second-order statistics derived from gridded SST products can contain discontinuities arising from changes in the product's input processing rather than from the ocean. All quantities were therefore screened.

Changepoints were detected on annual series using binary segmentation with a single breakpoint, with a 2,000-replicate residual bootstrap confidence interval on the breakpoint year. The method was validated on synthetic step series, recovering the known breakpoint exactly in 98–100% of replicates across realistic noise levels.

The screen identified cross-basin-synchronous changepoints in daily-residual autocorrelation and in annual residual variance at 2007 and 2022 (Table S14), but not in annual mean, phase, Colwell predictability, or cue reliability. Both dates correspond to documented changes in the product: a transition from single-satellite reprocessed input to dual-satellite operational input effective 1 January 2007, together with a simultaneous change in the in-situ input source (Banzon et al. 2016, Tables 1 and 2), and a change from one satellite retrieval algorithm to another effective 1 October 2021. An independently processed satellite product and the nearest available in-situ record reproduce neither cluster.

Because the change affects both annual mean and residual persistence at the same dates, correlations between them computed across the full record are inflated (Table S15). Quantities derived from daily variance or persistence structure are therefore reported on the 1982–2006 subperiod as primary, with the full record alongside.

## S1.11 Estimator validation

Every estimator was checked against a known analytic answer before application. Summarized: harmonic fit recovers known mean, amplitude, and peak day exactly, including across leap years; circular mean and resultant length behave correctly on a distribution straddling the year boundary, where the arithmetic mean fails by more than 180 days; Colwell's P = C + M identity holds across 200 random parameterizations and at both limiting cases; Theil–Sen recovers a known slope and the Hamed–Rao correction is more conservative under genuine AR(1) but not otherwise; the spectral slope estimator recovers known exponents for white and red noise exactly; the breakpoint estimator recovers a known synthetic breakpoint with coverage; the trend-plus-step model recovers known slope and step magnitudes; the daylength model reproduces known values at the equator, tropics, polar circle, and equinoxes, with correct hemisphere handling.

Twenty-three of 23 core implementation checks passed, and no implementation error was found in any estimator used. Failures that were found and reported concern the applicability of methods rather than their implementation: the moving-block bootstrap for lag-1 autocorrelation (S1.8), and the spectral slope, which is not estimable from these data because the residual spectrum is not a power law (S1.11).

## S1.12 Spectral structure of residual variability

A single spectral exponent is a poor description of reef SST residual variability. Across all 243 site-windows examined, the fit of log-power against log-frequency over the 10-day to 2-year band had R² below 0.5 (mean 0.10). The binned periodogram shows power rising from the 2-year toward the 100-day timescale and falling from 100 days toward 10 days, a band-limited peak rather than a monotonic power-law decline (Figure S9). Frameworks that characterize environmental variability by a single "colour" (Vasseur and Yodzis 2004) assume approximate power-law scaling that these data do not exhibit. The spectral shape itself is the more informative description, and spectral exponents are reported as unreliable throughout rather than presented as estimates.

## S1.13 Data and code availability

All analysis code, per-site daily series, intermediate tables, and validation outputs are archived at github (see data accessibility statement). The per-site metrics file (Table S2) is provided in full. Reef distribution data are subject to the UNEP-WCMC General Data Licence and are not redistributed; site coordinates in Table S2 are the resolved OISST pixel centres computed in this study.

---

# Supplementary Tables

## Table S1. Site selection by region

| Region | Raw candidates | After 100 km declustering | Accepted | Rejected (land mask) |
|---|---|---|---|---|
| Australia | 1,655 | 54 | 8 | 0 |
| Central Indian Ocean | 6,496 | 55 | 8 | 0 |
| Coral Triangle and SE Asia | 4,451 | 295 | 8 | 1 |
| Eastern Atlantic and West Africa | 13 | 7 | 6 | 1 |
| Eastern Pacific | 8 | 2 | 2 | 0 |
| Red Sea and Persian Gulf | 857 | 52 | 8 | 0 |
| South Central Pacific and Polynesia | 334 | 60 | 8 | 0 |
| Western Atlantic, Caribbean and Brazil | 917 | 108 | 8 | 0 |
| Western Central Pacific | 1,367 | 95 | 8 | 0 |
| Western Indian Ocean | 1,370 | 87 | 8 | 0 |
| Focal subset (retained, not re-selected) | — | — | 9 | — |
| **Total** | | | **81** | |

The Eastern Atlantic and Eastern Pacific regions fall short of the eight-site target because their candidate pools are genuinely small, not because sites were rejected.

## Table S2. Per-site estimates (provided as a data file)

Full per-site table, 81 rows, provided as `site_metrics.csv`. Column dictionary:

| Column | Description | Units |
|---|---|---|
| `site_id` | Site identifier | — |
| `region` | Region assignment (Table S1) | — |
| `lat`, `lon` | Resolved OISST pixel centre | degrees |
| `dist_from_nominal_km` | Distance from the nominal reef coordinate | km |
| `landmask_frac_3x3` | Land fraction of the surrounding 3×3 box | proportion |
| `M_mean` | Mean annual SST, full record | °C |
| `M_trend` | Theil–Sen slope, annual mean | °C yr⁻¹ |
| `M_trend_ci_lo`, `_hi` | Bootstrap 95% interval | °C yr⁻¹ |
| `A1_mean` | Mean annual harmonic amplitude | °C |
| `A1_trend`, `_ci_lo`, `_ci_hi` | Amplitude trend, naive full record | °C yr⁻¹ |
| `A1_trend_step_adj` | Amplitude trend, step-adjusted model | °C yr⁻¹ |
| `A1_step_2007`, `A1_step_2022` | Fitted step magnitudes | °C |
| `phase_doy_mean` | Circular mean day of year of thermal maximum | day |
| `phase_R` | Mean resultant length of annual phase | — |
| `phase_sd_days` | Circular SD, exact expression | days |
| `phase_shift_days`, `_ci_lo`, `_ci_hi` | First-to-last 15-year shift | days |
| `rho_magnitude`, `_ci_lo`, `_ci_hi` | Cue reliability, peak magnitude target | — |
| `rho_timing`, `rho_timing_p` | Cue reliability, peak timing target | — |
| `harmonic_R2_pre2007` | Variance explained by the seasonal cycle | proportion |
| `colwell_P_0p5`, `_1p0`, `_2p0` | Colwell predictability, three bin widths | — |
| `mhw_freq_early`, `_late` | Marine heatwave frequency by block | events yr⁻¹ |
| `mhw_dur_early`, `_late` | Marine heatwave mean duration by block | days |
| `lag1_ac_pre2007` | Daily residual lag-1 autocorrelation | — |
| `cp_lag1_ac`, `cp_A1`, `cp_resid_var` | Detected changepoint years | year |
| `empirical_peak_R` | Timing consistency, empirical-peak estimator | — |
| `daylength_range_h` | Annual daylength range (longest minus shortest day) | hours |
| `daylength_roc_max` | Maximum rate of change of daylength, at the equinoxes | min day⁻¹ |
| `daylength_roc_at_peak` | Rate of change of daylength at the site's climatological thermal peak date | min day⁻¹ |
| `solstice_peak_lag_days` | Mean signed lag between thermal peak and local summer solstice | days |
| `solstice_peak_lag_ci_lo`, `_hi` | Bootstrap 95% interval on the mean lag | days |

## Table S3. Pooled estimates, four axes

Random-effects pooled across 81 sites.

| Quantity | Pooled estimate | 95% CI | τ² | I² |
|---|---|---|---|---|
| Mean trend, full record | +0.0222 °C yr⁻¹ | [+0.0208, +0.0237] | 3.13 × 10⁻⁵ | 71.4% |
| Mean trend, 1982–2006 | +0.0185 °C yr⁻¹ | [+0.0154, +0.0215] | 1.29 × 10⁻⁴ | 66.8% |
| Amplitude trend, naive full record | +0.0017 °C yr⁻¹ | [+0.0006, +0.0028] | 1.29 × 10⁻⁵ | 55.0% |
| Amplitude trend, 1982–2006 | +0.0027 °C yr⁻¹ | [+0.0009, +0.0044] | 1.8 × 10⁻⁵ | 29.3% |
| Amplitude trend, step-adjusted (one step) | +0.0024 °C yr⁻¹ | [+0.0011, +0.0036] | 2 × 10⁻⁶ | 6.4% |
| Amplitude trend, step-adjusted (two steps) | +0.0020 °C yr⁻¹ | [+0.0007, +0.0034] | 0 | 0.0% |
| Phase shift, first-to-last 15 yr, full record | +0.86 days | [−0.11, +1.82] | 9.77 | 60.0% |
| Phase shift, 1982–2006 | +0.21 days | [−0.34, +0.75] | 0 | 0.0% |
| Cue reliability (magnitude), region-level RE | +0.222 | [+0.160, +0.283] | 6.5 × 10⁻³ | 64.9% |

The step-adjusted two-step estimate is the recommended amplitude figure (S1.7). Its I² of 0% is not subject to the objection that applies to the 1982–2006 column, because the step-adjusted models use the full record rather than a shortened window.

## Table S4. Mean SST trend by region

| Region | n | Pooled trend (°C yr⁻¹) | 95% CI |
|---|---|---|---|
| Red Sea and Persian Gulf | 8 | 0.0325 | [0.0280, 0.0370] |
| Western Central Pacific | 8 | 0.0269 | [0.0246, 0.0292] |
| Western Atlantic, Caribbean and Brazil | 8 | 0.0257 | [0.0236, 0.0278] |
| Focal subset | 9 | 0.0236 | [0.0212, 0.0260] |
| South Central Pacific and Polynesia | 8 | 0.0233 | [0.0181, 0.0285] |
| Coral Triangle and SE Asia | 8 | 0.0206 | [0.0184, 0.0227] |
| Australia | 8 | 0.0201 | [0.0171, 0.0232] |
| Western Indian Ocean | 8 | 0.0188 | [0.0145, 0.0231] |
| Central Indian Ocean | 8 | 0.0173 | [0.0143, 0.0203] |
| Eastern Atlantic and West Africa | 6 | 0.0082 | [0.0046, 0.0117] |
| Eastern Pacific | 2 | not pooled (n < 3) | — |

Every region with sufficient sites to pool excludes zero. 76 of 81 sites are individually significant after correction for multiple comparisons.

## Table S5. Seasonal amplitude trend by region

Naive full-record estimates.

| Region | n | Pooled trend (°C yr⁻¹) | 95% CI | Excludes zero |
|---|---|---|---|---|
| Red Sea and Persian Gulf | 8 | +0.0080 | [+0.0036, +0.0124] | yes |
| Eastern Atlantic and West Africa | 6 | +0.0068 | [+0.0033, +0.0104] | yes |
| Central Indian Ocean | 8 | +0.0033 | [+0.0002, +0.0063] | yes |
| Western Atlantic, Caribbean and Brazil | 8 | +0.0032 | [+0.0012, +0.0053] | yes |
| Focal subset | 9 | +0.0029 | [−0.0007, +0.0064] | no |
| Australia | 8 | +0.0012 | [−0.0022, +0.0046] | no |
| Western Indian Ocean | 8 | −0.0004 | [−0.0025, +0.0017] | no |
| South Central Pacific and Polynesia | 8 | −0.0011 | [−0.0033, +0.0011] | no |
| Coral Triangle and SE Asia | 8 | −0.0024 | [−0.0050, +0.0001] | no |
| Western Central Pacific | 8 | −0.0029 | [−0.0054, −0.0004] | yes (negative) |
| Eastern Pacific | 2 | not pooled (n < 3) | — | — |

Seven of 81 sites are individually significant after correction. The globally pooled positive value is a net of opposing regional trends.

## Table S6. Seasonal phase shift by region

Difference in circular mean phase between the first and last 15 non-overlapping years.

| Region | n | Pooled shift (days) | 95% CI | Excludes zero |
|---|---|---|---|---|
| Western Atlantic, Caribbean and Brazil | 8 | +6.07 | [+3.02, +9.12] | yes (later) |
| Coral Triangle and SE Asia | 8 | +4.31 | [+0.87, +7.76] | yes (later) |
| South Central Pacific and Polynesia | 8 | +4.25 | [−0.42, +8.91] | no |
| Eastern Atlantic and West Africa | 6 | +3.71 | [+1.11, +6.31] | yes (later) |
| Western Central Pacific | 8 | −0.22 | [−2.78, +2.33] | no |
| Australia | 8 | −0.27 | [−2.57, +2.04] | no |
| Focal subset | 9 | −0.31 | [−2.21, +1.59] | no |
| Central Indian Ocean | 8 | −0.78 | [−6.10, +4.53] | no |
| Red Sea and Persian Gulf | 8 | −1.63 | [−3.29, +0.03] | no |
| Western Indian Ocean | 8 | −2.88 | [−4.56, −1.20] | yes (earlier) |
| Eastern Pacific | 2 | not pooled (n < 3) | — | — |

No individual site is significant after correction; the regional effects emerge only under pooling.

## Table S7. Interannual timing precision by region

Circular standard deviation of the day of year of the thermal maximum.

| Region | n | Median (days) | IQR | Range |
|---|---|---|---|---|
| Red Sea and Persian Gulf | 8 | 5.65 | [4.70, 6.04] | 3.07–25.61 |
| Eastern Atlantic and West Africa | 6 | 6.02 | [5.82, 8.16] | 5.50–9.63 |
| Australia | 8 | 6.30 | [5.47, 7.59] | 4.96–11.00 |
| Western Indian Ocean | 8 | 6.70 | [6.02, 7.19] | 5.77–13.44 |
| Western Atlantic, Caribbean and Brazil | 8 | 9.87 | [8.53, 11.55] | 6.33–12.25 |
| Western Central Pacific | 8 | 10.06 | [9.64, 11.65] | 8.05–37.93 |
| Coral Triangle and SE Asia | 8 | 13.89 | [10.79, 18.67] | 8.12–33.36 |
| Eastern Pacific | 2 | 14.92 | [10.00, 19.84] | 5.08–24.76 |
| Central Indian Ocean | 8 | 16.76 | [9.51, 23.03] | 5.64–32.04 |
| South Central Pacific and Polynesia | 8 | 17.50 | [11.08, 23.46] | 9.96–57.19 |
| **All 81 sites** | 81 | **8.85** | **[5.87, 13.44]** | **3.07–57.19** |

Three sites require the exact rather than the approximate expression for circular SD; two have R < 0.8, at which point the interpretation as a standard deviation in days becomes unstable.

## Table S8. Timing precision by seasonal amplitude

**By the fitted breakpoint** (A₁ = 1.126 °C, 95% CI [0.974, 1.233]):

| Amplitude class | n | Median (days) | IQR | Range |
|---|---|---|---|---|
| Below breakpoint (A₁ < 1.13 °C) | 25 | 19.36 | [14.05, 28.24] | 10.14–57.19 |
| Above breakpoint (A₁ ≥ 1.13 °C) | 56 | 6.70 | [5.62, 8.97] | 3.07–11.44 |

The two regimes do not overlap in range.

**By amplitude quartile:**

| Quartile | n | Median (days) | IQR | Range |
|---|---|---|---|---|
| Q1 (A₁ < 0.99 °C) | 21 | 21.48 | [15.84, 29.68] | 10.26–57.19 |
| Q2 (0.99–1.72 °C) | 20 | 9.99 | [9.17, 11.35] | 5.87–13.73 |
| Q3 (1.72–2.66 °C) | 20 | 7.08 | [6.11, 8.25] | 5.50–9.99 |
| Q4 (A₁ ≥ 2.66 °C) | 20 | 5.32 | [5.05, 5.74] | 3.07–6.82 |

**Fitted hinge model:**

| Predictor | Breakpoint (°C) | 95% CI | Slope below | Slope above | r(SD, \|latitude\|) |
|---|---|---|---|---|---|
| A₁ | 1.126 | [0.974, 1.233] | −39.66 days °C⁻¹ | −1.33 days °C⁻¹ | −0.593 |

A hinge model fitted to photoperiod amplitude against thermal amplitude, for comparison, returns a breakpoint of 3.07 °C (95% CI [0.88, 3.32]) with an interval spanning most of the fitted range, indicating no comparable threshold (Table S20a). The abrupt transition in timing precision is therefore specific to the thermal cycle and is not a general property of seasonal signals at low latitude.


## Table S9. Cue reliability by region

Correlation between the early-season cue and peak magnitude, full record.

| Region | n | Mean ρ | 95% CI | r² | Sites individually significant |
|---|---|---|---|---|---|
| Western Atlantic, Caribbean and Brazil | 8 | 0.401 | [0.292, 0.509] | 16.0% | 6/8 |
| Eastern Pacific | 2 | 0.362 | [0.138, 0.585] | 13.1% | 1/2 |
| Coral Triangle and SE Asia | 8 | 0.338 | [0.233, 0.443] | 11.4% | 6/8 |
| Red Sea and Persian Gulf | 8 | 0.236 | [0.131, 0.341] | 5.6% | 1/8 |
| South Central Pacific and Polynesia | 8 | 0.216 | [−0.012, 0.444] | 4.7% | 4/8 |
| Focal subset | 9 | 0.204 | [0.122, 0.286] | 4.2% | 2/9 |
| Australia | 8 | 0.196 | [0.109, 0.284] | 3.9% | 3/8 |
| Central Indian Ocean | 8 | 0.150 | [−0.008, 0.309] | 2.3% | 2/8 |
| Eastern Atlantic and West Africa | 6 | 0.148 | [0.045, 0.252] | 2.2% | 1/6 |
| Western Central Pacific | 8 | 0.139 | [−0.047, 0.324] | 1.9% | 3/8 |
| Western Indian Ocean | 8 | 0.069 | [−0.038, 0.177] | 0.5% | 1/8 |

Thirty of 81 sites have an individual interval excluding zero. Because sites are spatially autocorrelated (Moran's I = 0.313, p = 0.001), this proportion is reported descriptively and is not converted into a formal comparison against a chance baseline.

## Table S10. Cue reliability: sensitivity to pooling method

| Method | Pooled ρ | 95% CI | r² |
|---|---|---|---|
| Normal approximation across 81 sites | 0.215 | [0.170, 0.260] | 4.6% |
| Cluster bootstrap, 11 regional clusters | 0.216 | [0.162, 0.274] | 4.6% |
| Region-level random effects (DerSimonian–Laird) | 0.222 | [0.160, 0.283] | 4.9% |

The region-level random-effects interval is reported in the main text. The normal approximation treats sites as independent and yields an interval that is too narrow given the confirmed spatial dependence.

## Table S11. What predicts cue reliability

**Site-level regressions**, region-cluster-robust standard errors, n = 81:

| Model | Coefficient | 95% CI | p | R² |
|---|---|---|---|---|
| ρ ~ seasonal-cycle R² (1982–2006) | −0.377 | [−0.614, −0.139] | 0.002 | 0.132 |
| ρ ~ interannual peak SD / A₁ | +0.346 | [+0.107, +0.585] | 0.005 | 0.121 |
| ρ ~ amplitude (A₁) | −0.022 | [−0.083, +0.039] | 0.479 | 0.019 |
| ρ ~ timing precision (phase R) | −1.022 | [−1.665, −0.379] | 0.002 | 0.084 |

**Mediation**, showing that the variance partition accounts for the apparent timing-precision effect:

| Model | phase R coefficient | 95% CI | Partition coefficient | 95% CI |
|---|---|---|---|---|
| ρ ~ phase R alone | −1.022 | [−1.665, −0.379] | — | — |
| ρ ~ phase R + seasonal-cycle R² | −0.028 | [−1.324, +1.268] | −0.370 | [−0.716, −0.025] |

Variance inflation factors for the joint model are 2.62, confirming the predictors are separable.

**Region-level meta-regression**, moderator effect on between-region heterogeneity (null τ² = 0.00652, I² = 64.9%):

| Moderator | Slope | 95% CI | Heterogeneity explained |
|---|---|---|---|
| Mean seasonal-cycle R² | −0.251 | [−0.716, +0.214] | +12.2% |
| Mean amplitude (A₁) | −0.016 | [−0.088, +0.055] | −9.2% |
| Mean timing precision (phase R) | −0.920 | [−3.788, +1.948] | −2.3% |

Amplitude and timing precision explain none of the between-region heterogeneity in cue reliability. The variance partition explains a modest fraction, though its interval crosses zero at n = 11 regions.

**Climate-mode coupling**, tested as a candidate mechanism:

| Predictor of ρ | Coefficient | 95% CI | p |
|---|---|---|---|
| Strongest of four index correlations | +0.238 | [−0.323, +0.799] | 0.406 |
| ONI alone | +0.121 | [−0.378, +0.619] | 0.636 |
| Dipole Mode Index alone | −0.399 | [−0.776, −0.022] | 0.038 |
| AMO alone | +0.103 | [−0.393, +0.598] | 0.685 |
| PDO alone | +0.073 | [−0.420, +0.565] | 0.772 |

The proposed mechanism is not supported: the composite predictor's interval crosses zero, and the one individually significant index has the opposite sign to the prediction. The regional prediction also fails: the lowest-ρ region has the second-highest mean climate-mode coupling.

## Table S12. Latitude and amplitude relationships

Site-level regressions, n = 81, with spatial diagnostics.

| Relationship | Slope | 95% CI | Cluster-robust p | Moran's I on residuals | p |
|---|---|---|---|---|---|
| Timing precision (phase R) ~ \|latitude\| | 0.0042 | [0.0026, 0.0058] | 0.005 | 0.053 | 0.201 |
| Amplitude (A₁) ~ \|latitude\| | 0.1349 | [0.1070, 0.1627] | < 0.0001 | 0.271 | 0.001 |
| Timing precision ~ amplitude | 0.0207 | [0.0116, 0.0298] | 0.006 | 0.049 | 0.234 |

All three relationships survive region-clustered inference. The amplitude–latitude residuals show significant spatial structure beyond latitude, so the cluster-robust result is the one to rely on for that relationship.

## Table S13. Amplitude step model

Per-site fitted step magnitude at 2007, from the trend-plus-step model (S1.7).

| Statistic | Value |
|---|---|
| Mean step | −0.030 °C |
| Median step | −0.030 °C |
| SD across sites | 0.180 °C |
| Sites with negative step | 49/81 (60.5%) |
| Sites individually significant | 1/81 |

**By region:**

| Region | Mean step (°C) | Negative / total |
|---|---|---|
| Central Indian Ocean | +0.234 | 0/8 |
| Eastern Atlantic and West Africa | +0.084 | 1/6 |
| Coral Triangle and SE Asia | +0.034 | 3/8 |
| Australia | +0.008 | 4/8 |
| South Central Pacific and Polynesia | −0.063 | 6/8 |
| Eastern Pacific | −0.069 | 1/2 |
| Focal subset | −0.071 | 6/9 |
| Western Indian Ocean | −0.088 | 7/8 |
| Western Atlantic, Caribbean and Brazil | −0.092 | 7/8 |
| Red Sea and Persian Gulf | −0.130 | 8/8 |
| Western Central Pacific | −0.177 | 6/8 |

**Model comparison:**

| Criterion | Trend only | Trend + 2007 step | Trend + two steps |
|---|---|---|---|
| BIC | 76/81 | 5/81 | 0/81 |
| AIC | 62/81 | 17/81 | 2/81 |

The step is negative on average but is not uniform across regions, is individually detectable at one site, and is not preferred by model comparison at most sites. It is therefore treated as a probable but not established partial artefact, and the step-adjusted slope is reported as the best estimate rather than as a correction for a demonstrated discontinuity.

## Table S14. Artefact screen: changepoint clustering

Proportion of sites whose single detected changepoint falls in the year indicated.

| Quantity | At 2007 | At 2022 | Combined | Median changepoint |
|---|---|---|---|---|
| Daily residual lag-1 autocorrelation | 32/81 (39.5%) | 26/81 (32.1%) | 58/81 (71.6%) | 2007 |
| Annual residual variance | 47/81 (58.0%) | 3/81 (3.7%) | 50/81 (61.7%) | 2007 |
| Seasonal amplitude (A₁) | 15/81 (18.5%) | 11/81 (13.6%) | 26/81 (32.1%) | 2002 |
| Annual mean, phase, Colwell P, cue reliability | at or near chance | at or near chance | — | scattered |

Daily residual autocorrelation and residual variance are functions of the same residual series and are not independent confirmations of each other. Amplitude is elevated above chance but far below the contaminated quantities and shows no dominant single-year peak.

## Table S15. A spurious relationship generated by the processing discontinuity

Correlation between annual mean SST and daily residual persistence, computed within sites across years.

| Period | n sites | Mean r | 95% CI | Fraction positive |
|---|---|---|---|---|
| 1982–2006 (artefact-free) | 81 | −0.004 | [−0.065, +0.058] | 44.4% |
| Full record 1982–2025 | 81 | +0.398 | [+0.359, +0.434] | 97.5% |

An apparent coupling between the thermal mean and the variance structure of a reef's thermal environment, present at 97% of sites over the full record, is absent in the artefact-free period. Because both quantities shift at the same dates, a shared discontinuity manufactures a relationship between them. The between-site relationship is separate and real: across sites, warmer sites have less persistent residuals (r = −0.65).

## Table S16. Marine heatwave metrics

Detection follows Hobday et al. (2016): events of at least five days above the seasonally varying 90th percentile, with events separated by two days or fewer merged. The baseline is a fixed 1982–2011 climatology.

**Pooled across 81 sites, mean event duration, first to last block:**

| Baseline | Pooled effect (days) | 95% CI | I² |
|---|---|---|---|
| Fixed 1982–2011 climatology (Hobday convention) | +8.78 | [+7.83, +9.73] | 44.0% |
| Trend-following baseline (diagnostic) | +1.50 | [+0.98, +2.02] | 19.7% |

**By region, both baselines:**

| Region | Fixed baseline (days) | 95% CI | Trend-following (days) | 95% CI |
|---|---|---|---|---|
| Western Atlantic, Caribbean and Brazil | +20.81 | [+12.34, +29.27] | +3.84 | [+1.80, +5.88] |
| Eastern Atlantic and West Africa | +13.24 | [+7.24, +19.24] | +7.03 | [+3.52, +10.53] |
| South Central Pacific and Polynesia | +11.55 | [+8.98, +14.11] | +1.25 | [−0.26, +2.77] |
| Western Central Pacific | +11.18 | [+9.40, +12.97] | +1.51 | [+0.57, +2.45] |
| Western Indian Ocean | +9.02 | [+6.19, +11.84] | +1.59 | [+0.12, +3.07] |
| Australia | +8.11 | [+5.61, +10.62] | +2.67 | [+0.96, +4.39] |
| Red Sea and Persian Gulf | +8.01 | [+4.36, +11.66] | +2.32 | [−0.65, +5.28] |
| Focal subset | +7.95 | [+5.92, +9.99] | +0.77 | [−0.45, +1.98] |
| Coral Triangle and SE Asia | +7.19 | [+5.15, +9.23] | +0.67 | [−0.47, +1.82] |
| Central Indian Ocean | +5.48 | [+3.75, +7.21] | +0.79 | [−0.56, +2.13] |
| Eastern Pacific | +6.00 | [−1.53, +13.53] | −0.90 | [−8.63, +6.83] |

Approximately 83% of the fixed-baseline effect, and more than half of the between-region heterogeneity, disappears under a trend-following baseline. The regional differences are therefore substantially attributable to differences in local warming rate relative to a stationary threshold rather than to region-specific changes in the character of thermal extremes, and the regional comparison is not interpreted as an ecological pattern. Changepoint screening of the marine heatwave series found no clustering at 2007 or 2022 (at most 3/81 sites for any metric), so these quantities are not affected by the processing discontinuity.

## Table S17. Warming rate in context

| Source | Estimate | Period | Domain |
|---|---|---|---|
| This study, pooled across 81 reef sites | 0.222 °C decade⁻¹ | 1982–2025 | reef pixels, global |
| Bove et al. (2022) | 0.16–0.20 °C decade⁻¹ | 1981–2020 | Caribbean reefs, basin-wide |
| Bove et al. (2022), Southern and Eastern Caribbean | 0.26 °C decade⁻¹ | since 1981/1984 | reef ecoregions |
| Published multi-dataset comparison | 0.108–0.184 °C decade⁻¹ | 1982–2024 | 60°S–60°N, global ocean |
| Published satellite SST climatology | 0.09 °C decade⁻¹ mean | 1981–2018 | global ocean |

The estimate here sits above global open-ocean values and within the range reported for reef and coastal sites specifically, consistent with the documented tendency for shallow coastal waters to warm faster than the open ocean. Per-site slopes range from 0.0002 to 0.0465 °C yr⁻¹, with the pooled value close to both the median (0.0225) and the unweighted mean (0.0220).

## Table S18. Representativeness of the focal subset

Percentile position of the nine focal sites within the 81-site distribution.

| Quantity | Median percentile of focal sites | Interpretation |
|---|---|---|
| Mean SST | 32.7 | approximately typical |
| Seasonal amplitude | 78.4 | skewed high |
| Timing precision (phase R) | 80.9 | skewed high |
| Circular SD of timing | 19.1 | skewed low (more precise than typical) |
| Cue reliability | 51.2 | representative |
| Cue reliability (timing target) | 38.9 | approximately typical |
| Colwell P, early block | 74.7 | skewed high |
| Colwell P, late block | 52.5 | representative |
| Marine heatwave frequency | 52.5–56.8 | representative |
| Marine heatwave duration | 53.7–57.4 | representative |

Eight of nine focal sites fall in the more precisely timed half of the global phase distribution, and three of nine show significant amplitude trends against 8.6% of sites globally. Absolute values of amplitude, timing precision, and rates of amplitude change drawn from the focal subset should not be generalized. Cue reliability is the exception.

## Table S19. Timing precision: cross-estimator agreement

Two independent estimators of interannual timing consistency: the resultant length of the harmonic-fit phase (the primary measure, Tables S7–S8), and the resultant length of the lag between the empirical rolling-maximum peak and a fixed reference date.

| Quantity | Median | IQR | Range |
|---|---|---|---|
| Empirical-peak consistency, all 81 sites | 0.906 | [0.823, 0.949] | [0.280, 0.990] |
| Below the amplitude breakpoint | 0.80 | — | — |
| Above the amplitude breakpoint | 0.92 | — | — |

| Correlation | r | 95% CI |
|---|---|---|
| With harmonic-fit phase R | +0.65 | [+0.50, +0.76] |
| With circular SD of timing (days) | −0.68 | [−0.78, −0.54] |

The two estimators share no smoothing assumptions and agree substantially, and both show the same amplitude dependence, monotonic across amplitude quartiles. The empirical-peak estimator shows a gradual rise rather than the sharp hinge seen in the harmonic-fit measure, so the sharpness of the breakpoint is partly a property of the harmonic estimator while the underlying amplitude dependence is not. Eighteen of 81 sites fall below the stability threshold on the empirical-peak measure against two of 81 on the harmonic measure, as expected for an estimator based on an unsmoothed peak, and the harmonic-fit measure is therefore used as primary throughout.

## Table S20. Photoperiod as a seasonal cue

Photoperiod has been proposed as a stable entrainment anchor in a destabilizing thermal environment, on the reasoning that daylength is astronomically fixed while thermal cycles are not. Two results bear on that proposal, and neither supports it.

### (a) Photoperiod signal strength does not compensate where the thermal cue is weak

Photoperiod amplitude covaries strongly with thermal amplitude across reefs (r = 0.74, 95% CI [0.63, 0.83]), because both are driven by latitude. Reefs with weak seasonal thermal structure therefore also have weak photoperiod structure: below the thermal amplitude breakpoint of 1.13 °C, median annual daylength range is 1.3 hours, against 2.2 hours above it.

**By amplitude class:**

| Amplitude class | n | Median daylength range (h) | IQR | range | Median max rate of change (min day⁻¹) | IQR | range |
|---|---|---|---|---|---|---|---|
| below breakpoint | 25 | 1.305 | [0.858, 1.671] | [0.188, 2.017] | 0.624 | [0.409, 0.796] | [0.092, 0.959] |
| above breakpoint | 56 | 2.177 | [1.812, 2.804] | [0.333, 4.091] | 1.035 | [0.865, 1.330] | [0.162, 1.933] |

**By amplitude quartile**:

| Quartile | n | Median daylength range (h) | IQR | range | Median max rate of change (min day⁻¹) | IQR | range |
|---|---|---|---|---|---|---|---|
| Q1 (A1<0.99) | 21 | 1.215 h | [0.858, 1.640] | [0.188, 2.017] | 0.579 min/day | [0.409, 0.781] | [0.092, 0.959] |
| Q2 (0.99-1.72) | 19 | 1.640 h | [1.170, 2.065] | [0.217, 2.242] | 0.781 min/day | [0.559, 0.985] | [0.105, 1.069] |
| Q3 (1.72-2.66) | 20 | 2.080 h | [1.820, 2.226] | [0.829, 2.988] | 0.992 min/day | [0.869, 1.061] | [0.398, 1.420] |
| Q4 (A1>=2.66) | 21 | 2.988 h | [2.709, 3.350] | [1.858, 4.091] | 1.416 min/day | [1.289, 1.586] | [0.887, 1.933] |

**By region:**

| Region | n | Median daylength range (h) | IQR | range |
|---|---|---|---|---|
| Coral_Triangle_SE_Asia | 8 | 0.845 | [0.297, 1.208] | [0.188, 1.640] |
| Western_Indian_Ocean | 8 | 1.441 | [0.770, 1.626] | [0.217, 2.988] |
| Central_Indian_Ocean | 8 | 1.548 | [1.298, 1.880] | [1.095, 2.778] |
| South_Central_Pacific_Polynesia | 8 | 1.687 | [1.238, 2.041] | [0.362, 2.242] |
| Western_Central_Pacific | 8 | 1.718 | [1.355, 2.080] | [0.653, 2.275] |
| Western_Atlantic_Caribbean_Brazil | 8 | 2.002 | [1.641, 2.218] | [1.426, 2.540] |
| Eastern_Pacific | 2 | 2.048 | [1.632, 2.465] | [1.215, 2.882] |
| Eastern_Atlantic_West_Africa | 6 | 2.049 | [2.017, 2.105] | [1.858, 2.473] |
| Australia | 8 | 2.161 | [1.790, 2.556] | [1.245, 2.709] |
| ORIGINAL_9 | 9 | 2.882 | [2.209, 3.130] | [0.858, 4.091] |
| Red_Sea_Persian_Gulf | 8 | 3.331 | [3.122, 3.397] | [2.017, 3.614] |

Unlike timing precision, which changes abruptly at a threshold in thermal amplitude (Table S8), photoperiod amplitude scales smoothly with latitude. A hinge model fitted to photoperiod amplitude against thermal amplitude for comparability returns a breakpoint of 3.07 °C (95% CI [0.88, 3.32]), far from the thermal breakpoint of 1.13 °C [0.97, 1.23] and with an interval spanning most of the fitted range. This is a negative result rather than a second threshold: the model has been forced to hinge a relationship that is not hinged. The threshold structure in timing precision is therefore a property of the thermal cycle specifically, not a general feature of seasonal signals at low latitude, and the two cue channels have different functional forms as well as different magnitudes.

### (b) Solstice-to-peak lag

| region | n | mean | median | SD |
|---|---|---|---|---|
| Central_Indian_Ocean | 8 | −6.00 | −15.72 | 33.42 |
| Eastern_Pacific | 2 | +30.80 | +30.80 | 62.48 |
| Coral_Triangle_SE_Asia | 8 | +33.62 | +34.74 | 15.37 |
| Western_Indian_Ocean | 8 | +43.55 | +64.90 | 58.50 |
| Australia | 8 | +45.03 | +45.13 | 7.22 |
| Red_Sea_Persian_Gulf | 8 | +48.65 | +62.39 | 42.12 |
| ORIGINAL_9 | 9 | +55.85 | +53.89 | 8.59 |
| Western_Central_Pacific | 8 | +61.60 | +63.48 | 4.65 |
| Western_Atlantic_Caribbean_Brazil | 8 | +72.21 | +75.60 | 14.60 |
| South_Central_Pacific_Polynesia | 8 | +84.42 | +72.33 | 39.18 |
| Eastern_Atlantic_West_Africa | 6 | +88.68 | +91.13 | 5.80 |

Per-site values are given in `site_metrics.csv`.

### (c) Quantities that are reparameterizations, not new results

Because the solstice does not move, three photoperiod-referenced quantities are mathematically identical to results already reported. They were computed independently and agreed to within approximately 10⁻¹³ days, which verifies the new code rather than adding evidence.

| Photoperiod-referenced quantity | Identical to | Reported in |
|---|---|---|
| Interannual SD of solstice-to-peak lag | Circular SD of thermal peak timing | Table S7 |
| Change in mean solstice-to-peak lag over the record | Phase shift, first to last 15 years | Table S6 |
| Daylength at the thermal peak | Non-linear rescaling of peak day of year | Table S2 |

This identity carries a substantive implication that requires no additional statistic. Since one of the two cycles is astronomically fixed, every regional shift in thermal phase is, by construction, an equal change in the separation between the thermal maximum and the photoperiod reference against which entrained programs could be calibrated. The Western Atlantic and Caribbean thermal maximum has moved 6.07 days (95% CI [3.02, 9.12]) further from the solstice; the Western Indian Ocean maximum has moved 2.88 days ([1.20, 4.56]) closer. In the four regions where a directional phase shift is detectable (Table S6), the thermal and photoperiod cycles have measurably decoupled by that amount.

### (d) Detectability of the photoperiod signal is unknown

Whether a coral can resolve a given annual daylength range is an empirical question this analysis cannot answer, and the literature does not answer it either. Four searches across distinct framings — coral and cnidarian reproductive cues, critical-photoperiod thresholds in marine invertebrates generally, coral photoreceptor and clock-gene biology, and the best-characterized marine invertebrate photoperiod system — returned consistent evidence that daylength is a plausible seasonal cue in corals, including confirmed cryptochromes and opsins, and a quantified blue-light **intensity** threshold of approximately 1.2 × 10¹⁵ quanta m⁻² s⁻¹ corresponding to moonlight levels. No published value was found for the minimum daylength **difference** or **rate of change** detectable by any cnidarian.

Two consequences follow. The comparison in (a) is a relative statement between reefs, not an absolute statement about whether any reef's photoperiod signal is usable; a 1.3 hour annual range cannot be described as insufficient, and neither can 2.2 hours be described as sufficient. And the framework's assumption of photoperiodic entrainment (Section 4.4) rests on a sensitivity parameter that has never been measured in this phylum, which is an empirical priority in its own right (Section 6).

### Verdict

Photoperiod does not function as a compensating anchor. It weakens alongside the thermal cue rather than substituting for it, so reefs with poor thermal timing information are cue-poor in both channels simultaneously. And because the solstice is fixed while thermal phase has shifted, the stability of the photoperiod cue is the mechanism of decoupling rather than a buffer against it. The claim that photoperiod provides a stable anchor in a destabilizing thermal environment is not supported and is removed from the manuscript rather than qualified.

---

# Supplementary Figures

**Figure S1. Interannual timing precision against seasonal amplitude.** Circular standard deviation of the day of year of the thermal maximum plotted against annual harmonic amplitude, all 81 sites, coloured by region, with the fitted continuous piecewise-linear model and the 95% confidence band on the breakpoint. 

**Figure S2. Global distribution of timing precision.** All 81 sites plotted by longitude and latitude, coloured by circular standard deviation of thermal peak timing. A band of imprecisely timed sites is visible near the equator, particularly in the Coral Triangle and Western Pacific, against a background of tightly timed sites at higher latitudes. 

**Figure S3. Forest plots of pooled trends.** Three panels, one per axis (annual mean, seasonal amplitude, phase shift), one row per site grouped by region, with the pooled estimate and its confidence band. 

**Figure S4. Cue reliability against the variance partition.** Two panels: cue reliability against the seasonal-cycle R², and against the ratio of interannual peak-magnitude variability to amplitude, both for the 1982–2006 period, all 81 sites coloured by region. Both show the predicted direction with substantial within-region scatter. 

**Figure S5. Changepoint year distributions.** Three histogram panels for daily residual autocorrelation, annual residual variance, and seasonal amplitude. The first two show a dominant spike in the 2005–2010 bin, with a clear second peak at 2020–2025 for residual autocorrelation. Amplitude shows no dominant peak, with its largest bin at 1985–1990.

**Figure S6. Geographic distribution of changepoint years.** Two world maps, sites coloured by detected changepoint year for daily residual autocorrelation and for seasonal amplitude. The first is dominated by two colours corresponding to 2007 and 2022 in every basin; the second shows an even mix across the record. 

**Figure S7. Marine heatwave duration, fixed against trend-following baseline.** Scatter of per-site fixed-baseline against trend-following-baseline duration change, all 81 sites, with a one-to-one reference line. 

**Figure S8. Marine heatwave duration forest plot.** One row per site grouped by region, with regional and global pooled estimates.

**Figure S9. Residual power spectrum.** Binned periodogram, log-log, for three representative sites, showing power rising from the 2-year toward the 100-day timescale and falling from 100 days toward 10 days. 

**Figure S10. Latitude relationships.** Three panels: timing precision against absolute latitude, amplitude against absolute latitude, and timing precision against amplitude, all coloured by region.

**Figure S11. Amplitude step magnitude by region.** One row per region sorted by mean fitted step at 2007, individual site values shown, with regional means and a zero reference line.

**Figure S12. Photoperiod signal strength against seasonal thermal amplitude.** Annual daylength range plotted against annual thermal harmonic amplitude, all 81 sites, coloured by region, with the thermal timing-precision breakpoint at 1.13 °C marked as a vertical reference. The two quantities covary (r = 0.74), and sites below the thermal breakpoint occupy the low end of the photoperiod range rather than compensating for weak thermal seasonality. 

**Figure S13. Solstice-to-peak lag against absolute latitude.** Mean signed lag between the thermal maximum and the local summer solstice, all 81 sites, coloured by region, with bootstrap intervals.

---
