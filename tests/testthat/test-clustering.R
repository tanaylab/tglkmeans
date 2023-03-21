library(dplyr)
library(tglkmeans)
set.seed(60427)

clustering_ok <- function(data, res, nclust, ndims, order = TRUE) {
    expect_equal(nrow(data), nrow(res$clust))
    expect_true(all(data$id %in% res$cluster$id))
    if (order) {
        expect_true(all(data$id %in% res$order$id))
    }

    expect_equal(nclust, nrow(res$centers))
    expect_equal(ndims, ncol(res$centers) - 1)
    expect_equal(nclust, length(unique(res$clust$clust)))
    expect_equal(nclust, length(unique(res$size$clust)))

    expect_true(all(res$center$clust %in% res$cluster$clust))
    expect_true(all(res$cluster$clust %in% res$center$clust))
    expect_true(all(res$size$clust %in% res$center$clust))
    expect_true(all(res$scenter$clust %in% res$size$clust))

    expect_equal(nrow(data), sum(res$size$n))
}

context("Missing data")
test_that("Stop when there are rows which contain only missing data", {
    data <- as.data.frame(simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL))
    data[3, -1] <- NA
    data[4, -1] <- NA
    expect_error(TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", verbose = FALSE, seed = 60427), "The following rows contain only missing values: 3,4")
})

context("Matrix input")
test_that("Do not fail when input is matrix", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    mat <- data %>%
        select(starts_with("V")) %>%
        as.matrix()
    res <- TGL_kmeans_tidy(mat, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427)

    clustering_ok(data, res, nclust, ndims, order = FALSE)
})

context("Rownames")
test_that("Use rownames if exists", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    data <- data %>%
        as.data.frame() %>%
        select(id, starts_with("V")) %>%
        mutate(id = paste0("id_", id)) %>%
        column_to_rownames("id")

    res <- TGL_kmeans_tidy(data, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427)
    clustering_ok(data, res, nclust, ndims, order = FALSE)

    expect_warning(res1 <- TGL_kmeans_tidy(data, 30, id_column = TRUE, metric = "euclid", verbose = FALSE, seed = 60427))
    clustering_ok(data, res1, nclust, ndims, order = FALSE)
})

test_that("Dot not fail when rownames do not exist", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    data <- data %>%
        select(starts_with("V")) %>%
        as.data.frame()
    data <- remove_rownames(data)

    res <- TGL_kmeans_tidy(data, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427)
    clustering_ok(data, res, nclust, ndims, order = FALSE)

    res_non_tidy <- TGL_kmeans(data, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427)
})

context("Metrics")
test_that("Pearson metric works", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, id_column = TRUE, metric = "pearson", verbose = FALSE, seed = 60427)
    clustering_ok(data, res, nclust, ndims, order = FALSE)
})

test_that("Spearman metric works", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, id_column = TRUE, metric = "spearman", verbose = FALSE, seed = 60427)
    clustering_ok(data, res, nclust, ndims, order = FALSE)
})

context("Correct output")

test_that("all ids and clusters are present", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE)

    clustering_ok(data, res, nclust, ndims, order = FALSE)
})

test_that("non tidy version works", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE, seed = 60427)
    res_tidy <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE, seed = 60427)

    clustering_ok(data, res_tidy, nclust, ndims, order = FALSE)

    expect_true(all(names(res$cluster) == res_tidy$cluster$id))
    expect_true(all(res$cluster == res_tidy$cluster$clust))

    expect_equal(res_tidy$centers %>% select(starts_with("V")) %>% as.matrix(), res$centers)

    expect_true(all(names(res$size) == res_tidy$size$clust))
    expect_true(all(res$size == res_tidy$size$n))
})

test_that("hclust intra cluster works", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE, hclust_intra_clusters = TRUE, parallel = FALSE, seed = 60427)
    clustering_ok(data, res, nclust, ndims, order = TRUE)
    res_non_tidy <- TGL_kmeans(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE, hclust_intra_clusters = TRUE, parallel = FALSE, , seed = 60427)

    expect_equal(res_non_tidy$order, res$order$order)
})

test_that("add_to_data works", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE, add_to_data = TRUE)

    clustering_ok(data, res, nclust, ndims, order = FALSE)

    expect_identical(res$data %>% select(id, starts_with("V")), data %>% as_tibble() %>% mutate(id = as.character(id)) %>% select(id, starts_with("V")))
    expect_equal(nrow(anti_join(res$data %>% select(id, clust), res$cluster %>% select(id, clust), by = c("id", "clust"))), 0)

    data <- data %>%
        as.data.frame() %>%
        select(id, starts_with("V")) %>%
        mutate(id = paste0("id_", id)) %>%
        column_to_rownames("id")

    res <- TGL_kmeans_tidy(data, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427, add_to_data = TRUE)
    expect_equal(res$data %>% select(starts_with("V")), data %>% select(starts_with("V")))
})

test_that("reorder func works when set to mean", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE, reorder_func = mean)

    clustering_ok(data, res, nclust, ndims, order = FALSE)
})

test_that("reorder func works when set to NULL", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE, reorder_func = NULL)

    clustering_ok(data, res, nclust, ndims, order = FALSE)
})

context("Verbosity")
test_that("quiet if verbose is turned off", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL)
    expect_silent(TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", verbose = FALSE, seed = 60427))
})

test_that("not quiet when verbose is turned on", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL)
    expect_message(TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", verbose = TRUE, seed = 60427))
})

test_that("Log is saved when 'keep_log' is turned on", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL)
    expect_warning(res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", verbose = TRUE, seed = 60427, keep_log = TRUE))
    expect_warning(res <- TGL_kmeans(data %>% select(id, starts_with("V")), 30, metric = "euclid", verbose = TRUE, seed = 60427, keep_log = TRUE))

    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", verbose = FALSE, seed = 60427, keep_log = TRUE)
    expect_type(res$log, "character")
    res <- TGL_kmeans(data %>% select(id, starts_with("V")), 30, metric = "euclid", verbose = FALSE, seed = 60427, keep_log = TRUE)
    expect_type(res$log, "character")
})

context("Random seed")
test_that("setting the seed returns reproducible results", {
    nclust <- 30
    data <- simulate_data(n = 100, sd = 0.3, nclust = nclust, frac_na = NULL)
    res1 <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE, seed = 60427)
    res2 <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", verbose = FALSE, seed = 60427)
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
    skip_on_cran()
    test_params <- expand.grid(n = c(500), sd = c(0.3), nclust = c(5, 30), dims = c(300)) %>% filter(nclust < n)
    apply(test_params, 1, function(x) {
        expect_gt(test_clustering(x[[1]], x[[2]], x[[3]], x[[4]], "euclid"), 0.9)
    })
})

test_that("clustering with NA is reasonable (high dim): euclid", {
    skip_on_cran()
    test_params <- expand.grid(n = c(500), sd = c(0.3), nclust = c(5, 30), frac_na = c(0.1, 0.2), dims = c(300)) %>% filter(nclust < n * (1 - frac_na))
    apply(test_params, 1, function(x) {
        expect_gt(test_clustering(x[[1]], x[[2]], x[[3]], x[[5]], "euclid", frac_na = x[4]), 0.75)
    })
})

context("Data simulation")
test_that("true_clust column is not added when add_true_clust is FALSE", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL, add_true_clust = FALSE)
    expect_true(!("true_clust" %in% colnames(data)))
})
