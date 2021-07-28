context("onLoad")
test_that("onLoad does not fail", {
    library(tglkmeans)
    cores <- round(parallel::detectCores() / 2)
    if (cores == 1) {
        expect_false(getOption("tglkmeans.parallel"))
    } else {
        expect_true(getOption("tglkmeans.parallel"))
    }
})

context("number of threads")
test_that("parallel is turned off when number of threads is 1", {
    tglkmeans.set_parallel(1)
    expect_false(getOption("tglkmeans.parallel"))
})

test_that("parallel is turned on when number of threads is not 1", {
    tglkmeans.set_parallel(2)
    expect_true(getOption("tglkmeans.parallel"))
})
