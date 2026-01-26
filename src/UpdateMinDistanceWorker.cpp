#include "UpdateMinDistanceWorker.h"

UpdateMinDistanceWorker::UpdateMinDistanceWorker(const vector<vector<float>>& data, 
                                                 vector<KMeansCenterBase*>& centers, 
                                                 vector<pair<float, int>>& min_dist, 
                                                 const vector<int>& assignment,
                                                 const int& cur_k) 
    : data(data), centers(centers), min_dist(min_dist), assignment(assignment), cur_k(cur_k) {}

void UpdateMinDistanceWorker::operator()(std::size_t begin, std::size_t end) {
    for (std::size_t i = begin; i < end; ++i) {
        if (assignment[i] != -1) {
            // Use -REAL_MAX sentinel for assigned points (below any valid distance including negative correlations)
            min_dist[i] = std::make_pair(-REAL_MAX, i);
            continue;
        }
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

void UpdateMinDistanceWorker::prepare_min_dist(vector<pair<float, int>>& min_dist) {
    // Remove assigned points (marked with -REAL_MAX), but keep points with valid distances
    // Note: distances can be negative for correlation metrics, so we use -REAL_MAX as sentinel
    min_dist.erase(std::remove_if(min_dist.begin(), min_dist.end(),
        [](const std::pair<float, int>& p) { return p.first == -REAL_MAX; }), min_dist.end());
}
