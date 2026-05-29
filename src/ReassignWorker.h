#ifndef REASSIGNWORKER_H
#define REASSIGNWORKER_H

#include <RcppParallel.h>
#include "KMeansCenterBase.h"
#include <vector>
#include <cstddef>

// ReassignWorker assigns each observation to its nearest center.
//
// The assignment vector is shared (by reference) across all parallelReduce
// split copies, and each observation index is processed by exactly one chunk,
// so assignments are written in place without races - no per-chunk vote buffer
// is needed. parallelReduce is used only to merge the scalar change counter via
// join(). Votes are applied to the centers in a single O(N) pass (apply_votes)
// after the parallel phase, in ascending index order so the floating-point
// accumulation matches a serial run exactly.
class ReassignWorker : public RcppParallel::Worker {
private:
    const std::vector<std::vector<float>>& data;
    std::vector<KMeansCenterBase*>& centers;
    std::vector<int>& assignment;
    std::size_t changes;

public:
    // Primary constructor
    ReassignWorker(const std::vector<std::vector<float>>& data,
                   std::vector<KMeansCenterBase*>& centers,
                   std::vector<int>& assignment);

    // Split constructor for parallelReduce - shares data/centers/assignment
    ReassignWorker(const ReassignWorker& other, RcppParallel::Split);

    void operator()(std::size_t begin, std::size_t end) override;

    // Merge the change counter from another chunk (called by parallelReduce)
    void join(const ReassignWorker& other);

    void apply_votes();

    std::size_t get_changes() const { return changes; }
};

#endif // REASSIGNWORKER_H
