#' Set parallel threads
#'
#' @param thread_num number of threads. use '1' for non parallel behavior
#'
#' @return No return value, called for side effects.
#'
#' @examples
#' \donttest{
#' tglkmeans.set_parallel(8)
#' }
#' @export
tglkmeans.set_parallel <- function(thread_num) {
    if (thread_num <= 1) {
        options(tglkmeans.parallel = FALSE)
        RcppParallel::setThreadOptions(numThreads = 1)
    } else {
        options(tglkmeans.parallel = TRUE)
        options(tglkmeans.parallel.thread_num = thread_num)
        RcppParallel::setThreadOptions(numThreads = thread_num)
    }
}

# Number of threads to configure by default on load. Uses ~75% of the available
# cores, but caps at 2 when running under R CMD check (which sets
# _R_CHECK_LIMIT_CORES_) so the package never grabs more than CRAN allows.
tglkmeans_default_threads <- function(n_cores = parallel::detectCores(),
                                      limit_cores = check_limits_cores()) {
    if (is.na(n_cores)) {
        n_cores <- 1L
    }
    if (limit_cores) {
        as.integer(min(2L, n_cores))
    } else {
        as.integer(max(1L, round(n_cores * 0.75)))
    }
}

check_limits_cores <- function() {
    chk <- tolower(Sys.getenv("_R_CHECK_LIMIT_CORES_", ""))
    nzchar(chk) && chk != "false"
}
