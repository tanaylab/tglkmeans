#ifndef REASSIGNWORKER_H
#define REASSIGNWORKER_H

#include <RcppParallel.h>
#include "KMeansCenterBase.h"
#include <vector>
#include <numeric>

// ReassignWorker uses parallelReduce to safely accumulate votes across threads.
// Each thread chunk gets its own copy via the split constructor, and results
// are merged via join() after parallel execution completes.
class ReassignWorker : public RcppParallel::Worker {
private:
    const std::vector<std::vector<float>>& data;
    std::vector<KMeansCenterBase*>& centers;
    std::vector<int>& assignment;
    std::vector<std::vector<float>> votes; // Per-chunk votes, merged via join()
    std::vector<int> changes; // Per-chunk change tracking, merged via join()

public:
    // Primary constructor
    ReassignWorker(const std::vector<std::vector<float>>& data,
                   std::vector<KMeansCenterBase*>& centers,
                   std::vector<int>& assignment);

    // Split constructor for parallelReduce - creates a new worker for a chunk
    ReassignWorker(const ReassignWorker& other, RcppParallel::Split);

    void operator()(std::size_t begin, std::size_t end) override;

    // Join results from another worker (called by parallelReduce)
    void join(const ReassignWorker& other);

    void apply_votes();

    size_t get_changes() const { 
        return std::accumulate(changes.begin(), changes.end(), 0);
    }
};

#endif // REASSIGNWORKER_H
