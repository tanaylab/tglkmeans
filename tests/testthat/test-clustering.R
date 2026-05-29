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

# Missing data:
test_that("Stop when there are rows which contain only missing data", {
    data <- as.data.frame(simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL))
    data[3, -1] <- NA
    data[4, -1] <- NA
    expect_error(TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 60427))
})

# Matrix input:
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

# Rownames:
test_that("Use rownames if exists", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    data <- data %>%
        as.data.frame() %>%
        select(id, starts_with("V")) %>%
        mutate(id = paste0("id_", id)) %>%
        tibble::column_to_rownames("id")

    res <- TGL_kmeans_tidy(data, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427)
    clustering_ok(data, res, nclust, ndims, order = FALSE)
    expect_true(all(rownames(data) == res$cluster$id))

    res <- TGL_kmeans(data, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427)
    expect_true(all(rownames(data) == names(res$cluster)))
})

test_that("Dot not fail when rownames do not exist", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    data <- data %>%
        select(starts_with("V")) %>%
        as.data.frame()
    data <- tibble::remove_rownames(data)

    res <- TGL_kmeans_tidy(data, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427)
    clustering_ok(data, res, nclust, ndims, order = FALSE)

    res_non_tidy <- TGL_kmeans(data, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427)
})

# Metrics:
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

# Correct output:

test_that("all ids and clusters are present", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE)

    clustering_ok(data, res, nclust, ndims, order = FALSE)
})

test_that("non tidy version works", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 60427)
    res_tidy <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 60427)

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
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE, hclust_intra_clusters = TRUE, seed = 60427)
    clustering_ok(data, res, nclust, ndims, order = TRUE)
    res_non_tidy <- TGL_kmeans(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE, hclust_intra_clusters = TRUE, seed = 60427)

    expect_equal(res_non_tidy$order, res$order$order)
})

test_that("hclust_every_cluster orders observations by dendrogram leaf order", {
    set.seed(42)
    nclust <- 3
    ndims <- 10
    npc <- 8
    df <- purrr::map(1:nclust, function(cl) {
        m <- matrix(rnorm(npc * ndims, mean = cl), ncol = ndims)
        tibble::as_tibble(m, .name_repair = ~ paste0("V", seq_along(.x))) %>%
            mutate(clust = cl, id = as.character((cl - 1) * npc + 1:npc))
    }) %>%
        purrr::list_rbind() %>%
        select(clust, id, everything())

    res <- hclust_every_cluster(km = NULL, df = df, parallel = FALSE)

    for (cl in unique(df$clust)) {
        x <- df[df$clust == cl, ]
        dmat <- as.matrix(x[, -1:-2]) %>%
            t() %>%
            tgs_cor(pairwise.complete.obs = TRUE, spearman = TRUE) %>%
            tgs_dist()
        hc <- stats::hclust(dmat, method = "ward.D2")
        # Within a cluster, sorting by intra_clust_order must reproduce the
        # dendrogram leaf order (ids[hc$order]).
        expected_ids <- x$id[hc$order]
        got <- res[res$clust == cl, ]
        got_ids <- got$id[order(got$intra_clust_order)]
        expect_equal(got_ids, expected_ids)
    }
})

test_that("add_to_data works", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE, add_to_data = TRUE)

    clustering_ok(data, res, nclust, ndims, order = FALSE)

    expect_identical(res$data %>% select(id, starts_with("V")), data %>% as_tibble() %>% mutate(id = as.character(id)) %>% select(id, starts_with("V")))
    expect_equal(nrow(anti_join(res$data %>% select(id, clust), res$cluster %>% select(id, clust), by = c("id", "clust"))), 0)

    data <- data %>%
        as.data.frame() %>%
        select(id, starts_with("V")) %>%
        mutate(id = paste0("id_", id)) %>%
        tibble::column_to_rownames("id")

    res <- TGL_kmeans_tidy(data, 30, id_column = FALSE, metric = "euclid", verbose = FALSE, seed = 60427, add_to_data = TRUE)
    expect_equal(res$data %>% select(starts_with("V")), data %>% select(starts_with("V")), ignore_attr = TRUE)
})

test_that("reorder func works when set to mean", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE, reorder_func = mean)

    clustering_ok(data, res, nclust, ndims, order = FALSE)
})

test_that("reorder func works when set to NULL", {
    nclust <- 30
    ndims <- 5
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = nclust, frac_na = 0.05)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE, reorder_func = NULL)

    clustering_ok(data, res, nclust, ndims, order = FALSE)
})

# Verbosity:
test_that("quiet if verbose is turned off", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL)
    expect_silent(TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 60427))
})

test_that("not quiet when verbose is turned on", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL)
    expect_output(TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", id_column = TRUE, verbose = TRUE, seed = 60427))
})

test_that("Log is saved when 'keep_log' is turned on", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL)
    expect_warning(res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, id_column = TRUE, metric = "euclid", verbose = TRUE, seed = 60427, keep_log = TRUE))
    expect_warning(expect_warning(res <- TGL_kmeans(data %>% select(id, starts_with("V")), 30, metric = "euclid", id_column = TRUE, verbose = TRUE, seed = 60427, keep_log = TRUE)))

    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 30, metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 60427, keep_log = TRUE)
    expect_type(res$log, "character")
    res <- TGL_kmeans(data %>% select(id, starts_with("V")), 30, metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 60427, keep_log = TRUE)
    expect_type(res$log, "character")
})

# Random seed:
test_that("setting the seed returns reproducible results", {
    nclust <- 30
    data <- simulate_data(n = 100, sd = 0.3, nclust = nclust, frac_na = NULL)
    res1 <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 60427)
    res2 <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 60427)
    expect_true(all(res1$centers[, -1] == res2$centers[, -1]))
})

# Correct Classification (low dim):
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

# Correct Classification (high dim):
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

# A single column data
test_that("clustering works with a single column data", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL)
    res <- TGL_kmeans_tidy(data %>% select(id, V1), 30, metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 60427)
    expect_equal(nrow(data), nrow(res$clust))
    expect_true(all(data$id %in% res$cluster$id))
    expect_equal(30, nrow(res$centers))
    expect_equal(1, ncol(res$centers) - 1)
    expect_equal(30, length(unique(res$clust$clust)))
    expect_equal(30, length(unique(res$size$clust)))
    expect_true(all(res$center$clust %in% res$cluster$clust))
    expect_true(all(res$cluster$clust %in% res$center$clust))
    expect_true(all(res$size$clust %in% res$center$clust))
    expect_true(all(res$scenter$clust %in% res$size$clust))
    expect_equal(nrow(data), sum(res$size$n))
})

# Data simulation:
test_that("true_clust column is not added when add_true_clust is FALSE", {
    data <- simulate_data(n = 100, sd = 0.3, nclust = 30, frac_na = NULL, add_true_clust = FALSE)
    expect_true(!("true_clust" %in% colnames(data)))
})

test_that("and error is thrown when number of observations is less than number of clusters", {
    expect_error(TGL_kmeans(data.frame(id = 1:10, V1 = rnorm(10)), 30, metric = "euclid", verbose = FALSE, seed = 60427))
    expect_error(TGL_kmeans(data.frame(id = numeric(0))))
})

# Auto-detection of ID column:
test_that("Auto-detect character first column as ID with warning", {
    data <- data.frame(
        sample_id = paste0("sample_", 1:100),
        V1 = rnorm(100),
        V2 = rnorm(100)
    )
    # Should warn about auto-detection
    expect_warning(
        res <- TGL_kmeans_tidy(data, k = 5, seed = 60427),
        "character/factor"
    )
    # IDs should be the sample_id column
    expect_equal(res$cluster$sample_id, data$sample_id)
})

test_that("Auto-detect factor first column as ID with warning", {
    data <- data.frame(
        sample_id = factor(paste0("sample_", 1:100)),
        V1 = rnorm(100),
        V2 = rnorm(100)
    )
    # Should warn about auto-detection
    expect_warning(
        res <- TGL_kmeans_tidy(data, k = 5, seed = 60427),
        "character/factor"
    )
    # IDs should be the sample_id column (converted to character)
    expect_equal(res$cluster$sample_id, as.character(data$sample_id))
})

test_that("No warning when id_column=TRUE is set explicitly", {
    data <- data.frame(
        sample_id = paste0("sample_", 1:100),
        V1 = rnorm(100),
        V2 = rnorm(100)
    )
    # Should not warn when explicitly set
    expect_no_warning(
        res <- TGL_kmeans_tidy(data, k = 5, id_column = TRUE, seed = 60427)
    )
    expect_equal(res$cluster$sample_id, data$sample_id)
})

test_that("Error when id_column=FALSE is set explicitly with character first column", {
    data <- data.frame(
        sample_id = paste0("sample_", 1:100),
        V1 = rnorm(100),
        V2 = rnorm(100)
    )
    # Should error when user explicitly says FALSE but data is non-numeric
    expect_error(
        TGL_kmeans_tidy(data, k = 5, id_column = FALSE, seed = 60427),
        "numeric"
    )
})

test_that("TGL_kmeans also auto-detects character first column", {
    data <- data.frame(
        sample_id = paste0("sample_", 1:100),
        V1 = rnorm(100),
        V2 = rnorm(100)
    )
    # Should warn about auto-detection
    expect_warning(
        res <- TGL_kmeans(data, k = 5, seed = 60427),
        "character/factor"
    )
    # Names should be the sample_id values
    expect_equal(names(res$cluster), data$sample_id)
})

# predict_tgl_kmeans:
test_that("predict_tgl_kmeans recovers training cluster assignments (euclid)", {
    data <- simulate_data(n = 200, sd = 0.3, dims = 5, nclust = 5, frac_na = NULL)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")),
        k = 5, id_column = TRUE, metric = "euclid", verbose = FALSE, seed = 60427
    )
    pred <- predict_tgl_kmeans(res, data %>% select(starts_with("V")))
    expect_equal(nrow(pred), nrow(data))
    expect_setequal(colnames(pred), c("id", "clust"))
    expect_true(all(pred$clust %in% res$centers$clust))
    expect_equal(pred$clust, res$cluster$clust)
})

test_that("predict_tgl_kmeans pearson/spearman round-trip", {
    data <- simulate_data(n = 200, sd = 0.3, dims = 10, nclust = 5, frac_na = NULL)
    for (m in c("pearson", "spearman")) {
        res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")),
            k = 5, id_column = TRUE, metric = m, verbose = FALSE, seed = 60427
        )
        pred <- predict_tgl_kmeans(res, data %>% select(starts_with("V")))
        expect_equal(nrow(pred), nrow(data))
        expect_true(all(pred$clust %in% res$centers$clust))
    }
})

# Bug #2: the training Euclidean distance is sqrt(sum_sq)/n where n is the number
# of dimensions present in BOTH the point and the center. predict must use the
# same metric. It used to call tgs_dist (a plain Euclidean), which disagrees once
# a center has a missing dimension so that n differs across centers. Here center 1
# is missing V2, so for x = (2, 3):
#   d(x, center1) = sqrt((2-0)^2) / 1          = 2.00
#   d(x, center2) = sqrt((2-0)^2 + (3-0)^2) / 2 = 1.80  <- nearer under the training metric
# A plain Euclidean would instead pick center 1 (2.00 < 3.61).
test_that("predict_tgl_kmeans euclid uses the training metric when a center has NA (#2)", {
    object <- structure(
        list(
            centers = tibble::tibble(clust = c(1L, 2L), V1 = c(0, 0), V2 = c(NA, 0)),
            metric = "euclid"
        ),
        class = "tgl_kmeans"
    )
    newdata <- matrix(c(2, 3), nrow = 1, dimnames = list(NULL, c("V1", "V2")))
    pred <- predict_tgl_kmeans(object, newdata)
    expect_equal(pred$clust, 2L)
})

# Bug #1: cond_mid_ranking tested the wrong missing sentinel (-REAL_MAX) while NAs
# are encoded as +REAL_MAX, so Spearman never excluded missing values - it ranked
# them as the largest value. The final training assignment is argmin distance to
# the centers, so every observation's assigned center must be (up to numerical
# tolerance) the nearest under an independent pairwise-complete Spearman computed
# in R. With the bug, observations with NAs are assigned to a center that is not
# actually nearest once missing values are properly dropped.
test_that("TGL_kmeans spearman excludes missing values (#1)", {
    data <- simulate_data(n = 200, sd = 0.3, dims = 10, nclust = 5, frac_na = 0.1)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")),
        k = 5, id_column = TRUE, metric = "spearman", verbose = FALSE, seed = 60427
    )
    mat <- as.matrix(data %>% select(starts_with("V")))
    centers <- as.matrix(res$centers[, -1])
    # pairwise-complete Spearman distance (-cor) from each observation to each center
    D <- matrix(NA_real_, nrow(mat), nrow(centers))
    for (j in seq_len(nrow(centers))) {
        D[, j] <- -suppressWarnings(apply(mat, 1, function(x) {
            stats::cor(x, centers[j, ], method = "spearman", use = "pairwise.complete.obs")
        }))
    }
    train_col <- match(res$cluster$clust, res$centers$clust)
    row_min <- apply(D, 1, min, na.rm = TRUE)
    train_dist <- D[cbind(seq_len(nrow(D)), train_col)]
    # the assigned center is the nearest one (ties from float-vs-double allowed)
    expect_true(all(train_dist - row_min < 1e-4, na.rm = TRUE))
})

# Issue #21: as.matrix(tgs_dist(.)) in predict overflowed integer range once
# the combined size exceeded ~46340 rows. Verify large inputs no longer crash
# and that chunked results agree with a brute-force per-center computation
# on a tractable subset.
test_that("predict_tgl_kmeans handles input larger than as.matrix.dist int limit (#21)", {
    skip_on_cran()
    set.seed(60427)
    nclust <- 5
    train <- simulate_data(n = 200, sd = 0.3, dims = 4, nclust = nclust, frac_na = NULL)
    res <- TGL_kmeans_tidy(train %>% select(id, starts_with("V")),
        k = nclust, id_column = TRUE, metric = "euclid", verbose = FALSE, seed = 60427
    )

    # Trigger the old code path: combined size = 50000 + nclust > 46340.
    big <- matrix(rnorm(50000 * 4), nrow = 50000, ncol = 4)
    colnames(big) <- paste0("V", seq_len(4))
    expect_no_error(pred <- predict_tgl_kmeans(res, big))
    expect_equal(nrow(pred), nrow(big))
    expect_true(all(pred$clust %in% res$centers$clust))

    # Cross-check chunked result against a brute-force per-row nearest-center
    # assignment on a small subset (tgs_dist's NA-aware Euclidean reduces to
    # the plain Euclidean when no NAs are present).
    subset <- big[1:500, , drop = FALSE]
    centers <- as.matrix(res$centers[, -1])
    brute <- apply(subset, 1, function(x) {
        which.min(sqrt(rowSums(sweep(centers, 2, x, "-")^2)))
    })
    expect_equal(pred$clust[1:500], res$centers$clust[brute])
})
