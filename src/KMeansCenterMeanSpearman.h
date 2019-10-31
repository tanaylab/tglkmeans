//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANSCENTERMEANSPEARMAN_H
#define TGLKMEANS_KMEANSCENTERMEANSPEARMAN_H


#include "KMeansCenterMean.h"

class KMeansCenterMeanSpearman : public KMeansCenterMean {
protected:
    vector<float> m_rank1;
    vector<float> m_rank2;
public:
    KMeansCenterMeanSpearman(int dim) :
		    KMeansCenterMean(dim),
            m_rank1(dim),
            m_rank2(dim)           
    {}

    virtual float dist(const vector<float> &v);
};


#endif //TGLKMEANS_KMEANSCENTERMEANSPEARMAN_H
