#include <vector>
#include <Rcpp.h>
#include <RcppParallel.h>
#include "DownsampleWorker.h"

typedef float float32_t;
typedef double float64_t;
typedef unsigned char uint8_t;
typedef unsigned int uint_t;

// [[Rcpp::export]]
Rcpp::IntegerMatrix downsample_matrix_cpp(Rcpp::IntegerMatrix input, int samples, unsigned int random_seed) {
    Rcpp::IntegerMatrix output(input.nrow(), input.ncol());

    DownsampleWorker worker(input, output, samples, random_seed);
    RcppParallel::parallelFor(0, input.ncol(), worker);

    return output;
}
