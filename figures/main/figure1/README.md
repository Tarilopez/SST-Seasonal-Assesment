# Coral reef thermal seasonality — Figure 1 (conceptual, R)

Conceptual figure defining the four axes of seasonal thermal structure
(mean, amplitude, phase, cue reliability) and where each acts
mechanistically. Precedes the empirical Figure 2 (`../figure2/`) and is
built to read as a pair with it: same palette, font, line weights, and
panel-letter convention.

## Scope

Panels A and B are **schematic** — idealized annual sinusoids with
deliberately exaggerated changes. The real observed changes are far too
small to see at annual-cycle scale (the largest regional phase shift
measured, 6.07 days, is 1.7% of a 365-day axis), so every schematic
sub-panel in A carries the true observed magnitude range as a caption,
checked against Figure 2's own Supplementary Tables (S4-S6, S9-S10)
rather than asserted.

Panel C uses **real site climatology data** — the same two sites as
Figure 2 panel D's inset — because it contrasts two *reefs* rather than
two *periods*, and that contrast (amplitude 0.85 vs. 2.61 degC) is large
enough to show directly without exaggeration.

Full panel-by-panel rationale, what was checked against what, and the
two build rounds (round 1 draft, round 2 finalization — resolving the
8pt-minimum-font and true-final-size items round 1 flagged) are in the
working repo's `extension/figure1/BUILD_NOTES.md`, not duplicated here.

## Structure

```
figure1/
├── R/
│   └── figure1.R          # Standalone script — run with `Rscript R/figure1.R`
├── data/
│   ├── South_Central_Pacific_Polynesia_03_daily.csv   # low-amplitude site, raw daily SST
│   ├── Western_Indian_Ocean_01_daily.csv                # high-amplitude site, raw daily SST
│   └── site_phase_sd_A1.csv                             # per-site A1, phase circular SD, phase R (81 sites; only 2 used)
├── caption.md              # Full figure caption
└── figures/                # ggsave() output: figure1.pdf, figure1_600dpi.png
```

`data/` here is identical to (copied from) `../figure2/data/` — both
figures use the same two representative sites, so the daily-SST extracts
and phase-summary table are shared source data, not independently
re-derived.

## Reproducing

Requires R with: `ggplot2`, `dplyr`, `tidyr`, `patchwork`, `scales`. Run
from this directory:

```bash
Rscript R/figure1.R
```

Produces `figures/figure1.pdf` (vector) and `figures/figure1_600dpi.png`
at 169mm width (GCB's confirmed double-column cap, matching Figure 2),
600dpi, with every in-panel annotation at 8pt or larger — no exceptions
(see BUILD_NOTES.md's round 2 for the collision-by-collision record of
what that took: several labels were shortened or repositioned rather
than shrunk to fit, and one panel's label moved into the figure caption
because no in-plot position was collision-free at 8pt).

## Panel C's peak-day derivation differs slightly from the working-repo version

The working-repo build (`extension/figure1/R/figure1_final.R`) reads each
site's circular-mean peak day from `axes81_2d_phase_sd_distribution.csv`.
That column isn't present in this folder's `site_phase_sd_A1.csv` (a
smaller export already made for Figure 2, which didn't need it). Rather
than adding the column back in, this version derives each site's peak day
directly from its own smoothed climatology curve (`which.max()`) — a
self-contained substitute using only data already in this folder, giving
a visually identical result (confirmed by comparing renders).

## Open items, not yet decided

- **Low-amplitude site swap**: `extension/figure1/BUILD_NOTES.md`
  documents an evaluated-but-undecided recommendation to swap the
  low-amplitude example site (here and in Figure 2's inset) from
  `South_Central_Pacific_Polynesia_03` to `ORIGINAL_9_Palau`, which shows
  a visibly clearer double-peaked seasonal cycle — with a caveat
  (Palau's phase_R=0.797 is just under this project's 0.8 stability
  threshold). Not applied to either figure pending a decision.
