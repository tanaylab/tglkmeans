
#' Simulate normal data for kmeans tests
#'
#' Creates \code{nclust} clusters normally distributed around \code{1:nclust}
#'
#' @param n number of observations per cluster
#' @param sd sd
#' @param nclust number of clusters
#' @param dims number of dimensions
#' @param frac_na fraction of NA in the first dimension
#' @param add_true_clust add a column with the true cluster ids
#'
#' @return simulated data
#' @export
#'
#' @examples
#' simulate_data(n = 100, sd = 0.3, nclust = 5, dims = 2)
#'
#' # add 20% missing data
#' simulate_data(n = 100, sd = 0.3, nclust = 5, dims = 2, frac_na = 0.2)
simulate_data <- function(n = 100, sd = 0.3, nclust = 30, dims = 2, frac_na = NULL, add_true_clust = TRUE) {
    data <- purrr::map_dfr(1:nclust, ~
        as.data.frame(matrix(rnorm(n * dims, mean = .x, sd = sd), ncol = dims)) %>%
            mutate(true_clust = .x)) %>%
        as_tibble() %>%
        mutate(id = 1:n()) %>%
        select(id, everything(), true_clust)
    if (!is.null(frac_na)) {
        data$V1[sample(1:nrow(data), round(nrow(data) * frac_na))] <- NA
    }

    if (!add_true_clust) {
        data <- data %>% select(-true_clust)
    }
    return(as.data.frame(data))
}

match_clusters <- function(data, res, nclust) {
    d <- data %>% left_join(res$clust %>% mutate(id = as.numeric(as.character(id))), by = "id")
    clust_map <- d %>%
        group_by(clust, true_clust) %>%
        summarise(n = n()) %>%
        top_n(1, n) %>%
        ungroup()
    d <- d %>% left_join(clust_map %>% select(new_clust = true_clust, clust), by = "clust")
    return(d)
}

test_clustering <- function(n, sd, nclust, dims = 2, method = "euclid", frac_na = NULL) {
    data <- simulate_data(n = n, sd = sd, nclust = nclust, dims = dims)
    res <- TGL_kmeans_tidy(data %>% select(id, starts_with("V")), nclust, method, verbose = FALSE)
    mres <- match_clusters(data, res, nclust)
    frac_success <- sum(mres$true_clust == mres$new_clust, na.rm = TRUE) / sum(!is.na(mres$new_clust))
    return(frac_success)
}
