#ifndef REASSIGNWORKER_H
#define REASSIGNWORKER_H

#include <RcppParallel.h>
#include "KMeansCenterBase.h"
#include <vector>
#include <numeric>

class ReassignWorker : public RcppParallel::Worker {
private:
    const std::vector<std::vector<float>>& data;
    std::vector<KMeansCenterBase*>& centers;
    std::vector<int>& assignment;
    std::vector<std::vector<float>> votes; // Thread-safe structure for votes
    std::vector<int> changes; // To track changes in assignments

public:
    ReassignWorker(const std::vector<std::vector<float>>& data,
                   std::vector<KMeansCenterBase*>& centers,
                   std::vector<int>& assignment);

    void operator()(std::size_t begin, std::size_t end) override;

    void apply_votes();

    size_t get_changes() const { 
        return std::accumulate(changes.begin(), changes.end(), 0);
    }
};

#endif // REASSIGNWORKER_H
