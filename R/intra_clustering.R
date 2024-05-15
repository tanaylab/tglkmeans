hclust_every_cluster <- function(km, df, parallel = TRUE) {
    doFuture::withDoRNG({
        all_hc <- df %>%
            plyr::dlply(plyr::.(clust), function(x) {
                ids <- x$id
                dist <- as.matrix(x[, -1:-2]) %>%
                    t() %>%
                    tgs_cor(pairwise.complete.obs = TRUE, spearman = TRUE) %>%
                    tgs_dist()

                if (length(dist) == 0 || any(is.na(dist))) {
                    return(tibble(clust = x$clust[1], id = ids, intra_clust_order = 1:length(ids)))
                }

                hc <- hclust(dist, method = "ward.D2")
                return(tibble(clust = x$clust[1], id = ids, intra_clust_order = hc$order))
            }, .parallel = parallel) %>%
            purrr::map_df(~.x)
    })

    res <- df %>%
        select(id, clust) %>%
        mutate(idx = 1:n()) %>%
        left_join(all_hc, by = c("id", "clust")) %>%
        arrange(clust, intra_clust_order) %>%
        mutate(order = 1:n()) %>%
        arrange(idx) %>%
        select(id, clust, order, intra_clust_order)
    return(res)
}
