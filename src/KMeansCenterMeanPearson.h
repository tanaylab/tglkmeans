//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANSCENTERMEANPEARSON_H
#define TGLKMEANS_KMEANSCENTERMEANPEARSON_H


#include "KMeansCenterMean.h"

class KMeansCenterMeanPearson : public KMeansCenterMean {

protected:

    float m_center_e;
    float m_center_v;

public:
    KMeansCenterMeanPearson(int dim) :
            KMeansCenterMean(dim) {}

    virtual float dist(const vector<float> &v);

    virtual void update_center_stats();
};


#endif //TGLKMEANS_KMEANSCENTERMEANPEARSON_H
