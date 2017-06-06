simulate_data <- function(n=100, sd=0.3, nclust=30, frac_na=NULL){
	data <- purrr::map_df(1:nclust, ~ 
					as.data.frame(matrix(rnorm(n, mean=.x, sd = sd), ncol = 2)) %>%
					rename(x=V1, y=V2) %>% 
					mutate(m = .x)) %>% 
				tbl_df %>% 
				mutate(id = 1:n()) %>%
				select(id, x, y, m)
	if (!is.null(frac_na)){
		data$x[sample(1:nrow(data), round(nrow(data)*frac_na))] <- NA
	}
	return(data)
}

match_clusters <- function(data, res, nclust){
	d <- data %>% left_join(res$clust %>% mutate(id = as.numeric(id)), by='id')
	clust_map <- d %>% group_by(clust, m) %>% summarise(n = n()) %>% top_n(1, n) %>% ungroup
	d <- d %>% left_join(clust_map %>% select(new_clust=m, clust), by='clust')
	return(d)
}

test_clustering <- function(n, sd, nclust, method='euclid', frac_na=NULL){
	data <- simulate_data(n=n, sd=sd, nclust=nclust)
	res <- TGL_kmeans_tidy(data %>% select(id, x,y) , nclust, method, verbose=F)
	mres <- match_clusters(data, res, nclust)
	frac_success <- sum(mres$m == mres$new_clust, na.rm=TRUE) / sum(!is.na(mres$new_clust))		
	return(frac_success)	
}