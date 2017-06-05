//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANSCENTERMEANEUCLID_H
#define TGLKMEANS_KMEANSCENTERMEANEUCLID_H


#include "KMeansCenterMean.h"

class KMeansCenterMeanEuclid  : public KMeansCenterMean {
public:
    KMeansCenterMeanEuclid(int dim) :
            KMeansCenterMean(dim)
    {}
    virtual float dist(const vector<float> &v);
};


#endif //TGLKMEANS_KMEANSCENTERMEANEUCLID_H
