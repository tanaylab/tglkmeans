simulate_data <- function(n=100, sd=0.3, nclust=30, dims=2, frac_na=NULL){
	data <- purrr::map_df(1:nclust, ~ 
					as.data.frame(matrix(rnorm(n*dims, mean=.x, sd = sd), ncol = dims)) %>%
					mutate(m = .x)) %>% 
				tbl_df %>% 
				mutate(id = 1:n()) %>%
				select(id, everything(), m)
	if (!is.null(frac_na)){
		data$V1[sample(1:nrow(data), round(nrow(data)*frac_na))] <- NA
	}
	return(data)
}

match_clusters <- function(data, res, nclust){
	d <- data %>% left_join(res$clust %>% mutate(id = as.numeric(id)), by='id')
	clust_map <- d %>% group_by(clust, m) %>% summarise(n = n()) %>% top_n(1, n) %>% ungroup
	d <- d %>% left_join(clust_map %>% select(new_clust=m, clust), by='clust')
	return(d)
}

test_clustering <- function(n, sd, nclust, dims=2, method='euclid', frac_na=NULL){
	data <- simulate_data(n=n, sd=sd, nclust=nclust, dims=dims)
	res <- TGL_kmeans_tidy(data %>% select(id, starts_with('V')) , nclust, method, verbose=FALSE)
	mres <- match_clusters(data, res, nclust)
	frac_success <- sum(mres$m == mres$new_clust, na.rm=TRUE) / sum(!is.na(mres$new_clust))		
	return(frac_success)	
}