#' Bootstrapping
#'
#' @param df data frame. Each row is a single observation and each column is a dimension.
#' the first column can contain id for each observation (if id_column is TRUE).
#' @param k number of clusters
#' @param N_boot number of bootstrapping iterations
#' @param boot_ratio percent of observations to sample on each iteration
#' @param parallel run parallely (using doMC backend)
#' @param id_column \code{df}'s first column contains the observation id
#' @param tidy return 'tidy' output
#' @param ... additional parameters to TGL_kmeans
#'
#' @return for non 'tidy' output, list with the following components:
#' \describe{
#'   \item{coclust:}{NxN matrix (where N is the number of observations) with the number of times observation i and j occured in the same cluster.}
#'   \item{num_trials:}{NxN matrix with the number of times observation i and j where sampled together.}
#'   \item{coclust_frac:}{fraction of times observation i and j where clustered together out of the times they were sampled together (coclust matrix divided by num_trails matrix).}
#' }.
#' for 'tidy' output: tibble with coclust, num_trials and coclust_frac for each 'i' and 'j' pair.
#'
#'
#' @export
#'
#' @examples
#' d <- simulate_data(nclust=6)
#' bootstrap <- bootstrap_kmeans(d, k=6, N_boot=100)
#' names(bootstrap)
#' bootstrap$coclust[1:5, 1:5]
#' bootstrap$num_trials[1:5, 1:5]
#' bootstrap$coclust_frac[1:5, 1:5]
#'
#' bootstrap_kmeans(d, k=6, N_boot=100, tidy=TRUE)
#'
#'
bootstrap_kmeans <- function(df, k, N_boot, boot_ratio=0.75, parallel=getOption('tglkmeans.parallel'), id_column=TRUE, tidy=FALSE, ...){
	N <- nrow(df)
	boot_size <- round(N * boot_ratio)

	if (!id_column) {
        df <- df %>% mutate(id = as.character(1:n())) %>% select(id, everything())
    }

	tot_coclust <- matrix(0, nrow=N, ncol=N, dimnames=list(df$id, df$id))
	num_trials <- matrix(0, nrow=N, ncol=N, dimnames=list(df$id, df$id))

	boot_res <- plyr::alply(1:N_boot, 1, function(i) {
		boot_obs <- sample(1:N, boot_size)
		km <- TGL_kmeans_tidy(df[boot_obs, -1], k=k, id_column=FALSE, ...)
		boot_nodes <- as.numeric(km$clust$id)
		isclust_ci <- diag(max(km$clust$clust))[, km$clust$clust]
		coclust_ij <- t(isclust_ci) %*% isclust_ci

		return(list(boot_nodes=boot_nodes, isclust_ci=isclust_ci, coclust_ij=coclust_ij))
	}, .parallel = parallel)

	for (i in 1:length(boot_res)){
		boot_nodes <- boot_res[[i]]$boot_nodes
		coclust_ij <- boot_res[[i]]$coclust_ij

		tot_coclust[boot_nodes, boot_nodes] <- tot_coclust[boot_nodes, boot_nodes] + coclust_ij
		num_trials[boot_nodes, boot_nodes] <- num_trials[boot_nodes, boot_nodes] + 1
	}

	if (!tidy){
		return(list(coclust = tot_coclust, num_trials=num_trials, coclust_frac = tot_coclust / num_trials))
	}

	coclust <- reshape2::melt(tot_coclust, varnames=c('i', 'j'), value.name='coclust') %>% as.tibble()
	num_trials <- reshape2::melt(num_trials, varnames=c('i', 'j'), value.name='num_trials') %>% as.tibble()

	stopifnot(all(coclust$i == num_trials$i) && all(coclust$j == num_trials$j))

	return(coclust %>% mutate(num_trials = num_trials$num_trials, coclust_frac=coclust / num_trials))
}
