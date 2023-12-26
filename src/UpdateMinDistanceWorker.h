#ifndef UPDATEMINDISTANCEWORKER_H
#define UPDATEMINDISTANCEWORKER_H

// [[Rcpp::depends(RcppParallel)]]
#include <RcppParallel.h>
#include "KMeansCenterBase.h"
#include <vector>

using namespace std;

class UpdateMinDistanceWorker : public RcppParallel::Worker {
private:
    const vector<vector<float>>& data;
    vector<KMeansCenterBase*>& centers;
    vector<pair<float, int>>& min_dist;
    const vector<int>& assignment;
    const int& cur_k;

public:
    UpdateMinDistanceWorker(const vector<vector<float>>& data, 
                            vector<KMeansCenterBase*>& centers, 
                            vector<pair<float, int>>& min_dist, 
                            const vector<int>& assignment,
                            const int& cur_k);

    void operator()(std::size_t begin, std::size_t end);

    void prepare_min_dist(vector<pair<float, int>>& min_dist);
};

#endif // UPDATEMINDISTANCEWORKER_H
