//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANSCENTERMEAN_H
#define TGLKMEANS_KMEANSCENTERMEAN_H


#include "KMeansCenterBase.h"

class KMeansCenterMean : public KMeansCenterBase {

protected:

    vector<float> m_center;

    vector<float> m_votes;
    vector<float> m_tot_wgt;

public:

    KMeansCenterMean(int dim) :
            m_center(dim, 0),
            m_votes(dim, 0),
            m_tot_wgt(dim, 0) {}

    virtual void init(vector<float> &cent);

    virtual void vote(const vector<float> &v, float wgt);

    virtual void reset_votes();  //tot = 0, votes = 0
    virtual void init_to_votes(); //center = votes/tot
    virtual void update_center_stats();

    virtual void report(ostream &out);
    virtual vector<float> report_vector();
};


#endif //TGLKMEANS_KMEANSCENTERMEAN_H
