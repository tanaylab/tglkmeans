test_that("match_clusters maps every found cluster (not just the global best)", {
    set.seed(123)
    # higher sd => imperfect clustering => differing per-cell counts (no ties at
    # the global max). A global slice_max would map only one cluster.
    data <- simulate_data(n = 100, sd = 0.6, nclust = 5, dims = 2)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), 5,
        metric = "euclid", id_column = TRUE, verbose = FALSE, seed = 123
    )
    m <- match_clusters(data, res, 5)

    # every observation receives a mapped cluster
    expect_false(any(is.na(m$new_clust)))
    # every found cluster is mapped to exactly one true cluster
    mapping <- m %>%
        dplyr::distinct(clust, new_clust)
    expect_equal(nrow(mapping), dplyr::n_distinct(m$clust))
    expect_false(any(is.na(mapping$new_clust)))
})

test_that("match_clusters does not duplicate rows when a cluster ties across true clusters", {
    # two found clusters, each split 50/50 across the same two true clusters,
    # so true_clust counts tie within a cluster. with_ties must not duplicate rows.
    data <- tibble::tibble(
        id = 1:8,
        true_clust = c(1, 1, 2, 2, 1, 1, 2, 2)
    )
    res <- list(clust = tibble::tibble(
        id = 1:8,
        clust = c(1, 1, 1, 1, 2, 2, 2, 2)
    ))
    m <- match_clusters(data, res, 2)
    expect_equal(nrow(m), nrow(data))
})
