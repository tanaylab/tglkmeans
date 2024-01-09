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
