#' Set parallel threads
#'
#' @param thread_num number of threads. use '1' for non parallel behaviour
#'
#' @return None
#'
#' @examples
#' tglkmeans.set_parallel(8)
#' @export
tglkmeans.set_parallel <- function(thread_num) {
    if (1 == thread_num) {
        options(tglkmeans.parallel = FALSE)
    } else {
        doMC::registerDoMC(thread_num)
        options(tglkmeans.parallel = TRUE)
        options(tglkmeans.parallel.thread_num = thread_num)
    }
}
