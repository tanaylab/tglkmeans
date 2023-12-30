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

// [[Rcpp::export]]
Rcpp::S4 rcpp_downsample_sparse(Rcpp::S4 matrix, int samples, unsigned int random_seed) {
    // Extract components of the dgCMatrix
    Rcpp::IntegerVector i = matrix.slot("i");
    Rcpp::IntegerVector p = matrix.slot("p");
    Rcpp::IntegerVector x = matrix.slot("x");

    int nrows = Rcpp::as<Rcpp::IntegerVector>(matrix.slot("Dim"))[0];
    int ncols = Rcpp::as<Rcpp::IntegerVector>(matrix.slot("Dim"))[1];

    // Prepare output vector
    Rcpp::IntegerVector out_x(x.size());

    // Create and run the DownsampleWorkerSparse
    DownsampleWorkerSparse worker(i, p, x, out_x, samples, random_seed);
    RcppParallel::parallelFor(0, ncols, worker);

    // Create a new dgCMatrix object for the output
    Rcpp::S4 out_matrix("dgCMatrix");
    out_matrix.slot("i") = i;
    out_matrix.slot("p") = p;    
    Rcpp::NumericVector out_x_double = Rcpp::as<Rcpp::NumericVector>(out_x);
    out_matrix.slot("x") = out_x_double;
    out_matrix.slot("Dim") = Rcpp::IntegerVector::create(nrows, ncols);

    return out_matrix;
}