library(dplyr)
library(tglkmeans)


context("Missing data")
test_that("Stop when there are rows which contain only missing data", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL)
    data[3, -1] <- NA
    data[4, -1] <- NA
    expect_error(TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", verbose = FALSE, seed = 17), "The following rows contain only missing values: 3,4")
})

context("Matrix input")
test_that("Do not fail when input is matrix", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    mat <- data %>% select(starts_with("V")) %>% as.matrix()
    res <- TGL_kmeans_tidy(mat, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 17)
    expect_equal(nrow(data), nrow(res$clust))
    expect_true(all(data$id %in% res$cluster$id))

    expect_equal(nclust, nrow(res$centers))
    expect_equal(ndims, ncol(res$centers) - 1)
    expect_equal(nclust, length(unique(res$clust$clust)))
    expect_equal(nclust, length(unique(res$size$clust)))

    expect_true(all(res$center$clust %in% res$cluster$clust))
    expect_true(all(res$cluster$clust %in% res$center$clust))
    expect_true(all(res$size$clust %in% res$center$clust))
    expect_true(all(res$scenter$clust %in% res$size$clust))

    expect_equal(nrow(data), sum(res$size$n))
})

context("Correct output")
test_that("hclust intra cluster works", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = F, hclust_intra_clusters = TRUE, parallel = FALSE)

    expect_equal(nrow(data), nrow(res$clust))
    expect_true(all(data$id %in% res$cluster$id))
    expect_true(all(data$id %in% res$order$id))

    expect_equal(nclust, nrow(res$centers))
    expect_equal(ndims, ncol(res$centers) - 1)
    expect_equal(nclust, length(unique(res$clust$clust)))
    expect_equal(nclust, length(unique(res$size$clust)))

    expect_true(all(res$center$clust %in% res$cluster$clust))
    expect_true(all(res$cluster$clust %in% res$center$clust))
    expect_true(all(res$size$clust %in% res$center$clust))
    expect_true(all(res$scenter$clust %in% res$size$clust))

    expect_equal(nrow(data), sum(res$size$n))
})

context("Correct output")
test_that("all ids and clusters are present", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = F)

    expect_equal(nrow(data), nrow(res$clust))
    expect_true(all(data$id %in% res$cluster$id))

    expect_equal(nclust, nrow(res$centers))
    expect_equal(ndims, ncol(res$centers) - 1)
    expect_equal(nclust, length(unique(res$clust$clust)))
    expect_equal(nclust, length(unique(res$size$clust)))

    expect_true(all(res$center$clust %in% res$cluster$clust))
    expect_true(all(res$cluster$clust %in% res$center$clust))
    expect_true(all(res$size$clust %in% res$center$clust))
    expect_true(all(res$scenter$clust %in% res$size$clust))

    expect_equal(nrow(data), sum(res$size$n))
})

context("Verbosity")
test_that("quiet if verbose is turned off", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL)
    expect_silent(TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", verbose = FALSE, seed = 17))
})

context("Random seed")
test_that("setting the seed returns reproducible results", {
    nclust <- 30
    data <- simulate_data(n = 100, sd = 0.3, nclust = nclust, frac_na = NULL)
    res1 <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = F, seed = 17)
    res2 <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = F, seed = 17)
    expect_true(all(res1$centers[, -1] == res2$centers[, -1]))
})

context("Correct Classification (low dim)")
test_that("clustering is reasonable (low dim): euclid", {
    test_params <- expand.grid(n = c(100), sd = c(0.05, 0.1, 0.3), nclust = c(5, 30, 100), dims = c(2, 10)) %>% filter(nclust < n)
    apply(test_params, 1, function(x) {
        expect_gt(test_clustering(x[[1]], x[[2]], x[[3]], x[[4]], "euclid"), 0.85)
    })
})

test_that("clustering with NA is reasonable (low dim): euclid", {
    test_params <- expand.grid(n = c(100), sd = c(0.05, 0.1, 0.3), nclust = c(5, 30, 100), frac_na = c(0.05, 0.1, 0.2), dims = c(2, 10)) %>% filter(nclust < n * (1 - frac_na))
    apply(test_params, 1, function(x) {
        expect_gt(test_clustering(x[[1]], x[[2]], x[[3]], x[[5]], "euclid", frac_na = x[4]), 0.75)
    })
})

context("Correct Classification (high dim)")
test_that("clustering is reasonable (high dim): euclid", {
    test_params <- expand.grid(n = c(500), sd = c(0.3), nclust = c(5, 30), dims = c(300)) %>% filter(nclust < n)
    apply(test_params, 1, function(x) {
        expect_gt(test_clustering(x[[1]], x[[2]], x[[3]], x[[4]], "euclid"), 0.9)
    })
})

test_that("clustering with NA is reasonable (high dim): euclid", {
    test_params <- expand.grid(n = c(500), sd = c(0.3), nclust = c(5, 30), frac_na = c(0.1, 0.2), dims = c(300)) %>% filter(nclust < n * (1 - frac_na))
    apply(test_params, 1, function(x) {
        expect_gt(test_clustering(x[[1]], x[[2]], x[[3]], x[[5]], "euclid", frac_na = x[4]), 0.75)
    })
})
