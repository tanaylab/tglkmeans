//
// Created by aviezerl on 6/5/17.
//

// [[Rcpp::plugins("cpp11")]]

#include <Rcpp.h>
#include "KMeans.h"
#include "KMeansCenterMeanEuclid.h"
#include "KMeansCenterMeanPearson.h"
#include "KMeansCenterMeanSpearman.h"
#include "Random.h"

using namespace Rcpp;
using namespace std;

void vec2df(const vector<vector<float > >& vec, DataFrame& df){
    unsigned long nc = vec.size();
    List list( nc );

    for( int j=0; j<nc; j++){
        list[j] = wrap( vec[j].begin(), vec[j].end() );
    }

    df = list;
}

void replace_na(DataFrame& df){
    for(int i=0; i < df.ncol(); ++i){
        NumericVector col = df[i];
        for (int j=0; j < col.length(); ++j){
            if (NumericVector::is_na(col[j])){
                col[j] = REAL_MAX;
            }
        }
    }
}

void real_max_to_na(DataFrame& df){
    for(int i=0; i < df.ncol(); ++i){
        NumericVector col = df[i];
        for (int j=0; j < col.length(); ++j){
            if (col[j] == REAL_MAX){
                col[j] = NumericVector::get_na();
            }
        }
    }
}

// [[Rcpp::export]]
List TGL_kmeans_cpp(const StringVector& ids, DataFrame& mat, const int& k, const String& metric, const double& max_iter=40, const double& min_delta=0.0001, const bool& random_seed=true, const int& seed=-1){

    if (!random_seed){
        Random::seed(seed);
    }

    replace_na(mat);

    vector<vector<float> > data = as<vector<vector<float> > >(mat);

    int dim = data[0].size();
    vector<KMeansCenterBase *> centers(k);

    if (metric == "euclid") {
        for (int i = 0; i < k; i++) {
            centers[i] = new KMeansCenterMeanEuclid(dim);
        }
    } else if (metric == "pearson") {
        for (int i = 0; i < k; i++) {
            centers[i] = new KMeansCenterMeanPearson(dim);
        }
    } else if (metric == "spearman") {
        for (int i = 0; i < k; i++) {
            centers[i] = new KMeansCenterMeanSpearman(dim);
        }
    } else {
        stop("possible metrics are 'euclid', 'pearson' and 'spearman'");
    }

    KMeans kmeans(data, k, centers);

    kmeans.cluster(max_iter, min_delta);

    vector<vector<float> > centers_float;
    kmeans.report_centers_to_vector(centers_float);
    DataFrame centers_df;
    vec2df(centers_float, centers_df);

    real_max_to_na(centers_df);

    vector<int> assignments = kmeans.report_assignment_to_vector();
    DataFrame clust_df = DataFrame::create( Named("id") = ids, _["clust"] = NumericVector::import(assignments.begin(), assignments.end()), _["stringsAsFactors"] = false);

    List res = List::create(Named("centers") = centers_df, _["cluster"] = clust_df);

    return(res);
}
