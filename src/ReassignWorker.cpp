#include "ReassignWorker.h"
#include <limits>

// Primary constructor
ReassignWorker::ReassignWorker(const std::vector<std::vector<float>>& data,
                               std::vector<KMeansCenterBase*>& centers,
                               std::vector<int>& assignment)
    : data(data), centers(centers), assignment(assignment), changes(0) {}

// Split constructor for parallelReduce.
// data/centers/assignment are shared by reference; only the change counter is
// per-chunk and merged back via join().
ReassignWorker::ReassignWorker(const ReassignWorker& other, RcppParallel::Split)
    : data(other.data), centers(other.centers), assignment(other.assignment), changes(0) {}

void ReassignWorker::operator()(std::size_t begin, std::size_t end) {
    for (std::size_t i = begin; i < end; i++) {
        int best_id_i = -1;
        float best_dist = std::numeric_limits<float>::max();

        // Determine the closest center
        for (size_t j = 0; j < centers.size(); j++) {
            float dist = centers[j]->dist(data[i]);
            if (dist < best_dist) {
                best_dist = dist;
                best_id_i = j;
            }
        }

        if (best_id_i == -1) {
            // Data point has all missing values - assign to cluster 0 arbitrarily
            best_id_i = 0;
        }

        // Each index is owned by a single chunk, so this write is race-free.
        if (assignment[i] != best_id_i) {
            assignment[i] = best_id_i;
            changes++;
        }
    }
}

// Merge change counts from another chunk (called by parallelReduce)
void ReassignWorker::join(const ReassignWorker& other) {
    changes += other.changes;
}

void ReassignWorker::apply_votes() {
    // Single O(N) pass in ascending index order. Each center therefore receives
    // its members in the same order a serial implementation would use, so the
    // accumulated means are identical regardless of how the range was split.
    for (size_t j = 0; j < data.size(); j++) {
        centers[assignment[j]]->vote(data[j], 1);
    }
}
