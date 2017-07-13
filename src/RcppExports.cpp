// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// TGL_kmeans_cpp
List TGL_kmeans_cpp(const StringVector& ids, DataFrame& mat, const int& k, const String& metric, const double& max_iter, const double& min_delta, const bool& random_seed, const int& seed);
RcppExport SEXP tglkmeans_TGL_kmeans_cpp(SEXP idsSEXP, SEXP matSEXP, SEXP kSEXP, SEXP metricSEXP, SEXP max_iterSEXP, SEXP min_deltaSEXP, SEXP random_seedSEXP, SEXP seedSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const StringVector& >::type ids(idsSEXP);
    Rcpp::traits::input_parameter< DataFrame& >::type mat(matSEXP);
    Rcpp::traits::input_parameter< const int& >::type k(kSEXP);
    Rcpp::traits::input_parameter< const String& >::type metric(metricSEXP);
    Rcpp::traits::input_parameter< const double& >::type max_iter(max_iterSEXP);
    Rcpp::traits::input_parameter< const double& >::type min_delta(min_deltaSEXP);
    Rcpp::traits::input_parameter< const bool& >::type random_seed(random_seedSEXP);
    Rcpp::traits::input_parameter< const int& >::type seed(seedSEXP);
    rcpp_result_gen = Rcpp::wrap(TGL_kmeans_cpp(ids, mat, k, metric, max_iter, min_delta, random_seed, seed));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"tglkmeans_TGL_kmeans_cpp", (DL_FUNC) &tglkmeans_TGL_kmeans_cpp, 8},
    {NULL, NULL, 0}
};

RcppExport void R_init_tglkmeans(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
