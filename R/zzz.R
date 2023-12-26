.onLoad <- function(libname, pkgname) {
    tglkmeans.set_parallel(pmax(1, round(parallel::detectCores() * 0.75)))
    utils::suppressForeignCheck(c("clust", "new_clust", "true_clust", "intra_clust_order", "idx", ":="))
    utils::globalVariables(c("clust", "new_clust", "true_clust", "intra_clust_order", "idx", ":="))
}
