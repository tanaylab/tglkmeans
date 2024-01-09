#' Downsample the columns of a matrix to a target number
#'
#' @description This function takes a matrix and downsamples it to a target number of samples.
#' It uses a random seed for reproducibility and allows for removing columns with
#' small sums.
#'
#' @param mat An integer matrix to be downsampled. Can be a matrix or sparse matrix (dgCMatrix).
#' If the matrix contains NAs, the function will run significantly slower. Values that are
#' not integers will be coerced to integers using \code{floor()}.
#' @param target_n The target number of samples to downsample to.
#' @param target_q A target quantile of sums to downsample to. Only one of 'target_n' or 'target_q' can be provided.
#' @param seed The random seed for reproducibility (default is NULL)
#' @param remove_columns Logical indicating whether to remove columns with small sums (default is FALSE)
#'
#' @return The downsampled matrix
#'
#' @examples
#' \dontshow{
#' # this line is only for CRAN checks
#' tglkmeans.set_parallel(1)
#' }
#'
#' mat <- matrix(1:12, nrow = 4)
#' downsample_matrix(mat, 2)
#'
#' # Remove columns with small sums
#' downsample_matrix(mat, 12, remove_columns = TRUE)
#'
#' # sparse matrix
#' mat_sparse <- Matrix::Matrix(mat, sparse = TRUE)
#' downsample_matrix(mat_sparse, 2)
#'
#' # with a quantile
#' downsample_matrix(mat, target_q = 0.5)
#'
#' @export
downsample_matrix <- function(mat, target_n = NULL, target_q = NULL, seed = NULL, remove_columns = FALSE) {
    if (is.null(target_n) && is.null(target_q)) {
        cli_abort("Either {.field target_n} or {.field target_q} must be provided.")
    } else if (!is.null(target_n) && !is.null(target_q)) {
        cli_abort("Only one of {.field target_n} or {.field target_q} can be provided.")
    }

    sums <- colsums_matrix(mat)
    if (!is.null(target_q)) {
        target_n <- round(stats::quantile(sums, target_q))
        cli::cli_alert_info("Using {.val {target_n}} as the target number (the {.val {target_q}} quantile of the column sums).")
    }

    if (is.null(seed)) {
        seed <- sample(1:10000, 1)
        cli::cli_alert_warning("No seed provided. Using {.val {seed}}.")
    } else if (!is.numeric(seed) || seed <= 0 || seed != as.integer(seed)) {
        cli_abort("{.field seed} must be a positive integer.")
    }

    if (!is.logical(remove_columns)) {
        cli_abort("{.field remove_columns} must be a logical value.")
    }

    if (target_n <= 0 || target_n != as.integer(target_n)) {
        cli_abort("{.field target_n} must be a positive integer.")
    }

    # replace NAs with 0s for the cpp code
    has_nas <- FALSE
    if (any(is.na(mat))) {
        has_nas <- TRUE
        cli_warn("Input matrix contains NAs. Processing would be significantly slower.")
        orig_mat <- mat
        mat[is.na(mat)] <- 0
    }

    if (methods::is(mat, "dgCMatrix")) {
        ds_mat <- rcpp_downsample_sparse(mat, target_n, seed)
    } else if (is.matrix(mat)) {
        ds_mat <- downsample_matrix_cpp(mat, target_n, seed)
    }

    rownames(ds_mat) <- rownames(mat)
    colnames(ds_mat) <- colnames(mat)

    small_cols <- sums < target_n
    if (any(small_cols)) {
        if (remove_columns) {
            ds_mat <- ds_mat[, !small_cols, drop = FALSE]
            if (has_nas) {
                orig_mat <- orig_mat[, !small_cols, drop = FALSE]
            }
            cli_alert_info("Removed {.val {sum(small_cols)}} columns with a sum smaller than {.val {target_n}}.")
        } else {
            cli_warn("{.val {sum(small_cols)}} columns have a sum smaller than {.val {target_n}}. These columns were not changed. To remove them, set {.field remove_columns=TRUE}.")
        }
    }

    if (has_nas) {
        # put back the NAs
        ds_mat[is.na(orig_mat)] <- NA
    }


    return(ds_mat)
}

colsums_matrix <- function(mat) {
    if (methods::is(mat, "dgCMatrix")) {
        return(Matrix::colSums(mat, na.rm = TRUE))
    } else if (is.matrix(mat)) {
        return(colSums(mat, na.rm = TRUE))
    } else {
        cli_abort("Input must be a matrix or a sparse matrix (dgCMatrix). class of {.field mat} is {.val {class(mat)}}.")
    }
}
