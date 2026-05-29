//
// Created by aviezerl on 6/5/17.
//

#include "KMeansCenterMeanSpearman.h"
#include "AParamStat.h"

using namespace std;

// Distance is the negated Spearman rank correlation, so nearer points have
// smaller values. The center ranks cannot be cached across calls because the
// conditional mid-ranking depends on which positions the data point x has
// missing; spearman() handles the ranking with thread_local buffers.
float KMeansCenterMeanSpearman::dist(const vector<float> &x) const
{
    return(-spearman(x, m_center));
}
