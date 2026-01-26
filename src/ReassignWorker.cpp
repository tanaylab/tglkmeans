#include "ReassignWorker.h"

// Primary constructor
ReassignWorker::ReassignWorker(const std::vector<std::vector<float>>& data,
                               std::vector<KMeansCenterBase*>& centers,
                               std::vector<int>& assignment)
    : data(data), centers(centers), assignment(assignment) {
    votes.resize(centers.size());
    for (auto& v : votes) {
        v.resize(data.size(), 0);
    }
    changes.resize(data.size(), 0);
}

// Split constructor for parallelReduce
// Creates a new worker with its own vote/change storage that will be merged later
ReassignWorker::ReassignWorker(const ReassignWorker& other, RcppParallel::Split)
    : data(other.data), centers(other.centers), assignment(other.assignment) {
    votes.resize(centers.size());
    for (auto& v : votes) {
        v.resize(data.size(), 0);
    }
    changes.resize(data.size(), 0);
}

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

        // Accumulate vote
        votes[best_id_i][i] = 1;

        // Track changes in assignments
        if (assignment[i] != best_id_i) {
            assignment[i] = best_id_i;
            changes[i]++;
        }
    }
}

// Join results from another worker into this one
// Called by parallelReduce to merge results from different chunks
void ReassignWorker::join(const ReassignWorker& other) {
    // Merge votes: since each data point is processed by exactly one chunk,
    // we can simply add the votes (one will be 0, the other will be 0 or 1)
    for (size_t i = 0; i < votes.size(); i++) {
        for (size_t j = 0; j < votes[i].size(); j++) {
            votes[i][j] += other.votes[i][j];
        }
    }
    
    // Merge change counts
    for (size_t i = 0; i < changes.size(); i++) {
        changes[i] += other.changes[i];
    }
}

void ReassignWorker::apply_votes() {
    for (size_t i = 0; i < centers.size(); i++) {
        for (size_t j = 0; j < data.size(); j++) {
            if (votes[i][j] > 0) {
                centers[i]->vote(data[j], votes[i][j]);
            }
        }
    }
}
