.onLoad <- function(libname, pkgname) {
    tglkmeans.set_parallel(tglkmeans_default_threads())
    utils::suppressForeignCheck(c("clust", "new_clust", "true_clust", "intra_clust_order", "idx", ":=", "id"))
    utils::globalVariables(c("clust", "new_clust", "true_clust", "intra_clust_order", "idx", ":=", "id"))
}
