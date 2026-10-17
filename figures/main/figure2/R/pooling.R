#' DerSimonian-Laird random-effects meta-analytic pooling
#'
#' Direct R port of the Python implementation used throughout this
#' project's extension analysis (extension/scripts/16_taskE4_distributional_
#' analysis.py::dersimonian_laird), including the standard truncation of a
#' negative moment-estimator tau^2 to zero (Borenstein et al. 2009; also R's
#' metafor default).
#'
#' @param effect numeric vector of per-unit effect sizes (e.g. per-site
#'   trend slopes)
#' @param variance numeric vector of per-unit variances (same length as
#'   effect)
#' @return a list with: pooled (random-effects pooled estimate), se
#'   (standard error), ci_lo, ci_hi (95% CI), tau2 (between-unit variance),
#'   Q (Cochran's Q), df, I2 (percent heterogeneity)
dersimonian_laird <- function(effect, variance) {
  effect <- as.numeric(effect)
  variance <- as.numeric(variance)
  stopifnot(length(effect) == length(variance))

  w <- 1 / variance
  fixed_pooled <- sum(w * effect) / sum(w)
  Q <- sum(w * (effect - fixed_pooled)^2)
  k <- length(effect)
  df <- k - 1
  C <- sum(w) - sum(w^2) / sum(w)
  tau2 <- if (C > 0) max(0, (Q - df) / C) else 0

  w_re <- 1 / (variance + tau2)
  pooled_re <- sum(w_re * effect) / sum(w_re)
  se_re <- sqrt(1 / sum(w_re))
  z_crit <- 1.959963985
  ci_lo <- pooled_re - z_crit * se_re
  ci_hi <- pooled_re + z_crit * se_re
  I2 <- if (Q > 0) max(0, (Q - df) / Q) * 100 else 0

  list(pooled = pooled_re, se = se_re, ci_lo = ci_lo, ci_hi = ci_hi,
       tau2 = tau2, Q = Q, df = df, I2 = I2)
}

#' Convert a 95% CI to an approximate variance (Wald-type), the same
#' ci_to_var() convention used throughout the Python pipeline wherever a
#' bootstrap CI (not a parametric SE) needed to be fed into a
#' variance-weighted meta-analysis.
ci_to_var <- function(ci_lo, ci_hi) {
  ((ci_hi - ci_lo) / (2 * 1.959963985))^2
}

#' Pool a per-site table (must have columns: region, effect, ci_lo, ci_hi)
#' both overall and by region, via dersimonian_laird(). Regions with fewer
#' than min_n sites are excluded from POOLING (DerSimonian-Laird is not
#' defined below 3 units) but are returned in the per-region table with a
#' simple unweighted mean and NA CI, so the caller can decide how to
#' display them (open marker, footnote, etc.) rather than silently
#' dropping them.
pool_by_region <- function(df, min_n = 3) {
  df$variance <- ci_to_var(df$ci_lo, df$ci_hi)

  overall <- dersimonian_laird(df$effect, df$variance)

  region_counts <- table(df$region)
  region_rows <- lapply(names(region_counts), function(r) {
    sub <- df[df$region == r, ]
    n <- nrow(sub)
    if (n >= min_n) {
      res <- dersimonian_laird(sub$effect, sub$variance)
      data.frame(region = r, n_sites = n, pooled = res$pooled,
                 ci_lo = res$ci_lo, ci_hi = res$ci_hi, tau2 = res$tau2,
                 I2 = res$I2, pooled_method = "dersimonian_laird")
    } else {
      data.frame(region = r, n_sites = n, pooled = mean(sub$effect),
                 ci_lo = NA_real_, ci_hi = NA_real_, tau2 = NA_real_,
                 I2 = NA_real_, pooled_method = "simple_mean_no_CI_n_lt_3")
    }
  })
  region_df <- do.call(rbind, region_rows)

  list(overall = overall, by_region = region_df)
}
