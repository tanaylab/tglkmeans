#include "UpdateMinDistanceWorker.h"

UpdateMinDistanceWorker::UpdateMinDistanceWorker(const vector<vector<float>>& data,
                                                 KMeansCenterBase* new_center,
                                                 vector<pair<float, int>>& min_dist,
                                                 const vector<int>& assignment)
    : data(data), new_center(new_center), min_dist(min_dist), assignment(assignment) {}

void UpdateMinDistanceWorker::operator()(std::size_t begin, std::size_t end) {
    for (std::size_t i = begin; i < end; ++i) {
        if (assignment[i] != -1) {
            // Mark assigned points with sentinel (below any valid distance including negative correlations)
            min_dist[i] = std::make_pair(-REAL_MAX, (int)i);
            continue;
        }

        // Incremental: only check distance to NEW center
        float dist = new_center->dist(data[i]);

        // Update only if new center is closer
        if (dist < min_dist[i].first) {
            min_dist[i] = std::make_pair(dist, (int)i);
        }
    }
}
