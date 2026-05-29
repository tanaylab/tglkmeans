//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANSCENTERMEANSPEARMAN_H
#define TGLKMEANS_KMEANSCENTERMEANSPEARMAN_H

#include "KMeansCenterMean.h"

class KMeansCenterMeanSpearman : public KMeansCenterMean {
public:
    KMeansCenterMeanSpearman(int dim) :
		    KMeansCenterMean(dim)
    {}

    virtual float dist(const std::vector<float> &v) const override;
};


#endif //TGLKMEANS_KMEANSCENTERMEANSPEARMAN_H
