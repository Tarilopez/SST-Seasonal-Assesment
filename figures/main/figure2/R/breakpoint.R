#' Grid-search continuous piecewise-linear ("hinge") breakpoint estimator
#'
#' Direct R port of the Python implementation
#' (extension/axes81/scripts/04_axes81_breakpoint.py::grid_search_breakpoint
#' and bootstrap_breakpoint_ci), used to test whether phase circular SD
#' (timing precision) saturates above some threshold of seasonal amplitude
#' A1. Model: y = b0 + b1*x + b2*max(x-bp, 0), i.e. two joined linear
#' segments with slopes b1 (before bp) and b1+b2 (after bp). The breakpoint
#' location is chosen by minimizing residual sum of squares over a fine
#' grid spanning the 5th-95th percentile of x.
#'
#' MUST be validated against a synthetic case with a known breakpoint
#' before being trusted on real data -- see validate_breakpoint_method()
#' below, run automatically wherever this file is sourced.

fit_hinge_ssr <- function(x, y, bp) {
  hinge <- pmax(x - bp, 0)
  X <- cbind(1, x, hinge)
  fit <- lm.fit(X, y)
  coef <- fit$coefficients
  yhat <- X %*% coef
  ssr <- sum((y - yhat)^2)
  list(ssr = ssr, coef = as.numeric(coef))
}

grid_search_breakpoint <- function(x, y, n_grid = 300) {
  rng <- quantile(x, probs = c(0.05, 0.95), na.rm = TRUE)
  grid <- seq(rng[1], rng[2], length.out = n_grid)
  ssrs <- vapply(grid, function(bp) fit_hinge_ssr(x, y, bp)$ssr, numeric(1))
  best_idx <- which.min(ssrs)
  best_bp <- grid[best_idx]
  fit <- fit_hinge_ssr(x, y, best_bp)
  list(breakpoint = best_bp, coef = fit$coef, ssr = fit$ssr)
}

bootstrap_breakpoint_ci <- function(x, y, n_boot = 2000, seed = 20260901, n_grid = 200) {
  set.seed(seed)
  n <- length(x)
  boot_bp <- numeric(n_boot)
  for (i in seq_len(n_boot)) {
    idx <- sample.int(n, n, replace = TRUE)
    boot_bp[i] <- grid_search_breakpoint(x[idx], y[idx], n_grid = n_grid)$breakpoint
  }
  ci <- quantile(boot_bp, probs = c(0.025, 0.975), na.rm = TRUE)
  list(ci_lo = as.numeric(ci[1]), ci_hi = as.numeric(ci[2]), boot_dist = boot_bp)
}

#' Validate the estimator against synthetic data with a KNOWN breakpoint
#' (A1 = 2.0, matching the value informally suggested elsewhere in this
#' project's development before the validated estimate of 1.13 replaced
#' it) before trusting the method on real data. Same synthetic construction
#' as the Python original: declining slope for x < true_bp, flat for
#' x >= true_bp, Gaussian noise, n=81 to match the real sample size.
validate_breakpoint_method <- function(seed = 1, verbose = TRUE) {
  set.seed(seed)
  n <- 81
  x <- runif(n, 0.3, 6.0)
  true_bp <- 2.0
  slope_before <- -3.0
  y <- ifelse(x < true_bp, 10 + slope_before * x, 10 + slope_before * true_bp) + rnorm(n, 0, 1.0)

  fit <- grid_search_breakpoint(x, y)
  ci <- bootstrap_breakpoint_ci(x, y, n_boot = 2000)

  covers <- ci$ci_lo <= true_bp && true_bp <= ci$ci_hi
  close <- abs(fit$breakpoint - true_bp) < 0.5
  passed <- covers && close

  if (verbose) {
    cat(sprintf(
      "Breakpoint method validation: true_bp=%.2f recovered=%.3f 95%% CI=[%.3f,%.3f]\n",
      true_bp, fit$breakpoint, ci$ci_lo, ci$ci_hi
    ))
    cat(sprintf("  covers true value: %s | close to true value: %s | %s\n",
                covers, close, if (passed) "PASS -- proceeding to real data" else "FAIL -- STOP"))
  }

  list(passed = passed, true_bp = true_bp, recovered_bp = fit$breakpoint,
       ci_lo = ci$ci_lo, ci_hi = ci$ci_hi)
}
