#' TGL kmeans with 'tidy' output
#'
#' @param df data frame. Each row is a single observation and each column is a dimension.
#' the first column can contain id for each observation (if id_column is TRUE).
#' @param k number of clusters
#' @param metric distance metric for kmeans++ seeding. can be 'euclid', 'pearson' or 'spearman'
#' @param max_iter maximal number of iterations
#' @param min_delta minimal change in assignments (fraction out of all observations) to continue iterating
#' @param verbose display algorithm messages
#' @param keep_log keep algorithm messages in 'log' field
#' @param id_column \code{df}'s first column contains the observation id
#' @param reorder_func function to reorder the clusters. operates on each center and orders by the result. e.g. \code{reorder_func = mean} would calculate the mean of each center and then would reorder the clusters accordingly. If \code{reorder_func = hclust} the centers would be ordered by hclust of the euclidian distance of the corelation matrix, i.e. \code{hclust(dist(cor(t(centers))))}
#' if NULL, no reordering would be done.
#' @param add_to_data return also the original data frame with an extra 'clust' column with the cluster ids
#' @param seed seed for the c++ random number generator
#' @param bootstrap bootstrap to estimate robustness of the clusters
#' @param ...
#'
#' @return list with the following components:
#' \describe{
#'   \item{cluster:}{tibble with `id` column with the observation id (`1:n` if no id column was supplied), and `clust` column with the observation assigned cluster.}
#'   \item{centers:}{tibble with `clust` column and the cluster centers.}
#'   \item{size:}{tibble with `clust` column and `n` column with the number of points in each cluster.}
#'   \item{data:}{tibble with `clust` column the original data frame.}
#'   \item{log:}{messages from the algorithm run (only if \code{id_column = TRUE}).}
#'   \item{bootstrap:}{tibble with 'clust' column and 'robust' column with the number of times the members of the clusters were clustered together divided by the total times they were sampled together. (only if bootstrap = TRUE)}
#' }
#'
#' @examples
#'
#' library(dplyr)
#' # create 5 clusters normally distribution around 1:5
#' d <- purrr::map_df(1:5, ~
#'      as.data.frame(matrix(rnorm(100, mean=.x, sd = 0.3), ncol = 2))) %>%
#'          mutate(id = 1:n()) %>%
#'          select(id, everything())
#' head(d)
#'
#' # cluster
#' km <- TGL_kmeans_tidy(d, k=5, 'euclid', verbose=TRUE)
#' km
#' 
#' # bootstrapping
#' km <- TGL_kmeans_tidy(d, k=5, 'euclid', N_boot=100, bootstrap=TRUE)
#' km$bootstrap
#'
#'

#' @seealso \code{\link{TGL_kmeans}}
#'
#' @inheritDotParams bootstrap_kmeans
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
                            add_to_data = FALSE,
                            seed = NULL,
                            bootstrap = FALSE,
                            ...) {

    if (is.null(seed)) {
        random_seed <- TRUE
        seed <- -1
    } else {
        random_seed <- FALSE
    }

    if (!id_column) {
        df <- df %>% mutate(id = as.character(1:n())) %>% select(id, everything())
    } else {
        if (verbose){
            message(sprintf('id column: %s', colnames(df)[1]))
        }
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
        log <- utils::capture.output(
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
        tbl_df() %>%
        purrr::set_names(column_names) %>%
        mutate(clust = 1:n()) %>%
        select(clust, everything()) %>%
        tbl_df()

    km$cluster <- km$cluster %>% mutate(clust = clust + 1) %>% tbl_df

    if (k > 1){
        km <- reorder_clusters(km, func = reorder_func)
    }

    km$size <- km$cluster %>% count(clust) %>% ungroup

    colnames(km$cluster)[1] <- colnames(df)[1]

    if (keep_log && !verbose) {
        km$log <- log
    }

    if (add_to_data){
        km$data <- df %>% left_join(km$cluster, by=colnames(df)[1]) %>% select(clust, everything()) %>% tbl_df()
        if (!id_column){
            km$data <- km$data %>% select(-id)
        }
    }

    if (bootstrap){
        message('bootstrapping')
        bt <- bootstrap_kmeans(df=df, k=k, id_column=id_column, metric=metric, max_iter=max_iter, min_delta=min_delta, seed=seed, ...)
        
        km$bootstrap <- km$clust %>% 
            group_by(clust) %>% 
            do({
                tibble(robust=
                    sum(bt$coclust[.$id, .$id], na.rm=TRUE) / 
                    sum(bt$num_trials[.$id, .$id], na.rm=TRUE))
            })
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

    clust_map <- tibble(clust = km$centers$clust[new_order]) %>% mutate(new_clust = 1:n())

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
#' @inheritDotParams bootstrap_kmeans
#' @return list with the following components:
#' \describe{
#'   \item{cluster:}{A vector of integers (from ‘1:k’) indicating the cluster to which each point is allocated.}
#'   \item{centers:}{A matrix of cluster centres.}
#'   \item{size:}{The number of points in each cluster.}
#'   \item{log:}{messages from the algorithm run (only if \code{id_column == TRUE}).}
#'   \item{bootstrap:}{number of times the members of the clusters were clustered together divided by the total times they were sampled together (only if bootstrap = TRUE).}
#' }
#'
#' @examples
#'
#' library(dplyr)
#'
#' # create 5 clusters normally distribution around 1:5
#' d <- purrr::map_df(1:5, ~
#'      as.data.frame(matrix(rnorm(100, mean=.x, sd = 0.3), ncol = 2))) %>%
#'          mutate(id = 1:n()) %>%
#'          select(id, everything())
#' head(d)
#'
#' # cluster
#' km <- TGL_kmeans(d, k=5, 'euclid', verbose=TRUE)
#' names(km)
#' km$centers
#' head(km$cluster)
#' km$size
#' 
#' # bootstrapping
#' km <- TGL_kmeans(d, k=5, 'euclid', N_boot=100, bootstrap=TRUE)
#' km$bootstrap
#'
#' @seealso \code{\link{TGL_kmeans_tidy}}
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
                       seed = NULL,
                       bootstrap = FALSE, 
                       ...) {

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
        seed = seed,
        bootstrap=bootstrap, 
        ...)


    km <- list()

    km$cluster <- res$cluster$clust
    if (id_column){
        names(km$cluster) <- res$cluster[[colnames(df)[1]]]
    } else {
        names(km$cluster) <- res$cluster$id
    }


    km$centers <- as.matrix(res$centers[,-1])

    km$size <- tapply(km$clust, km$clust, length)

    if (keep_log){
        km$log <- res$log
    }

    if (bootstrap){
        km$bootstrap <- res$bootstrap$robust
    }

    return(km)
}

