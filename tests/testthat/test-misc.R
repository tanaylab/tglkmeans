# Default thread count selection:
test_that("default thread count caps at 2 cores under R CMD check", {
    # CRAN sets _R_CHECK_LIMIT_CORES_; in that case never use more than 2 cores.
    expect_equal(tglkmeans_default_threads(n_cores = 64, limit_cores = TRUE), 2L)
    expect_equal(tglkmeans_default_threads(n_cores = 1, limit_cores = TRUE), 1L)
})

test_that("default thread count uses 75% of cores outside checks", {
    expect_equal(tglkmeans_default_threads(n_cores = 64, limit_cores = FALSE), 48L)
    expect_equal(tglkmeans_default_threads(n_cores = 1, limit_cores = FALSE), 1L)
    expect_equal(tglkmeans_default_threads(n_cores = 4, limit_cores = FALSE), 3L)
})

test_that("default thread count handles NA core detection", {
    expect_equal(tglkmeans_default_threads(n_cores = NA, limit_cores = FALSE), 1L)
    expect_equal(tglkmeans_default_threads(n_cores = NA, limit_cores = TRUE), 1L)
})

# onLoad:
test_that("onLoad does not fail", {
    skip_on_cran()
    library(tglkmeans)
    cores <- round(parallel::detectCores() / 2)
    if (cores == 1) {
        expect_false(getOption("tglkmeans.parallel"))
    } else {
        expect_true(getOption("tglkmeans.parallel"))
    }
})

# number of threads:
test_that("parallel is turned off when number of threads <= 1", {
    skip_on_cran()
    withr::with_options(
        list(tglkmeans.parallel = TRUE),
        {
            tglkmeans.set_parallel(1)
            expect_false(getOption("tglkmeans.parallel"))
        }
    )

    withr::with_options(
        list(tglkmeans.parallel = TRUE),
        {
            tglkmeans.set_parallel(0)
            expect_false(getOption("tglkmeans.parallel"))
        }
    )
})

test_that("parallel is turned on when number of threads is not 1", {
    skip_on_cran()
    withr::with_options(
        list(tglkmeans.parallel = FALSE),
        {
            tglkmeans.set_parallel(2)
            expect_true(getOption("tglkmeans.parallel"))
        }
    )
})
