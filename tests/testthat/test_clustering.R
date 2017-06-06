library(tglkmeans)

context('Correct output')
test_that('all ids and clusters are present', {
	nclust <- 30
	data <- simulate_data(n=100, sd=0.3, nclust=nclust, frac_na=0.05)
	res <- TGL_kmeans_tidy(data %>% select(id, x,y) , nclust, metric='euclid', verbose=F)

	expect_equal(nrow(data), nrow(res$clust))
	expect_true(all(data$id %in% res$cluster$id))

	expect_equal(nclust, nrow(res$centers))
	expect_equal(nclust, length(unique(res$clust$clust)))
	expect_equal(nclust, length(unique(res$size$clust)))

	expect_true(all(res$center$clust %in% res$cluster$clust))
	expect_true(all(res$cluster$clust %in% res$center$clust))
	expect_true(all(res$size$clust %in% res$center$clust))
	expect_true(all(res$scenter$clust %in% res$size$clust))

	expect_equal(nrow(data), sum(res$size$n))

})



context('Verbosity')
test_that('quiet if verbose is turned off', {
	data <- simulate_data(n=100, sd=0.3, nclust=30, frac_na=NULL)	
	expect_silent(TGL_kmeans_tidy(data %>% select(id, x,y) , 30, metric='euclid', verbose=FALSE))
})

context('Correct Classification')
test_that('clustering is reasonable: euclid', {
	test_params <- expand.grid(n=c(100,1000), sd=c(0.05, 0.1, 0.3), nclust=c(5,10,30,100))  %>% filter(nclust < n)
	apply(test_params, 1, function(x) {		
		expect_gt(test_clustering(x[1], x[2], x[3], 'euclid'), 0.9)
	})		
})

test_that('clustering with NA is reasonable: euclid', {
	test_params <- expand.grid(n=c(100,1000), sd=c(0.05, 0.1, 0.3), nclust=c(5,10,30,100), frac_na=c(0.05, 0.1, 0.2))  %>% filter(nclust < n*(1-frac_na))
	apply(test_params, 1, function(x) {		
		expect_gt(test_clustering(x[1], x[2], x[3], 'euclid', frac_na=x[4]), 0.85)
	})		
})