//
// Parallel worker for add_new_core distance calculations
//

#ifndef ADDCOREWORKER_H
#define ADDCOREWORKER_H

#include <RcppParallel.h>
#include "KMeansCenterBase.h"
#include <vector>

using namespace std;

class AddCoreWorker : public RcppParallel::Worker {
private:
    const vector<vector<float>>& data;
    KMeansCenterBase* center;
    const vector<int>& assignment;
    vector<pair<float, int>>& core_dist;

public:
    AddCoreWorker(const vector<vector<float>>& data,
                  KMeansCenterBase* center,
                  const vector<int>& assignment,
                  vector<pair<float, int>>& core_dist)
        : data(data), center(center), assignment(assignment), core_dist(core_dist) {}

    void operator()(std::size_t begin, std::size_t end) {
        for (std::size_t i = begin; i < end; i++) {
            if (assignment[i] == -1) {
                float dist = center->dist(data[i]);
                core_dist[i] = make_pair(dist, (int)i);
            } else {
                // Assigned points get max distance (sorted to end)
                core_dist[i] = make_pair(REAL_MAX, (int)i);
            }
        }
    }
};

#endif // ADDCOREWORKER_H
