//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANSCENTERMEAN_H
#define TGLKMEANS_KMEANSCENTERMEAN_H


#include "KMeansCenterBase.h"

class KMeansCenterMean : public KMeansCenterBase {

protected:

    std::vector<float> m_center;

    std::vector<float> m_votes;
    std::vector<float> m_tot_wgt;

public:

    KMeansCenterMean(int dim) :
            m_center(dim, 0),
            m_votes(dim, 0),
            m_tot_wgt(dim, 0) {}

    virtual void init(std::vector<float> &cent);

    virtual void vote(const std::vector<float> &v, float wgt) override;

    virtual void reset_votes() override;  //tot = 0, votes = 0
    virtual void init_to_votes() override; //center = votes/tot
    virtual void update_center_stats();

    virtual void report(std::ostream &out) override;
    virtual std::vector<float> report_vector() override;
};


#endif //TGLKMEANS_KMEANSCENTERMEAN_H
