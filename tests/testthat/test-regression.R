test_that("kmeans regression snapshots match", {
    skip_on_cran()

    snapshot_dir <- regression_snapshot_dir()
    if (!dir.exists(snapshot_dir)) {
        skip("Regression snapshots not available; set TGLKMEANS_REGRESSION_DIR.")
    }

    test_data_file <- file.path(snapshot_dir, "test_data.rds")
    if (!file.exists(test_data_file)) {
        skip("Regression test data not available; set TGLKMEANS_REGRESSION_DIR.")
    }

    test_data <- readRDS(test_data_file)
    df1 <- test_data$df1
    df3 <- test_data$df3
    df4 <- test_data$df4

    withr::with_options(
        list(tglkmeans.parallel = FALSE),
        {
            result1 <- TGL_kmeans(df1, 20, id_column = TRUE, metric = "euclid", verbose = FALSE, seed = 123)
            expect_regression(result1, "kmeans_euclid_basic", snapshot_dir)

            result2 <- TGL_kmeans(df1, 20, id_column = TRUE, metric = "pearson", verbose = FALSE, seed = 123)
            expect_regression(result2, "kmeans_pearson_basic", snapshot_dir)

            result3 <- TGL_kmeans(df3, 100, id_column = TRUE, metric = "euclid", verbose = FALSE, seed = 456)
            expect_regression(result3, "kmeans_euclid_large_k", snapshot_dir)

            result4 <- TGL_kmeans(df4, 30, id_column = TRUE, metric = "euclid", verbose = FALSE, seed = 789)
            expect_regression(result4, "kmeans_euclid_with_na", snapshot_dir)
        }
    )
})
