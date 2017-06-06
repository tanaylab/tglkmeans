#' @import dplyr

#' @useDynLib tglkmeans
#' @importFrom Rcpp sourceCpp
NULL


#' TGL kmeans tidy
#' @export
TGL_kmeans_tidy <- function(df, k, metric, max_iter = 40, min_delta = 0.0001){
    mat <- t(df[, -1])
    # mat[is.na(mat)] <- .Machine$double.xmax

    df <- as.data.frame(df)
    ids <- as.character(df[, 1])

    column_names <- as.character(colnames(df)[-1])

    res <- TGL_kmeans_cpp(ids=ids, mat=mat, k=k, metric=metric, max_iter=max_iter, min_delta=min_delta)
    browser()
    res$centers <- t(res$centers) %>%
        tbl_df %>%
        set_names(column_names) %>%
        mutate(clust = 1:n()) %>%
        select(clust, everything()) %>%
        tbl_df

    res$cluster <- res$cluster %>% mutate(clust = clust + 1) %>% tbl_df

    res$size <- res$cluster %>% count(clust)

    return(res)
}

# TGL kmeans
#' @export
TGL_kmeans <- function(df, k, metric, max_iter = 40, min_delta = 0.0001){
    res <- TGL_kmeans_tidy(df=df, k=k, metric=metric, max_iter=max_iter, min_delta=min_delta)

    km <- list()

    km$cluster <- res$cluster$clust
    names(km$cluster) <- res$cluster$id

    km$centers <- as.matrix(res$centers[,-1])
    colnames(km$centers) <- colnames(df)[-1]

    km$size <- tapply(km$clust, km$clust, length)

    return(km)
}





