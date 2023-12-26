#include "ReassignWorker.h"

ReassignWorker::ReassignWorker(const std::vector<std::vector<float>>& data,
                               std::vector<KMeansCenterBase*>& centers,
                               std::vector<int>& assignment)
    : data(data), centers(centers), assignment(assignment), changes(0) {
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
            throw std::logic_error("No valid center found for data point.");
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

void ReassignWorker::apply_votes() {
    for (size_t i = 0; i < centers.size(); i++) {
        for (size_t j = 0; j < data.size(); j++) {
            if (votes[i][j] > 0) {
                centers[i]->vote(data[j], votes[i][j]);
            }
        }
    }
}
