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
    KMeansCenterBase* new_center;
    vector<pair<float, int>>& min_dist;
    const vector<int>& assignment;

public:
    UpdateMinDistanceWorker(const vector<vector<float>>& data,
                            KMeansCenterBase* new_center,
                            vector<pair<float, int>>& min_dist,
                            const vector<int>& assignment);

    void operator()(std::size_t begin, std::size_t end);
};

#endif // UPDATEMINDISTANCEWORKER_H
