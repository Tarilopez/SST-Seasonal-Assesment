"""
Figure S9 -- residual power spectrum: binned periodogram, log-log, for
three representative sites, showing power rising from the 2-year toward
the 100-day timescale and falling from 100 days toward 10 days (S1.12).

Written in Python, not R like the other 12 supplementary figures, because
it reuses spectral_slope() (src/lib/spectral.py), already validated
against synthetic power-law series with a known exponent
(audit/task8_spectral_slope_validation.csv) -- porting that validation to
R for one figure would duplicate work without adding anything. Restyled
here (Okabe-Ito palette, 8pt minimum font, panel letters) to match the
other 12 figures and Figures 1/2; the underlying computation is unchanged
from audit/scripts/16_task8_spectral_validation.py's 8b diagnostic.

Reads audit/processed_corrected/harmonic_residuals.csv (the gap-fix-
corrected version, per this project's established precedence -- see
submission/tables/STATUS.md) for the three focal-9 sites already used in
that diagnostic (Central_GBR: mid-amplitude reef; Palau: lowest-amplitude/
weakest-signal focal site; N_Red_Sea_Aqaba: corrected pixel).
"""
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "src"))
from lib.spectral import spectral_slope  # noqa: E402

MIN_PT = 8
plt.rcParams.update({
    "font.family": "sans-serif", "font.size": MIN_PT, "axes.labelsize": MIN_PT,
    "xtick.labelsize": MIN_PT, "ytick.labelsize": MIN_PT, "pdf.fonttype": 42, "ps.fonttype": 42,
})
OKABE_ITO = ["#E69F00", "#56B4E9", "#009E73"]

PROC = ROOT / "audit" / "processed_corrected"
OUT = ROOT / "submission" / "figures" / "supplementary" / "figures"
OUT.mkdir(parents=True, exist_ok=True)

resid = pd.read_csv(PROC / "harmonic_residuals.csv", parse_dates=["date"])
sub = resid[(resid["product"] == "OISST_v2.1") & (resid["extraction"] == "single_pixel")]
sites_chosen = ["Central_GBR", "Palau", "N_Red_Sea_Aqaba"]

fig, axes = plt.subplots(1, 3, figsize=(169 / 25.4, 65 / 25.4), sharey=False)

for i, (ax, site, color) in enumerate(zip(axes, sites_chosen, OKABE_ITO)):
    r = sub[sub.site == site].sort_values("date")
    resid_vals = r["resid"].to_numpy()
    resid_vals = resid_vals[np.isfinite(resid_vals)]
    n = len(resid_vals)
    r0 = resid_vals - resid_vals.mean()
    freqs = np.fft.rfftfreq(n, d=1.0)
    power = np.abs(np.fft.rfft(r0)) ** 2
    f_lo, f_hi = 1.0 / 730, 1.0 / 10
    mask = (freqs >= f_lo) & (freqs <= f_hi) & (freqs > 0) & (power > 0)
    f_band, p_band = freqs[mask], power[mask]
    log_edges = np.linspace(np.log10(f_lo), np.log10(f_hi), 21)
    bin_idx = np.clip(np.digitize(np.log10(f_band), log_edges) - 1, 0, 19)
    xb, yb = [], []
    for b in range(20):
        in_bin = bin_idx == b
        if in_bin.sum() >= 1:
            xb.append(np.mean(np.log10(f_band[in_bin])))
            yb.append(np.log10(np.mean(p_band[in_bin])))
    period_days = 1.0 / (10 ** np.array(xb))
    ax.plot(period_days, yb, "o-", color=color, ms=3, lw=1.0)
    ax.set_xscale("log")
    ax.invert_xaxis()
    ax.set_xlabel("period (days)")
    ax.set_title(site.replace("_", " "), fontsize=MIN_PT, fontweight="bold")
    ax.axvline(100, color="grey", lw=0.7, ls="--", alpha=0.6)
    beta_hat, r2, _ = spectral_slope(resid_vals, dt_days=1.0, period_band_days=(10, 730))
    ax.text(0.03, 0.05, f"fit beta={beta_hat:.2f}\nfit R2={r2:.2f}", transform=ax.transAxes,
            fontsize=MIN_PT, va="bottom")
    ax.text(-0.12, 1.12, chr(65 + i), transform=ax.transAxes, fontsize=10, fontweight="bold")
    for spine in ax.spines.values():
        spine.set_linewidth(0.6)

axes[0].set_ylabel("log10(binned power)")
fig.text(0.01, 0.01, "2-harmonic residuals, full record (10d-2yr band); dashed line = 100-day period.",
          fontsize=MIN_PT, style="italic", ha="left")
fig.tight_layout(rect=[0, 0.05, 1, 1])
fig.savefig(OUT / "FigureS9_residual_power_spectrum.png", dpi=300)
fig.savefig(OUT / "FigureS9_residual_power_spectrum.pdf")
print("Wrote FigureS9_residual_power_spectrum.png/.pdf")
