# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

reduce_coclust <- function(boot_nodes_l, cc_ij_mat_l, cc_mat) {
    invisible(.Call('_tglkmeans_reduce_coclust', PACKAGE = 'tglkmeans', boot_nodes_l, cc_ij_mat_l, cc_mat))
}

reduce_num_trials <- function(boot_nodes_l, cc_mat) {
    invisible(.Call('_tglkmeans_reduce_num_trials', PACKAGE = 'tglkmeans', boot_nodes_l, cc_mat))
}

TGL_kmeans_cpp <- function(ids, mat, k, metric, max_iter = 40, min_delta = 0.0001, use_cpp_random = FALSE, seed = -1L) {
    .Call('_tglkmeans_TGL_kmeans_cpp', PACKAGE = 'tglkmeans', ids, mat, k, metric, max_iter, min_delta, use_cpp_random, seed)
}

downsample_matrix_cpp <- function(input, samples, random_seed) {
    .Call('_tglkmeans_downsample_matrix_cpp', PACKAGE = 'tglkmeans', input, samples, random_seed)
}

rcpp_downsample_sparse <- function(matrix, samples, random_seed) {
    .Call('_tglkmeans_rcpp_downsample_sparse', PACKAGE = 'tglkmeans', matrix, samples, random_seed)
}

