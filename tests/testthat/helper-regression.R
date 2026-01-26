#' Tests if an object was changed since the last run.
#' If an rds file named \code{snapshot_dir/id.rds} exists its contents are compared with \code{obj},
#' otherwise the test is skipped unless snapshot updates are enabled.
#'
#' @param obj an R object
#' @param id unique test id.
#' @param snapshot_dir directory with rds file containing snapshot of previous versions
#' @param tolerance numeric tolerance for comparisons
regression_snapshot_dir <- function() {
    dir <- Sys.getenv("TGLKMEANS_REGRESSION_DIR", unset = "")
    if (!nzchar(dir)) {
        dir <- testthat::test_path("regression")
    }
    normalizePath(dir, winslash = "/", mustWork = FALSE)
}

regression_update_enabled <- function() {
    isTRUE(as.logical(Sys.getenv("TGLKMEANS_UPDATE_REGRESSION", unset = "false")))
}

expect_regression <- function(obj, id, snapshot_dir = regression_snapshot_dir(), tolerance = 1e-5) {
    regression_file <- file.path(snapshot_dir, paste0(id, ".rds"))

    if (!file.exists(regression_file)) {
        if (regression_update_enabled()) {
            if (!dir.exists(snapshot_dir)) {
                dir.create(snapshot_dir, recursive = TRUE)
            }
            saveRDS(obj, regression_file)
            cli::cli_alert_info("Created regression file: {regression_file}")
            testthat::skip("Regression snapshot created; re-run tests to compare.")
        }
        testthat::skip("Regression snapshot not available; set TGLKMEANS_REGRESSION_DIR.")
    }

    old <- readRDS(regression_file)
    testthat::expect_equal(old, obj, tolerance = tolerance)
}
