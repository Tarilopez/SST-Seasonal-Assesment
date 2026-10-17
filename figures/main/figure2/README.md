# Coral reef thermal seasonality — Figure 2 (R)

R port of Figure 2's statistical modeling and figure-building pipeline: a
6-panel figure summarizing regional patterns in seasonal SST trends, phase
shift, timing precision, and cue reliability across 81 coral reef sites.

## Scope

This repository performs, in R:

- Regional random-effects pooling (DerSimonian-Laird) of four per-site
  metrics (mean/amplitude seasonal trends, phase shift, cue reliability).
- A validated breakpoint (piecewise-linear threshold) model relating
  timing precision to seasonal amplitude.
- The derived comparison between regional phase-shift magnitude and
  regional timing-precision envelope (Panel E).
- Assembly of the full 6-panel `ggplot2`/`patchwork` figure.

It does **not** re-derive the underlying per-site metrics from raw
sea-surface-temperature data. Those come from harmonic regression and
circular-statistics methods already implemented and validated in this
project's Python pipeline (`extension/` in the parent repository).
Reimplementing harmonic fitting a second time in R would duplicate months
of already-validated work and risk silent numerical drift between two
independent implementations. Instead, the per-site outputs of that
pipeline are the documented starting point here (see `data/` below); this
repo picks up from there and does everything downstream — pooling,
breakpoint estimation, and figure construction — natively in R.

Every routine that *is* new here is a direct, tested port of the
corresponding validated Python function, not a reimplementation from
scratch, and is checked against an already-published Python number before
being used (see `analysis.Rmd`, "Step 1").

## Structure

```
r_figure2/
├── analysis.Rmd          # Complete narrated analysis: data -> pooling ->
│                          # breakpoint (with synthetic validation) ->
│                          # Panel E derivation -> figure. Knit this.
├── R/
│   ├── pooling.R          # dersimonian_laird(), ci_to_var(), pool_by_region()
│   ├── breakpoint.R       # grid_search_breakpoint(), bootstrap_breakpoint_ci(),
│   │                      # validate_breakpoint_method()
│   └── figure2.R          # Standalone script version of the same pipeline
│                          # (no narration) — run with `Rscript R/figure2.R`
├── data/
│   ├── site_trends_M_A1.csv          # per-site M and A1 trend + 95% CI
│   ├── site_phase_shift.csv          # per-site phase shift (first vs last 15yr) + CI
│   ├── site_phase_sd_A1.csv          # per-site phase circular SD, mean A1, R
│   ├── site_rho.csv                  # per-site cue-reliability rho + CI
│   └── inset_climatology/            # raw daily SST, 2 representative sites
│       ├── South_Central_Pacific_Polynesia_03_daily.csv  # below breakpoint
│       └── Western_Indian_Ocean_01_daily.csv              # above breakpoint
└── figures/               # ggsave() output: figure2.pdf, figure2_600dpi.png
```

## Data provenance

| File | Source table (upstream Python pipeline) | Filter |
|---|---|---|
| `site_trends_M_A1.csv` | `extension/axes81/tables/axes81_1b_trends.csv` | `period=="full"`, `axis` in `{M, A1}` |
| `site_phase_shift.csv` | `extension/axes81/tables/axes81_1b_phase_block_shift.csv` | `period=="full"` |
| `site_phase_sd_A1.csv` | `extension/axes81/tables/axes81_2d_phase_sd_distribution.csv` | — |
| `site_rho.csv` | `extension/tables/taskE3_site_metrics.csv` | — |
| `inset_climatology/*.csv` | `extension/data/oisst_site_daily_full/*.csv` | 2 of 81 sites only |

Full column definitions are in `analysis.Rmd`'s Data section.

## Reproducing

Requires R (developed and tested on R 4.5.2) with: `ggplot2`, `dplyr`,
`tidyr`, `patchwork`, `ggrepel`, `scales`, `readr`, `knitr`, `rmarkdown`.
Knitting `analysis.Rmd` also requires [pandoc](https://pandoc.org/) on the
system `PATH` (RStudio bundles its own copy automatically; from a plain R
session, install pandoc separately, e.g. `brew install pandoc` on macOS, or
point `rmarkdown::render()` at one via the `RSTUDIO_PANDOC` environment
variable). `R/figure2.R` alone has no pandoc dependency.

Run everything from the `r_figure2/` directory (working directory = repo
root, all paths in the code are relative to it):

```bash
# Narrated notebook (recommended) — produces analysis.html and figures/
Rscript -e 'rmarkdown::render("analysis.Rmd")'

# Or, the equivalent standalone script with no narration
Rscript R/figure2.R
```

Both entry points independently validate the breakpoint estimator against
synthetic data with a known answer before fitting it to real data, and the
pooled M-trend result is checked against the published Python value
(`0.02222 [0.02075, 0.02369] degC/yr`) before anything downstream is built
on it — if either check fails, the script stops rather than silently
producing a figure from an unvalidated estimator.

## Notes on cross-language reproduction

- The deterministic parts of the analysis (DerSimonian-Laird pooling,
  grid-search breakpoint point estimates) match the Python pipeline's
  published numbers almost exactly.
- Bootstrap confidence intervals (the breakpoint CI) will be close to, but
  not bit-identical to, the Python originals: R's `sample.int()` and
  numpy's `default_rng` are different RNG algorithms, so nominally
  matching seeds do not produce identical resamples across languages.
