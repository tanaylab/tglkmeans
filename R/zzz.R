.onLoad <- function(libname, pkgname) {
    tglkmeans.set_parallel(parallel::detectCores() / 2)
    utils::suppressForeignCheck(c("clust", "new_clust", "true_clust"))
    utils::globalVariables(c("clust", "new_clust", "true_clust"))
}
