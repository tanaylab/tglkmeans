#ifndef UPDATEMINDISTANCEWORKER_H
#define UPDATEMINDISTANCEWORKER_H

// [[Rcpp::depends(RcppParallel)]]
#include <RcppParallel.h>
#include "KMeansCenterBase.h"
#include <vector>

class UpdateMinDistanceWorker : public RcppParallel::Worker {
private:
    const std::vector<std::vector<float>>& data;
    KMeansCenterBase* new_center;
    std::vector<std::pair<float, int>>& min_dist;
    const std::vector<int>& assignment;

public:
    UpdateMinDistanceWorker(const std::vector<std::vector<float>>& data,
                            KMeansCenterBase* new_center,
                            std::vector<std::pair<float, int>>& min_dist,
                            const std::vector<int>& assignment);

    void operator()(std::size_t begin, std::size_t end);
};

#endif // UPDATEMINDISTANCEWORKER_H
