library(testthat)
library(tglkmeans)
library(dplyr)
library(ggplot2)
library(purrr)
library(tgstat)

# Set the number of threads to 1 for testing on CRAN
if (identical(Sys.getenv("NOT_CRAN"), "false")) {
    tglkmeans.set_parallel(1)
}

test_check("tglkmeans")
