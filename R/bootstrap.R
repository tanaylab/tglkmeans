#' Bootstrapping
#'
#' @param df data frame. Each row is a single observation and each column is a dimension.
#' the first column can contain id for each observation (if id_column is TRUE).
#' @param k number of clusters
#' @param N_boot number of bootstrapping iterations
#' @param boot_ratio percent of observations to sample on each iteration
#' @param parallel run parallely (using doMC backend)
#' @param id_column \code{df}'s first column contains the observation id
#' @param ... additional parameters to TGL_kmeans
#'
#' @return list with the following components:
#' \describe{
#'   \item{coclust:}{NxN matrix (where N is the number of observations) with the number of times observation i and j occured in the same cluster.}
#'   \item{num_trials:}{NxN matrix with the number of times observation i and j where sampled together.}
#'   \item{coclust_frac:}{fraction of times observation i and j where clustered together out of the times they were sampled together (coclust matrix divided by num_trails matrix).}
#' }.
#'
#'
#' @export
#'
#' @examples
#' d <- simulate_data(nclust=6)
#' bootstrap <- bootstrap_kmeans(d, k=6, N_boot=100)
#' names(bootstrap)
#' bootstrap$coclust[1:5, 1:5]
#' bootstrap$num_trials[1:5, 1:5]
#' bootstrap$coclust_frac[1:5, 1:5]
#'
#' bootstrap_kmeans(d, k=6, N_boot=100, tidy=TRUE)
#'
#'
bootstrap_kmeans <- function(df, k, N_boot, boot_ratio=0.75, parallel=getOption('tglkmeans.parallel'), id_column=TRUE, ...){
    df <- tbl_df(df)
    N <- nrow(df)
    boot_size <- round(N * boot_ratio)

    if (id_column) {
        id_col <- df[[1]]
        df <- df[, -1]
    } else {
        id_col <- as.character(1:nrow(df))
    }

    df <- df %>% mutate(id = 1:n()) %>% select(id, everything())

    tot_coclust <- matrix(0, nrow=N, ncol=N, dimnames=list(id_col, id_col))
    num_trials <- matrix(0, nrow=N, ncol=N, dimnames=list(id_col, id_col))

    boot_res <- plyr::alply(1:N_boot, 1, function(i) {
        boot_obs <- sample(1:N, boot_size)
        km <- TGL_kmeans_tidy(df[boot_obs, ], k=k, id_column=TRUE, ...)
        boot_nodes <- as.numeric(km$clust$id)
        isclust_ci <- diag(max(km$clust$clust))[, km$clust$clust]
        coclust_ij <- t(isclust_ci) %*% isclust_ci

        return(list(boot_nodes=boot_nodes, coclust_ij=coclust_ij))
    }, .parallel = parallel)

    reduce_coclust(map(boot_res, 'boot_nodes'), map(boot_res, 'coclust_ij'), tot_coclust)
    reduce_num_trials(map(boot_res, 'boot_nodes'), num_trials)

    return(list(coclust = tot_coclust, num_trials=num_trials, coclust_frac = tot_coclust / num_trials))
}


#' Bootstrap clustering
#'
#' @param df data frame. Each row is a single observation and each column is a dimension. Input to \code{bootstrap_func} (first paramter).
#' @param N_boot number of bootstraps.
#' @param boot_ratio fraction of observations to sample in each bootstrap.
#' @param k_boot k to use in \code{bootstrap_func}(\code{k} parameter).
#' @param bootstrap_func function to use bootstrapping. Should take \code{df} as the first parameter, has the following parameters: \code{k}, \code{boot_ratio}, \code{N_boot}, and return a list with \code{coclust}, \code{num_trials} and \code{coclust_frac}.
#' @param max_k maximal k to test. if NULL, would be chosen as \code{floor(nrow(df) / 40)}
#' @param heatmap_plot_fn filename for coclust heatmap.
#' @param width width for heatmap plot.
#' @param height height for heatmap plot.
#' @param device device for heatmap plot (default \code{png}),
#' @param ... other paramters to \code{bootstrap_func}.
#'
#' @return list with the following components:
#' \describe{
#'   \item{mat:}{original \code{df}. NxM}
#'   \item{coclust:}{xN matrix with number of times item \code{i} was sampled with item \code{j} in the same cluster.}
#'   \item{num_trials:}{NxN matrix with number of times item \code{i} was sampled with item \code{j}.}
#'   \item{coclust_frac:}{NxN matrix with \code{coclust} / \code{num_trials}.}
#'   \item{cm:}{NxN correlation matrix.}
#'   \item{hc:}{hierachical clustering of \code{coclust_frac} matrix.}
#'   \item{coclust_score:}{tibble with score for each cluster in each k from 1 to \code{max_k}.}
#' }
#' @export
bootclust <- function(df, N_boot, boot_ratio=0.75, k_boot=NULL, bootstrap_func='bootstrap_kmeans', max_k = NULL, heatmap_plot_fn=NULL, width=700, height=700, device='png', ...){

    k_boot <- k_boot %||% floor(nrow(df) * boot_ratio / 130)
    max_k <- max_k %||% floor(nrow(df) / 40)

    message('bootstrapping')
    bt <- do.call(bootstrap_func, list(df, boot_ratio=boot_ratio, N_boot=N_boot, k = k_boot, ...))

    coclust_frac <- bt$coclust_frac
    coclust <- bt$coclust
    num_trials <- bt$num_trials

    message('clustering bootstrapping results')
    cm <- cor(coclust_frac, use='pairwise.complete.obs', method='spearman')
    hc <- hclust(dist(cm), 'ward.D2')

    coclust_tidy <- reshape2::melt(coclust, varnames=c('i', 'j'), value.name='coclust') %>% as_tibble()
    num_trials_tidy <- reshape2::melt(num_trials, varnames=c('i', 'j'), value.name='num_trials') %>% as_tibble()
    coclust_tidy <- coclust_tidy %>% mutate(num_trials = num_trials_tidy$num_trials) %>% mutate(i = as.character(i), j = as.character(j))

    score_clust <- function(clusters){
        coclust_tidy %>%
            left_join(tibble(i = names(clusters), clust=clusters), by='i') %>%
            left_join(tibble(j = names(clusters), clust_j=clusters), by='j') %>%
            mutate(coclust_score = coclust / num_trials) %>%
            group_by(i, clust) %>%
            summarise(same_clust = sum(coclust_score[clust == clust_j]),
                      diff_clust = sum(coclust_score[clust != clust_j]),
                      score = same_clust / (same_clust + diff_clust)) %>%
            ungroup()
    }

    message('calculating score for each k')
    coclust_score <- plyr::adply(cutree(hc, 2:max_k), 2, score_clust, .parallel=getOption('tglkmeans.parallel'), .id='k') %>% tbl_df()

    shades <- colorRampPalette(rev(RColorBrewer::brewer.pal(11,"RdBu")))(1000)

    if (!is.null(heatmap_plot_fn)){
        do.call(device, list(heatmap_plot_fn, width=width, height=height))
    }

    pheatmap::pheatmap(coclust_frac,
                       col=shades,
                       cluster_rows=hc,
                       cluster_cols=hc,
                       show_rownames=FALSE,
                       show_colnames=FALSE)

    if (!is.null(heatmap_plot_fn)){
        dev.off()
    }

    res <- list(mat = df,
                coclust=coclust,
                num_trials=num_trials,
                coclust_frac=coclust_frac,
                cm=cm,
                hc=hc,
                coclust_score=coclust_score)
    return(res)

}

#' Plot co-clustering score for different choices of k
#'
#' @param coclust_score \code{bt$coclust_score}) where \code{bt} was returned from \code{bootclust}
#' @param ks k values to plot
#' @param fig_fn filename of the output figure. if NULL figure would be plotted to the screen
#' @param ... additional paramters to \code{ggplot2::ggsave}
#'
#' @return ggplot object with the densities of k
#' @export
#'
#' @examples
plot_coclust_score <- function(coclust_score, ks = c(2,4,5,6,10,15), fig_fn=NULL, ...){
    ggp <- coclust_score %>%
        filter(k %in% ks) %>%
        group_by(k, clust) %>%
        filter(n() >= 2) %>%
        ggplot(aes(y=factor(clust), x=score)) +
            ggjoy::geom_joy() +
            ylab('Cluster') +
            facet_wrap(~k) +
            theme_minimal()
    if (!is.null(fig_fn)){
        ggsave(fig_fn, ...)
    }
    ggp
}

#' Plot co-clustering matrix
#'
#' @param bt output of \code{bootclust}
#' @param col color pallete
#'
#' @return None
#' @export
plot_coclust_mat <- function(bt,
                             col = colorRampPalette(rev(RColorBrewer::brewer.pal(11,"RdBu")))(1000),
                             ...){
    ord <- bt$clust %>%
        arrange(clust) %>%
        group_by(clust) %>%
        mutate(index = index[hclust(dist(bt$coclust_frac[index, index]), 'ward.D2')$order]) %>%
        pull(index)
    pheatmap::pheatmap(
        bt$coclust_frac[ord, ord],
        cluster_rows = FALSE,
        cluster_cols = FALSE,
        show_rownames = FALSE,
        show_colnames = FALSE,
        col = col,
        annotation_row = data.frame(cluster = bt$clust$clust),
        annotation_col = data.frame(cluster = bt$clust$clust),
        ...
    )
}

#' Cutree of bootstrap clustering
#'
#' @param bt output of \code{bootclust}
#' @param k an integer scalar or vector with the desired number of groups
#' @param min_coclust minimal co-clust score for observation in a cluster
#' @param tidy  tidy output
#'
#' @return if \code{tidy == TRUE}: \code{bt} with the following aditional fields:
#' \describe{
#'   \item{clust:}{tibble with `id` column with the observation id (`1:n` if no id column was supplied), and `clust` column with the observation assigned cluster.}
#'   \item{centers:}{tibble with `clust` column and the cluster centers.}
#'   \item{size:}{tibble with `clust` column and `n` column with the number of points in each cluster.}
#'   \item{score:}{}
#' }
#' if \code{tidy == FALSE}: \code{bt} with the following aditional fields:
#' \describe{
#'   \item{cluster:}{A vector of integers (from ‘1:k’) indicating the cluster to which each point is allocated.}
#'   \item{centers:}{A matrix of cluster centres.}
#'   \item{size:}{The number of points in each cluster.}
#'   \item{score:}{}
#' }
#' @export
#'
cutree_bootclust <- function(bt, k, min_coclust = 0.5, tidy=FALSE){
    bt$clust <- cutree(bt$hc, k)

    clust_inds <- map(unique(bt$clust), ~ {
        inds <- which(bt$clust == .x)
        obs_score <-  apply(bt$coclust[inds, inds], 1, sum, na.rm=TRUE) / apply(bt$num_trials[inds, inds], 1, sum, na.rm=TRUE)
        good_inds <- tibble(index = inds[which(obs_score >= min_coclust)]) %>% mutate(clust = .x)
        bad_inds <- tibble(index = inds[which(obs_score < min_coclust)]) %>% mutate(clust = .x)

        list(good_inds=good_inds, bad_inds=bad_inds, score=tibble(id=inds, score=obs_score))
    })

    if (min_coclust > 0){
        excluded <- map_df(clust_inds, 'bad_inds') %>% select(clust, index)
        new_clust <- map_df(clust_inds, 'good_inds') %>% select(clust, index)
        bt$excluded <- excluded$index
        new_clust <- bind_rows(new_clust, excluded %>% mutate(clust = max(new_clust$clust) + 1))
        new_clust <- new_clust %>%
            mutate(clust = factor(clust),
                   clust = forcats::lvls_revalue(clust, as.character(1:length(unique(clust)))))
    } else {
        new_clust <- tibble(clust = bt$clust, index=1:length(bt$clust))
    }

    bt$clust <- new_clust %>% arrange(index)

    bt$centers <- bt$mat %>% mutate(clust = bt$clust$clust) %>% group_by(clust) %>% summarise_all(mean, na.rm=TRUE)

    bt$size <- bt$clust %>% count(clust) %>% ungroup()

    bt$score <- clust_inds %>% map_df('score') %>% arrange(id)

    if (!tidy){
        bt$cluster <- bt$clust %>% pull(clust)
        bt$centers <- bt$centers %>% select(-clust)
        bt$size <- tapply(bt$clust, bt$clust, length)
        bt$score <- bt$score %>% pull(score)
    }

    return(bt)
}

`%||%` <- function(lhs, rhs) {
    if (!is.null(lhs)) { lhs } else { rhs }
}
