test_that("downsample_matrix returns the correct number of samples", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 2
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
    expect_true(all(mat >= ds_mat))
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

test_that("downsample_matrix returns the correct number of samples when there are NAs and remove_columns is TRUE", {
    mat <- matrix(1:12, nrow = 4)
    mat[1, 1] <- NA
    target_n <- 2
    expect_warning(ds_mat <- downsample_matrix(mat, target_n, remove_columns = TRUE))
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))

    # make sure the NAs are still there
    expect_true(all(is.na(ds_mat[1, 1])))
})

test_that("downsample_matrix returns the correct number of samples when there are NAs and remove_columns is FALSE", {
    mat <- matrix(1:12, nrow = 4)
    mat[1, 1] <- NA
    target_n <- 2
    expect_warning(ds_mat <- downsample_matrix(mat, target_n, remove_columns = FALSE))
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
    expect_true(all(mat[!is.na(mat)] >= ds_mat[!is.na(ds_mat)]))

    # make sure the NAs are still there
    expect_true(all(is.na(ds_mat[1, 1])))
})

test_that("downsample_matrix returns the correct number of samples when there are NAs and remove_columns is TRUE and the matrix is sparse", {
    mat <- Matrix::Matrix(matrix(1:12, nrow = 4), sparse = TRUE)
    mat[1, 1] <- NA
    target_n <- 2
    expect_warning(ds_mat <- downsample_matrix(mat, target_n, remove_columns = TRUE))
    expect_true(all(Matrix::colSums(ds_mat, na.rm = TRUE) == target_n))

    # make sure the NAs are still there
    expect_true(all(is.na(ds_mat[1, 1])))
})

test_that("downsample_matrix works with all zeros matrix", {
    mat <- matrix(0, nrow = 4)
    target_n <- 2
    expect_warning(ds_mat <- downsample_matrix(mat, target_n))
    expect_true(all(mat == ds_mat))

    ds_mat <- downsample_matrix(mat, target_n, remove_columns = TRUE)
    expect_equal(ncol(ds_mat), 0)
})

# Test with Different Matrix Sizes
test_that("downsample_matrix works with larger matrix", {
    mat <- matrix(1:1e3, nrow = 10)
    target_n <- 5
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
})

test_that("downsample_matrix works with single-column matrix", {
    mat <- matrix(1:10, nrow = 10)
    target_n <- 5
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
})

test_that("downsample_matrix works with single-row matrix", {
    mat <- matrix(1:10, nrow = 1)
    target_n <- 5
    ds_mat <- downsample_matrix(mat, target_n, remove_columns = TRUE)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
    expect_equal(ncol(ds_mat), 6)
})

# Test with Different target_n Values
test_that("downsample_matrix with target_n equal to number of rows", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 4
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
})

test_that("downsample_matrix with target_n greater than number of rows", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 6
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) <= target_n))
})

test_that("downsample_matrix with target_n equal to 1", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 1
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
})

test_that("downsample_matrix with target_n equal to 0", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 0
    expect_error(downsample_matrix(mat, target_n))
})

# Test with Different Matrix Types
test_that("downsample_matrix with sparse matrix", {
    mat <- Matrix::Matrix(matrix(1:12, nrow = 4), sparse = TRUE)
    target_n <- 2
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(all(Matrix::colSums(ds_mat, na.rm = TRUE) == target_n))
    expect_true(all(mat >= ds_mat))
})

test_that("downsample_matrix with invalid matrix type", {
    mat <- 1:12
    target_n <- 2
    expect_error(downsample_matrix(mat, target_n))

    mat <- Matrix::Matrix(matrix(1:12, nrow = 4), sparse = FALSE)
    target_n <- 2
    expect_error(downsample_matrix(mat, target_n))
})

# Test with non-integer values
test_that("downsample_matrix with non-integer values", {
    mat <- matrix(1:12, nrow = 4)
    mat[1, 1] <- 1.5
    target_n <- 2
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == target_n))
    expect_true(all(mat >= ds_mat))
})

# Test with Various Seed Values
test_that("downsample_matrix with fixed seed", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 2
    seed <- 123
    ds_mat1 <- downsample_matrix(mat, target_n, seed = seed)
    ds_mat2 <- downsample_matrix(mat, target_n, seed = seed)
    expect_equal(ds_mat1, ds_mat2)
})

test_that("downsample_matrix without specifying seed", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 2
    ds_mat <- downsample_matrix(mat, target_n)
    expect_true(is.matrix(ds_mat))
})

test_that("downsample_matrix with invalid seed", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 2
    expect_error(downsample_matrix(mat, target_n, seed = -1))
    expect_error(downsample_matrix(mat, target_n, seed = "not a number"))
})

test_that("downsample_matrix correctly downsamples matrix using target_q", {
    mat <- matrix(1:12, nrow = 4)
    target_q <- 0.5
    ds_mat <- downsample_matrix(mat, target_q = target_q, remove_columns = TRUE)
    expect_true(all(colSums(ds_mat, na.rm = TRUE) == round(stats::quantile(colSums(mat), target_q))))

    expect_warning(ds_mat <- downsample_matrix(mat, target_q = target_q, remove_columns = FALSE))
    expect_true(all(mat >= ds_mat))
})

test_that("Cannot provide both target_n and target_q", {
    mat <- matrix(1:12, nrow = 4)
    target_n <- 2
    target_q <- 0.5
    expect_error(downsample_matrix(mat, target_n = target_n, target_q = target_q))
})

test_that("Fail when no target_n or target_q is provided", {
    mat <- matrix(1:12, nrow = 4)
    expect_error(downsample_matrix(mat))
})

test_that("rownames and colnames are preserved", {
    mat <- matrix(1:12, nrow = 4)
    rownames(mat) <- letters[1:4]
    colnames(mat) <- LETTERS[1:3]
    target_n <- 2
    ds_mat <- downsample_matrix(mat, target_n)
    expect_equal(rownames(ds_mat), rownames(mat))
    expect_equal(colnames(ds_mat), colnames(mat))
})

test_that("rownames and colnames are preserved when remove_columns is TRUE", {
    mat <- matrix(1:12, nrow = 4)
    rownames(mat) <- letters[1:4]
    colnames(mat) <- LETTERS[1:3]
    target_n <- 20
    ds_mat <- downsample_matrix(mat, target_n, remove_columns = TRUE)
    expect_equal(rownames(ds_mat), rownames(mat))
    expect_equal(colnames(ds_mat), colnames(mat)[2:3])
})

test_that("rownames and colnames are preserved with a single column", {
    mat <- matrix(1:12, nrow = 4)
    rownames(mat) <- letters[1:4]
    colnames(mat) <- LETTERS[1:3]
    target_n <- 2
    ds_mat <- downsample_matrix(mat[, 1, drop = FALSE], target_n)
    expect_equal(rownames(ds_mat), rownames(mat))
    expect_equal(colnames(ds_mat), colnames(mat)[1])
})

test_that("rownames and colnames are preserved with a single row", {
    mat <- matrix(1:12, nrow = 4)
    rownames(mat) <- letters[1:4]
    colnames(mat) <- LETTERS[1:3]
    target_n <- 2
    expect_warning(ds_mat <- downsample_matrix(mat[1, , drop = FALSE], target_n))
    expect_equal(rownames(ds_mat), rownames(mat)[1])
    expect_equal(colnames(ds_mat), colnames(mat))
})
