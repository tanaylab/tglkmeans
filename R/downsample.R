#' Downsample a matrix to a target number of in each column
#'
#' @description This function takes a matrix and downsamples it to a target number of samples.
#' It uses a random seed for reproducibility and allows for removing columns with
#' small sums.
#'
#' @param mat The input matrix to be downsampled
#' @param target_n The target number of samples to downsample to
#' @param seed The random seed for reproducibility (default is NULL)
#' @param remove_columns Logical indicating whether to remove columns with small sums (default is FALSE)
#'
#' @return The downsampled matrix
#'
#' @examples
#' mat <- matrix(1:12, nrow = 4)
#' downsample_matrix(mat, 2)
#'
#' # Remove columns with small sums
#' downsample_matrix(mat, 12, remove_columns = TRUE)
#'
#' @export
downsample_matrix <- function(mat, target_n, seed = NULL, remove_columns = FALSE) {
    if (is.null(seed)) {
        seed <- sample(1:10000, 1)
    }

    # replace NAs with 0s for the cpp code
    orig_mat <- mat
    mat[is.na(mat)] <- 0
    ds_mat <- downsample_matrix_cpp(mat, target_n, seed)

    sums <- colSums(ds_mat, na.rm = TRUE)
    small_cols <- sums < target_n
    if (any(small_cols)) {
        if (remove_columns) {
            ds_mat <- ds_mat[, !small_cols, drop = FALSE]
            orig_mat <- orig_mat[, !small_cols, drop = FALSE]
        } else {
            cli_warn("Some columns ({which(small_cols)}) have a sum<{.val {target_n}}. These columns were not changed. To remove them, set {.field remove_columns=TRUE}.")
        }
    }

    # put back the NAs
    ds_mat[is.na(orig_mat)] <- NA

    return(ds_mat)
}
