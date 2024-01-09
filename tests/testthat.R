library(testthat)
library(tglkmeans)
library(dplyr)
library(ggplot2)
library(purrr)
library(tgstat)


tglkmeans.set_parallel(1)
if (identical(Sys.getenv("NOT_CRAN"), "true")) {
    tglkmeans.set_parallel(parallel::detectCores())
}

test_check("tglkmeans")
