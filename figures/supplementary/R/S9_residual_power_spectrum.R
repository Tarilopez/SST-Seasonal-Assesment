#!/usr/bin/env Rscript
# Figure S9 -- residual power spectrum: binned periodogram, log-log, for
# three representative sites, showing power rising from the 2-year toward
# the 100-day timescale and falling from 100 days toward 10 days (S1.12).
#
# R port of lib/spectral.py::spectral_slope() and of the 8b diagnostic in
# audit/scripts/16_task8_spectral_validation.py. Per this project's standing
# rule, the port is validated before being trusted: (1) it must recover
# known exponents on synthetic power-law series (white noise beta=0, red
# noise beta=2, same construction as audit task 8a), and (2) it must
# reproduce the fitted beta / R2 the Python implementation gave for these
# exact three sites. The script stops if either check fails.
#
# Data: data/S9_harmonic_residuals_3sites.csv -- 2-harmonic-fit daily
# residuals (OISST v2.1, single pixel, 1982-2025) for Central_GBR (mid-
# amplitude reef), Palau (lowest-amplitude focal site) and N_Red_Sea_Aqaba
# (corrected pixel), extracted from audit/processed_corrected/
# harmonic_residuals.csv (the gap-fix-corrected version).
#
# Run from submission/figures/supplementary/R/.

setwd("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main")

source("theme_supp.R")

source("/Users/tarilopez/Downloads/SST_seasonalityAssessment-main/figures/supplementary/R/theme_supp.R")

suppressPackageStartupMessages(library(patchwork))


PERIOD_BAND <- c(10, 730)   # days
N_LOG_BINS <- 20

# ---------------------------------------------------------------------------
# Port of spectral_slope(): returns binned periodogram + OLS log-log fit
# ---------------------------------------------------------------------------
binned_periodogram <- function(resid, dt = 1, band = PERIOD_BAND, n_bins = N_LOG_BINS) {
  r <- resid[is.finite(resid)]
  n <- length(r)
  r0 <- r - mean(r)
  power_full <- Mod(fft(r0))^2
  k <- 0:floor(n / 2)                       # rfft ordinates
  freqs <- k / (n * dt)
  power <- power_full[k + 1]
  f_lo <- 1 / band[2]; f_hi <- 1 / band[1]
  keep <- freqs >= f_lo & freqs <= f_hi & freqs > 0 & power > 0
  f_band <- freqs[keep]; p_band <- power[keep]

  log_edges <- seq(log10(f_lo), log10(f_hi), length.out = n_bins + 1)
  bin_idx <- pmin(pmax(findInterval(log10(f_band), log_edges) - 1, 0), n_bins - 1)
  bins <- lapply(0:(n_bins - 1), function(b) {
    in_bin <- bin_idx == b
    if (!any(in_bin)) return(NULL)
    data.frame(log_f = mean(log10(f_band[in_bin])), log_p = log10(mean(p_band[in_bin])))
  })
  do.call(rbind, bins)
}

spectral_slope <- function(resid, ...) {
  b <- binned_periodogram(resid, ...)
  fit <- lm(log_p ~ log_f, data = b)
  list(beta = -unname(coef(fit)[2]), r2 = summary(fit)$r.squared, bins = b)
}

# ---------------------------------------------------------------------------
# Validation 1: synthetic series with an exact, known spectral exponent
# ---------------------------------------------------------------------------
make_power_law_series <- function(n, beta) {
  nf <- n %/% 2 + 1
  freqs <- (0:(nf - 1)) / n
  mag <- numeric(nf); mag[-1] <- freqs[-1]^(-beta / 2)
  phases <- runif(nf, 0, 2 * pi); phases[1] <- 0; if (n %% 2 == 0) phases[nf] <- 0
  X <- mag * exp(1i * phases)
  full <- c(X, Conj(X[if (n %% 2 == 0) (nf - 1):2 else nf:2]))
  Re(fft(full, inverse = TRUE)) / n
}

set.seed(1000)
N <- 5478; N_REPS <- 30
for (cfg in list(list(beta = 0, expect_high_r2 = FALSE), list(beta = 2, expect_high_r2 = TRUE))) {
  res <- t(replicate(N_REPS, { s <- spectral_slope(make_power_law_series(N, cfg$beta)); c(s$beta, s$r2) }))
  beta_ok <- abs(mean(res[, 1]) - cfg$beta) < 0.15
  r2_ok <- if (cfg$expect_high_r2) mean(res[, 2]) > 0.9 else mean(res[, 2]) < 0.5
  cat(sprintf("Synthetic check, true beta=%g: recovered %.3f, mean R2=%.3f -> %s\n",
              cfg$beta, mean(res[, 1]), mean(res[, 2]), if (beta_ok && r2_ok) "PASS" else "FAIL"))
  stopifnot("spectral_slope port failed synthetic validation" = beta_ok && r2_ok)
}

# ---------------------------------------------------------------------------
# Real data
# ---------------------------------------------------------------------------
#resid <- read.csv(here_root("submission", "figures", "supplementary", "data", "S9_harmonic_residuals_3sites.csv"),
  #                stringsAsFactors = FALSE)

resid <- read.csv("tables/S9_harmonic_residuals_3sites.csv",stringsAsFactors = FALSE)


sites <- c("Central_GBR", "Palau", "N_Red_Sea_Aqaba")
site_labels <- c(Central_GBR = "Central GBR", Palau = "Palau", N_Red_Sea_Aqaba = "N Red Sea Aqaba")
site_cols <- c("#025F9B", "#837AAE", "#5bd3b0")   # Okabe-Ito, as in the original diagnostic

# Validation 2: reproduce the Python implementation's fits for these sites
python_ref <- data.frame(site = sites, beta = c(-0.21, -0.51, -0.15), r2 = c(0.05, 0.17, 0.02))

fits <- lapply(sites, function(s) {
  r <- resid$resid[resid$site == s][order(resid$date[resid$site == s])]
  spectral_slope(r)
})
names(fits) <- sites
for (i in seq_along(sites)) {
  f <- fits[[sites[i]]]
  ok <- abs(f$beta - python_ref$beta[i]) < 0.01 && abs(f$r2 - python_ref$r2[i]) < 0.01
  cat(sprintf("%-16s beta=%.2f R2=%.2f  (Python: %.2f / %.2f) -> %s\n", sites[i], f$beta, f$r2,
              python_ref$beta[i], python_ref$r2[i], if (ok) "MATCH" else "MISMATCH"))
  stopifnot("R port does not reproduce the Python fit" = ok)
}

# ---------------------------------------------------------------------------
# Figure
# ---------------------------------------------------------------------------
panel <- function(i) {
  s <- sites[i]; f <- fits[[s]]
  b <- data.frame(period = 1 / 10^f$bins$log_f, log_p = f$bins$log_p)
  ggplot(b, aes(period, log_p)) +
    geom_vline(xintercept = 100, colour = "grey60", linetype = "dashed", linewidth = 0.5) +
    geom_line(colour = site_cols[i], linewidth = 0.7) +
    geom_point(colour = site_cols[i], size = 2) +
    scale_x_continuous(transform = scales::transform_compose("log10", "reverse"),
                  breaks = c(730, 300, 100, 30, 10), labels = c("730", "300", "100", "30", "10")) +
    annotate("text", x = 15, y = min(b$log_p), hjust = 1, vjust = 0, size = MIN_PT / .pt,
             label = sprintf("fit beta=%.2f\nfit R2=%.2f", f$beta, f$r2)) +
    labs(x = "Period (days)", y = if (i == 1) "Log10 (binned power)" else NULL,
         subtitle = site_labels[[s]], tag = LETTERS[i]) +
    theme(plot.subtitle = element_text(size = MIN_PT, face = "bold"))
}

final <- (panel(1) + panel(2) + panel(3) + plot_layout(nrow = 1)) +
  plot_annotation(caption = "2-harmonic residuals, full record (10 d - 2 yr band); dashed line = 100-day period.") &
  theme(plot.caption = element_text(size = MIN_PT, hjust = 0, face = "italic")); final

out <- here_root("submission", "figures", "supplementary", "figures")
ggsave(file.path(out, "FigureS9_residual_power_spectrum.png"), final, width = 169, height = 65, units = "mm", dpi = 300)
ggsave(file.path(out, "FigureS9_residual_power_spectrum.pdf"), final, width = 169, height = 65, units = "mm")
cat("Wrote FigureS9_residual_power_spectrum.png/.pdf\n")
