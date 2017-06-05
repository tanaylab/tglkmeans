//
// Created by aviezerl on 6/5/17.
//

#include "KMeansCenterMeanSpearman.h"
#include "AParamStat.h"

//We could have save the ranking of the center and cut some running time here.
float KMeansCenterMeanSpearman::dist(const vector<float> &x)
{
    double pv;
    return(-spearman(x, m_center, m_rank1, m_rank2, pv));
}

