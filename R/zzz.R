.onLoad <- function(libname, pkgname) {
    tglkmeans.set_parallel(round(parallel::detectCores() / 2))
    utils::suppressForeignCheck(c("clust", "new_clust", "true_clust", "intra_clust_order", "idx"))
    utils::globalVariables(c("clust", "new_clust", "true_clust", "intra_clust_order", "idx"))
}
