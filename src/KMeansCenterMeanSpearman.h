//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANSCENTERMEANSPEARMAN_H
#define TGLKMEANS_KMEANSCENTERMEANSPEARMAN_H

#include <list>
#include "KMeansCenterMean.h"

class KMeansCenterMeanSpearman : public KMeansCenterMean {
protected:
    // Cached center ranks for performance optimization
    // These are pre-computed when center is updated and used when data has no missing values
    vector<float> m_center_ranks;
    std::list<int> m_center_sorted_order;
    
public:
    KMeansCenterMeanSpearman(int dim) :
		    KMeansCenterMean(dim),
            m_center_ranks(dim)
    {}

    virtual float dist(const vector<float> &v) const;
    virtual void update_center_stats() override;
};


#endif //TGLKMEANS_KMEANSCENTERMEANSPEARMAN_H
