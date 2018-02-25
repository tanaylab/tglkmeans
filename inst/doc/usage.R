## ------------------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(tglkmeans)

## ------------------------------------------------------------------------
data <- simulate_data(n=100, sd=0.3, nclust=5, dims=2)
data

## ---- fig.show='hold'----------------------------------------------------
data %>% ggplot(aes(x=V1, y=V2, color=factor(true_clust))) + 
    geom_point() + 
    scale_color_discrete(name='true cluster')

## ------------------------------------------------------------------------
km <- TGL_kmeans_tidy(data %>% select(id, starts_with('V')) ,
		      k=5, 
		      metric='euclid', 
		      verbose=TRUE)

## ------------------------------------------------------------------------
names(km)

## ------------------------------------------------------------------------
km$centers

## ------------------------------------------------------------------------
km$cluster

## ------------------------------------------------------------------------
km$size

## ------------------------------------------------------------------------
d <- tglkmeans:::match_clusters(data, km, 5)
sum(d$true_clust == d$new_clust, na.rm=TRUE) / sum(!is.na(d$new_clust))

## ---- fig.show='hold'----------------------------------------------------
d %>% ggplot(aes(x=V1, y=V2, color=factor(new_clust), shape=factor(true_clust))) + 
    geom_point() + 
    scale_color_discrete(name='cluster') + 
    scale_shape_discrete(name='true cluster') + 
    geom_point(data=km$centers, size=7, color='black', shape='X')

## ------------------------------------------------------------------------
km <- TGL_kmeans_tidy(data %>% select(id, starts_with('V')), 
		      k=5, 
		      metric='euclid', 
		      verbose=FALSE, 
		      reorder_func=median)
km$centers

## ------------------------------------------------------------------------
data$V1[sample(1:nrow(data), round(nrow(data)*0.2))] <- NA
data

## ------------------------------------------------------------------------
km <- TGL_kmeans_tidy(data %>% select(id, starts_with('V')), 
		      k=5, 
		      metric='euclid', 
		      verbose=FALSE)
d <- tglkmeans:::match_clusters(data, km, 5)
sum(d$true_clust == d$new_clust, na.rm=TRUE) / sum(!is.na(d$new_clust))

## ---- fig.show='hold'----------------------------------------------------
d %>% ggplot(aes(x=V1, y=V2, color=factor(new_clust), shape=factor(true_clust))) + 
    geom_point() + 
    scale_color_discrete(name='cluster') + 
    scale_shape_discrete(name='true cluster') + 
    geom_point(data=km$centers, size=7, color='black', shape='X')

## ------------------------------------------------------------------------
data <- simulate_data(n=100, sd=0.3, nclust=30, dims=300)
km <- TGL_kmeans_tidy(data %>% select(id, starts_with('V')), 
    k=30, 
    metric='euclid', 
    verbose=FALSE)

## ------------------------------------------------------------------------
d <- tglkmeans:::match_clusters(data, km, 30)
sum(d$true_clust == d$new_clust, na.rm=TRUE) / sum(!is.na(d$new_clust))

## ------------------------------------------------------------------------
km_standard <- kmeans(data %>% select(starts_with('V')), 30)
km_standard$clust <- tibble(id = 1:nrow(data), clust=km_standard$cluster)

d <- tglkmeans:::match_clusters(data, km_standard, 30)
sum(d$true_clust == d$new_clust, na.rm=TRUE) / sum(!is.na(d$new_clust))


## ------------------------------------------------------------------------
km1 <- TGL_kmeans_tidy(data %>% select(id, starts_with('V')), 
		       k=30, 
		       metric='euclid', 
		       verbose=FALSE, 
		       seed=17)
km2 <- TGL_kmeans_tidy(data %>% select(id, starts_with('V')), 
		       k=30, 
		       metric='euclid', 
		       verbose=FALSE, 
		       seed=17)
all(km1$centers[, -1] == km2$centers[, -1])

