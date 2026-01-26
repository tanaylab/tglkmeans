//
// Created by aviezerl on 6/5/17.
//

#include "KMeansCenterMeanSpearman.h"
#include "AParamStat.h"
#include "IndirectSort.h"
#include "Ranking.h"

// Pre-calculate center ranks when center is updated
void KMeansCenterMeanSpearman::update_center_stats()
{
    // Pre-compute sorted order and ranks for the center
    m_center_sorted_order.clear();
    int dim = m_center.size();
    for (int i = 0; i < dim; i++) {
        m_center_sorted_order.push_back(i);
    }
    m_center_sorted_order.sort<IndirectSort<float>>(IndirectSort<float>(m_center));
    m_center_ranks.resize(dim);
    mid_ranking(m_center_ranks, m_center_sorted_order, m_center);
}

// Thread-safe distance calculation using local rank vectors
float KMeansCenterMeanSpearman::dist(const vector<float> &x) const
{
    double pv;
    // Use local rank vectors to avoid race conditions
    vector<float> rank1(x.size());
    vector<float> rank2(x.size());
    return(-spearman(x, m_center, rank1, rank2, pv));
}

