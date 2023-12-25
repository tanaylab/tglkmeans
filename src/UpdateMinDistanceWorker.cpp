#include "UpdateMinDistanceWorker.h"

UpdateMinDistanceWorker::UpdateMinDistanceWorker(const vector<vector<float>>& data, 
                                                 vector<KMeansCenterBase*>& centers, 
                                                 vector<pair<float, int>>& min_dist, 
                                                 int cur_k) 
    : data(data), centers(centers), min_dist(min_dist), cur_k(cur_k) {}

void UpdateMinDistanceWorker::operator()(std::size_t begin, std::size_t end) {
    for (std::size_t i = begin; i < end; ++i) {
        float best_dist = REAL_MAX;
        int id_i = 0;
        for (auto cent_i = centers.begin(); id_i < cur_k; cent_i++) {
            float dist = (*cent_i)->dist(data[i]);
            if (dist < best_dist) {
                best_dist = dist;
            }
            id_i++;
        }
        min_dist[i] = std::make_pair(best_dist, i);
    }    
}
