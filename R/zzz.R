.onLoad <- function(libname, pkgname) {
    n_cores <- parallel::detectCores()
    if (is.na(n_cores)) n_cores <- 1L
    tglkmeans.set_parallel(max(1L, round(n_cores * 0.75)))
    utils::suppressForeignCheck(c("clust", "new_clust", "true_clust", "intra_clust_order", "idx", ":=", "id"))
    utils::globalVariables(c("clust", "new_clust", "true_clust", "intra_clust_order", "idx", ":=", "id"))
}
