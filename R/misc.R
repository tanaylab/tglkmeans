#' Set parallel threads
#'
#' @param thread_num number of threads. use '1' for non parallel behavior
#'
#' @return None
#'
#' @examples
#' \donttest{
#' tglkmeans.set_parallel(8)
#' }
#' @export
tglkmeans.set_parallel <- function(thread_num) {
    if (thread_num <= 1) {
        options(tglkmeans.parallel = FALSE)
    } else {
        doFuture::registerDoFuture()
        future::plan(future::multicore, workers = thread_num)
        options(tglkmeans.parallel = TRUE)
        options(tglkmeans.parallel.thread_num = thread_num)
    }
}
