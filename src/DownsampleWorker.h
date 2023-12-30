#ifndef DOWNSAMPLEWORKER_H
#define DOWNSAMPLEWORKER_H

#include <Rcpp.h>
#include <RcppParallel.h>
#include <vector>

class DownsampleWorker : public RcppParallel::Worker {
private:
    RcppParallel::RMatrix<int> input_matrix;
    RcppParallel::RMatrix<int> output_matrix;
    int samples;
    unsigned int random_seed;

public:    
    DownsampleWorker(const Rcpp::IntegerMatrix& input, Rcpp::IntegerMatrix& output, int samples, unsigned int random_seed);

    // Parallel operator
    void operator()(std::size_t begin, std::size_t end) override;
};

class DownsampleWorkerSparse : public RcppParallel::Worker {
private:
    Rcpp::IntegerVector input_i;
    Rcpp::IntegerVector input_p;
    Rcpp::IntegerVector input_x;
    Rcpp::IntegerVector output_x;
    int samples;
    unsigned int random_seed;

public:
    DownsampleWorkerSparse(const Rcpp::IntegerVector& i, const Rcpp::IntegerVector& p, const Rcpp::IntegerVector& x, 
                           Rcpp::IntegerVector& out_x, int samples, unsigned int random_seed);

    // Parallel operator
    void operator()(std::size_t begin, std::size_t end) override;
};


#endif // DOWNSAMPLEWORKER_H
