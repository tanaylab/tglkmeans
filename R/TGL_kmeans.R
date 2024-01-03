#' TGL kmeans with 'tidy' output
#'
#' @param df a data frame or a matrix. Each row is a single observation and each column is a dimension.
#' the first column can contain id for each observation (if id_column is TRUE),
#' otherwise the rownames are used.
#' @param k number of clusters. Note that in some cases the algorithm might return less clusters than k.
#' @param metric distance metric for kmeans++ seeding. can be 'euclid', 'pearson' or 'spearman'
#' @param max_iter maximal number of iterations
#' @param min_delta minimal change in assignments (fraction out of all observations) to continue iterating
#' @param verbose display algorithm messages
#' @param keep_log keep algorithm messages in 'log' field
#' @param id_column \code{df}'s first column contains the observation id
#' @param reorder_func function to reorder the clusters. operates on each center and orders by the result. e.g. \code{reorder_func = mean} would calculate the mean of each center and then would reorder the clusters accordingly. If \code{reorder_func = hclust} the centers would be ordered by hclust of the euclidean distance of the correlation matrix, i.e. \code{hclust(dist(cor(t(centers))))}
#' if NULL, no reordering would be done.
#' @param add_to_data return also the original data frame with an extra 'clust' column with the cluster ids ('id' is the first column)
#' @param hclust_intra_clusters run hierarchical clustering within each cluster and return an ordering of the observations.
#' @param seed seed for the c++ random number generator
#' @param parallel cluster every cluster parallelly (if hclust_intra_clusters is true)
#' @param use_cpp_random use c++ random number generator instead of R's. This should be used for only for
#' backwards compatibility, as from version 0.4.0 onwards the default random number generator was changed o R.
#'
#' @return list with the following components:
#' \describe{
#'   \item{cluster:}{tibble with `id` column with the observation id (`1:n` if no id column was supplied), and `clust` column with the observation assigned cluster.}
#'   \item{centers:}{tibble with `clust` column and the cluster centers.}
#'   \item{size:}{tibble with `clust` column and `n` column with the number of points in each cluster.}
#'   \item{data:}{tibble with `clust` column the original data frame.}
#'   \item{log:}{messages from the algorithm run (only if \code{id_column = FALSE}).}
#'   \item{order:}{tibble with 'id' column, 'clust' column, 'order' column with a new ordering if the observations and 'intra_clust_order' column with the order within each cluster. (only if hclust_intra_clusters = TRUE)}
#' }
#'
#' @examples
#' \dontshow{
#' # this line is only for CRAN checks
#' tglkmeans.set_parallel(1)
#' }
#'
#' # create 5 clusters normally distributed around 1:5
#' d <- simulate_data(
#'     n = 100,
#'     sd = 0.3,
#'     nclust = 5,
#'     dims = 2,
#'     add_true_clust = FALSE,
#'     id_column = FALSE
#' )
#'
#' head(d)
#'
#' # cluster
#' km <- TGL_kmeans_tidy(d, k = 5, "euclid", verbose = TRUE)
#' km
#' @seealso \code{\link{TGL_kmeans}}
#'
#' @export
TGL_kmeans_tidy <- function(df,
                            k,
                            metric = "euclid",
                            max_iter = 40,
                            min_delta = 0.0001,
                            verbose = FALSE,
                            keep_log = FALSE,
                            id_column = FALSE,
                            reorder_func = "hclust",
                            add_to_data = FALSE,
                            hclust_intra_clusters = FALSE,
                            seed = NULL,
                            parallel = getOption("tglkmeans.parallel"),
                            use_cpp_random = FALSE) {
    if (!is.null(seed)) {
        set.seed(seed)
    } else {
        seed <- -1
    }

    if (!(metric %in% c("euclid", "pearson", "spearman"))) {
        cli_abort("{.field metric} must be one of 'euclid', 'pearson' or 'spearman'")
    }

    if (max_iter < 1) {
        cli_abort("{.field max_iter} must be greater than 0")
    }

    if (min_delta < 0 || min_delta > 1) {
        cli_abort("{.field min_delta} must be between 0 and 1")
    }

    if (!is.matrix(df) && !is.data.frame(df)) {
        cli_abort("{.field df} must be a matrix or a data frame")
    }

    if (tibble::is_tibble(df)) {
        df <- as.data.frame(df)
    }

    # Extract IDs if necessary
    ids <- as.character(seq_len(nrow(df)))
    id_column_name <- "id"
    if (!is.null(rownames(df))) {
        ids <- rownames(df)
    }

    if (id_column) {
        ids <- as.character(df[, 1])
        id_column_name <- colnames(df)[1]
        df <- df[, -1]
    }

    mat <- df

    # make sure that the input is numeric
    mat <- as.matrix(mat)
    if (!is.numeric(mat)) {
        if (any(!is.numeric(mat[, 1])) && missing(id_column) && !id_column) {
            cli_abort("{.field df} must be numeric. Note that the default of {.field id_column} was changed to FALSE in version {.field 0.4.0}. If you want to use the first column as ids, please set {.field id_column=TRUE}")
        }
        cli_abort("{.field df} must be numeric.")
    }

    if (k < 1) {
        cli_abort("k must be greater than 0")
    }

    if (nrow(mat) < k) {
        cli_abort("number of observations ({.val {nrow(mat)}} must be greater than k ({.val {k}})")
    }

    # Thorw an error if there are rows that do not contain any value
    n_not_missing <- rowSums(!is.na(mat))
    if (any(n_not_missing == 0)) {
        all_nas <- which(n_not_missing == 0)
        cli_abort("The following rows contain only missing values: {.val {all_nas}}")
    }

    if (verbose) {
        km <- TGL_kmeans_cpp(
            ids = ids,
            mat = t(mat),
            k = k,
            metric = metric,
            max_iter = max_iter,
            min_delta = min_delta,
            use_cpp_random = use_cpp_random,
            seed = seed
        )
    } else {
        log <- utils::capture.output(
            km <- TGL_kmeans_cpp(
                ids = ids,
                mat = t(mat),
                k = k,
                metric = metric,
                max_iter = max_iter,
                min_delta = min_delta,
                use_cpp_random = use_cpp_random,
                seed = seed
            )
        )
    }

    # Processing the output

    km$centers <- t(km$centers) %>%
        as_tibble(.name_repair = "minimal") %>%
        purrr::set_names(colnames(mat)) %>%
        mutate(clust = 1:n()) %>%
        select(clust, everything()) %>%
        as_tibble()

    km$cluster <- km$cluster %>%
        mutate(clust = clust + 1) %>%
        as_tibble()

    if (k > 1) {
        km <- reorder_clusters(km, func = reorder_func)
    }

    colnames(km$cluster)[1] <- id_column_name

    km$size <- km$cluster %>%
        count(clust) %>%
        ungroup()

    if (keep_log) {
        if (verbose) {
            cli_warn("cannot keep log when {.field verbose=TRUE}")
        } else {
            km$log <- log
        }
    }

    if (add_to_data) {
        km$data <- add_data_to_km_object(df, km$cluster, ids, id_column_name)
        if (!id_column) {
            km$data <- as.data.frame(km$data)
            rownames(km$data) <- km$data$id
            km$data <- km$data %>% select(-id)
        }
    }

    if (hclust_intra_clusters) {
        cli_alert_info("running hclust within each cluster")
        if (is.null(km$data)) {
            full_data <- add_data_to_km_object(df, km$cluster, ids, id_column_name)
        } else {
            full_data <- km$data
        }
        full_data <- full_data %>%
            select(clust, !!id_column_name, everything())
        km$order <- hclust_every_cluster(km, full_data, parallel = parallel)
    }

    return(km)
}

add_data_to_km_object <- function(df, cluster, ids, id_column_name) {
    df %>%
        # add the ids at id_column_name
        mutate(!!id_column_name := as.character(ids)) %>%
        left_join(cluster, by = id_column_name) %>%
        select(clust, everything()) %>%
        as_tibble()
}


reorder_clusters <- function(km, func = "hclust") {
    # if there is an empty cluster, remove it and renumber the clusters
    empty_clusters <- km$centers %>%
        filter(!(clust %in% km$cluster$clust)) %>%
        pull(clust) %>%
        unique()

    if (length(empty_clusters) > 0) {
        clust_map <- km$centers %>%
            filter(!(clust %in% empty_clusters)) %>%
            mutate(new_clust = 1:n()) %>%
            select(clust, new_clust)

        km$centers <- km$centers %>%
            filter(!(clust %in% empty_clusters)) %>%
            left_join(clust_map, by = "clust") %>%
            mutate(clust = new_clust) %>%
            select(-new_clust)

        km$cluster <- km$cluster %>%
            filter(!(clust %in% empty_clusters)) %>%
            left_join(clust_map, by = "clust") %>%
            mutate(clust = new_clust) %>%
            select(-new_clust)
    }

    if (is.null(func)) {
        return(km)
    }

    if (identical(func, "hclust") ||
        identical(func, hclust)) {
        if (min(apply(km$centers[, -1], 1, var, na.rm = TRUE), na.rm = TRUE) == 0) {
            cli_warn("standard deviation of kmeans center is 0")
        } else {
            cm <- km$centers[, -1] %>%
                t() %>%
                cor(use = "pairwise.complete.obs")

            # we set NA's to zero in order for hclust not to fail when NA's are present in the dist object
            cm[is.na(cm)] <- 0

            centers_hc <- cm %>%
                dist() %>%
                stats::hclust("ward.D2")

            new_order <- centers_hc$order
        }
    } else {
        new_order <- order(apply(km$centers[, -1], 1, func))
    }

    clust_map <- tibble(clust = km$centers$clust[new_order]) %>% mutate(new_clust = 1:n())

    km$centers <- km$centers %>%
        left_join(clust_map, by = "clust") %>%
        select(-clust) %>%
        select(clust = new_clust, everything()) %>%
        arrange(clust)

    km$cluster <- km$cluster %>%
        left_join(clust_map, by = "clust") %>%
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
#'   \item{centers:}{A matrix of cluster centers.}
#'   \item{size:}{The number of points in each cluster.}
#'   \item{log:}{messages from the algorithm run (only if \code{id_column == TRUE}).}
#'   \item{order:}{A vector of integers with the new ordering if the observations. (only if hclust_intra_clusters = TRUE)}
#' }
#'
#' @examples
#' \dontshow{
#' # this line is only for CRAN checks
#' tglkmeans.set_parallel(1)
#' }
#'
#' # create 5 clusters normally distributed around 1:5
#' d <- simulate_data(
#'     n = 100,
#'     sd = 0.3,
#'     nclust = 5,
#'     dims = 2,
#'     add_true_clust = FALSE,
#'     id_column = FALSE
#' )
#'
#' head(d)
#'
#' # cluster
#' km <- TGL_kmeans(d, k = 5, "euclid", verbose = TRUE)
#' names(km)
#' km$centers
#' head(km$cluster)
#' km$size
#' @seealso \code{\link{TGL_kmeans_tidy}}
#' @export
TGL_kmeans <- function(df,
                       k,
                       metric = "euclid",
                       max_iter = 40,
                       min_delta = 0.0001,
                       verbose = FALSE,
                       keep_log = FALSE,
                       id_column = FALSE,
                       reorder_func = "hclust",
                       hclust_intra_clusters = FALSE,
                       seed = NULL,
                       parallel = getOption("tglkmeans.parallel"),
                       use_cpp_random = FALSE) {
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
        hclust_intra_clusters = hclust_intra_clusters,
        parallel = parallel,
        use_cpp_random = use_cpp_random
    )


    km <- list()

    km$cluster <- res$cluster$clust
    if (id_column) {
        names(km$cluster) <- res$cluster[[colnames(df)[1]]]
    } else {
        names(km$cluster) <- res$cluster$id
    }

    km$centers <- as.matrix(res$centers[, -1])

    km$size <- tapply(km$clust, km$clust, length)

    if (keep_log) {
        if (verbose) {
            cli_warn("cannot keep log when {.field verbose=TRUE}")
        } else {
            km$log <- res$log
        }
    }

    if (hclust_intra_clusters) {
        km$order <- res$order$order
    }

    return(km)
}
