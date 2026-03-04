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

    virtual float dist(const std::vector<float> &v) const override;

    virtual void update_center_stats() override;
};


#endif //TGLKMEANS_KMEANSCENTERMEANPEARSON_H
