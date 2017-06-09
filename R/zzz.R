.onLoad <- function(libname, pkgname) {
	utils::suppressForeignCheck(c('clust', 'new_clust', 'true_clust'))
	utils::globalVariables(c('clust', 'new_clust', 'true_clust'))

}
