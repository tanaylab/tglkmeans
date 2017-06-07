#' @import dplyr

#' @useDynLib tglkmeans
#' @importFrom Rcpp sourceCpp
NULL


#' TGL kmeans with 'tidy' output
#'
#' @param df data frame. Each row is a single observation and each column is a dimension.
#' the first column can contain id for each observation (if id_column is TRUE).
#' @param k nunmber of clusters
#' @param metric distance metric for kmeans++ seeding. can be 'euclid', 'pearson' or 'spearman'
#' @param max_iter maximal number of iterations
#' @param min_delta minimal change in assignments (fraction out of all observations) to continue iterating
#' @param verbose display algorithm messages
#' @param keep_log keep algorithm messages in 'log' field
#' @param id_column \code{df}'s first column contains the observation id
#' @param reorder_func function to reorder the clusters. operates on each center and orders by the result. e.g. \code{reorder_func == mean} would calculate the mean of each center and then would reorder the clusters accordingly. If \code{reorder_func == hclust} the centers would be ordered by hclust of the euclidian distance of the corelation matrix, i.e. \code{hclust(dist(cor(t(centers))))}
#' if NULL, no reordering would be done.
#' @param seed seed for the c++ random number generator
#'
#' @return list with the following components:
#' \describe{
#'   \item{cluster:}{tibble with `id` column with the observation id (`1:n` if no id column was supplied), and `clust` column with the observation assigned cluster.}
#'   \item{centers:}{tibble with `clust` column and the cluster centres.}
#'   \item{size:}{tibble with `clust` column and `n` column with the number of points in each cluster.}
#'   \item{log:}{messages from the algorithm run (only if \code{id_column == TRUE}).}
#' }
#'
#' @export
TGL_kmeans_tidy <- function(df,
                            k,
                            metric = 'euclid',
                            max_iter = 40,
                            min_delta = 0.0001,
                            verbose = FALSE,
                            keep_log = TRUE,
                            id_column = TRUE,
                            reorder_func = 'hclust',
                            seed = NULL) {

    if (is.null(seed)) {
        random_seed <- TRUE
        seed <- -1
    } else {
        random_seed <- FALSE
    }

    if (!id_column) {
        df <- df %>% mutate(id = 1:n()) %>% select(id, everything())
    }
    mat <- t(df[,-1])

    df <- as.data.frame(df)
    ids <- as.character(df[, 1])

    column_names <- as.character(colnames(df)[-1])
    if (verbose) {
        km <- TGL_kmeans_cpp(
                ids = ids,
                mat = mat,
                k = k,
                metric = metric,
                max_iter = max_iter,
                min_delta = min_delta,
                random_seed = random_seed,
                seed = seed
            )
    } else {
        log <- capture.output(
            km <- TGL_kmeans_cpp(
                ids = ids,
                mat = mat,
                k = k,
                metric = metric,
                max_iter = max_iter,
                min_delta = min_delta,
                random_seed = random_seed,
                seed = seed
            )
        )
    }

    km$centers <- t(km$centers) %>%
        tbl_df %>%
        set_names(column_names) %>%
        mutate(clust = 1:n()) %>%
        select(clust, everything()) %>%
        tbl_df

    km$cluster <- km$cluster %>% mutate(clust = clust + 1) %>% tbl_df

    km <- reorder_clusters(km, func = reorder_func)

    km$size <- km$cluster %>% count(clust) %>% ungroup

    if (keep_log) {
        km$log <- log
    }

    return(km)
}

reorder_clusters <- function(km, func='hclust'){
    if (is.null(func)) {
        return(km)
    }

    if (identical(func, 'hclust') ||
        identical(func, hclust)) {
        if (min(apply(km$centers[, -1], 1, var)) == 0) {
            warning("standard deviation of kmeans center is 0")
        } else {
            centers_hc <-
                km$centers[, -1] %>% t() %>% cor() %>% dist() %>% hclust('ward.D2')
            new_order <- centers_hc$order
        }
    } else {
        new_order <- order(apply(km$centers[,-1], 1, func))
    }

    clust_map <- tibble::tibble(clust = km$centers$clust[new_order]) %>% mutate(new_clust = 1:n())

    km$centers <- km$centers %>%
        left_join(clust_map, by = 'clust') %>%
        select(-clust) %>%
        select(clust = new_clust, everything()) %>%
        arrange(clust)

    km$cluster <- km$cluster %>%
        left_join(clust_map, by = 'clust') %>%
        select(-clust) %>%
        select(id, clust = new_clust)

    return(km)
}

#' kmeans++ with return value similar to R kmeans
#'
#' @inheritParams TGL_kmeans_tidy
#' @return list with the following components:
#' \describe{
#'   \item{cluster:}{A vector of integers (from ‘1:k’) indicating the cluster to which each point is allocated.}
#'   \item{centers:}{A matrix of cluster centres.}
#'   \item{size:}{The number of points in each cluster.}
#'   \item{log:}{messages from the algorithm run (only if \code{id_column == TRUE}).}
#' }
#' @export
TGL_kmeans <- function(df,
                       k,
                       metric = 'euclid',
                       max_iter = 40,
                       min_delta = 0.0001,
                       verbose = FALSE,
                       keep_log = TRUE,
                       id_column = TRUE,
                       reorder_func = 'hclust',
                       seed = NULL) {

    res <- TGL_kmeans_tidy(
        df = df,
        k = k,
        metric = metric,
        max_iter = max_iter,
        min_delta = min_delta,
        verbose = verbose,
        keep_log = keep_log,
        id_column = id_column,
        reorder_func = reorder_func,
        seed = seed)


    km <- list()

    km$cluster <- res$cluster$clust
    names(km$cluster) <- res$cluster$id

    km$centers <- as.matrix(res$centers[,-1])

    km$size <- tapply(km$clust, km$clust, length)

    if (keep_log){
        km$log <- res$log
    }

    return(km)
}

