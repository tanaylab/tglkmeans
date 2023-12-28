test_that("downsample_matrix returns the correct number of samples", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 2
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
})

test_that("downsample_matrix removes columns with small sums when remove_columns is TRUE", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 12
    ds_mat <- downsample_matrix(mat, target_n, remove_columns = TRUE)
    expect_equal(ncol(ds_mat), 2)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
})

test_that("downsample_matrix does not remove columns with small sums when remove_columns is FALSE", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 12
    expect_warning(ds_mat <- downsample_matrix(mat, target_n, remove_columns = FALSE))
    expect_equal(ncol(ds_mat), ncol(mat))
    expect_true(all(colSums(ds_mat[, -1], na.rm = TRUE) == target_n))
})

test_that("downsample_matrix returns the correct number of samples when there are NAs", {
    mat <- matrix(1:12, nrow = 4)
    mat[1, 1] <- NA
    target_n <- 2
    expect_warning(ds_mat <- downsample_matrix(mat, target_n))
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))

    # make sure the NAs are still there
    expect_true(all(is.na(ds_mat[1, 1])))
})
