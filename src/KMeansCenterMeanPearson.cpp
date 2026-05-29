//
// Created by aviezerl on 6/5/17.
//

#include <cmath>
#include "KMeansCenterMeanPearson.h"

using namespace std;

// Negated Pearson correlation between x and the center.
//
// For speed, the center's mean (m_center_e) and variance (m_center_v) are
// precomputed once over all non-missing center positions (update_center_stats)
// rather than recomputed over the x/center overlap on every call. When x has no
// missing values this is exact Pearson; when x has missing values the center
// moments are a (close) approximation over a slightly larger support than the
// overlap. Recomputing them per pair would make this O(dim) extra work on the
// hottest loop, so the approximation is intentional.
float KMeansCenterMeanPearson::dist(const vector<float> &x) const
{
    vector<float>::const_iterator x_i = x.begin();
    float cov2 = 0;
    float x_v2 = 0;
    float x_e = 0;
    int n = 0;
    for(vector<float>::const_iterator c_i = m_center.begin(); c_i != m_center.end(); c_i++) {
        if(!isnan(*x_i) && *x_i != REAL_MAX && *c_i != REAL_MAX) {
            cov2 += (*c_i) * (*x_i);
            x_v2 += (*x_i) * (*x_i);
            x_e += (*x_i);
            n++;
        }
        x_i++;
    }
    if(n == 0) {
        return(REAL_MAX);
    }
    x_e /= n;
    float cov = cov2/n - x_e * m_center_e;

    float x_v = x_v2/n - x_e * x_e;
    if(x_v == 0) {
        return(0);
    }
    return(-cov/sqrt(m_center_v * x_v));
}

void KMeansCenterMeanPearson::update_center_stats()
{
    float c_e = 0;
    float c_e2 = 0;
    float n = 0;
    for(vector<float>::iterator c_i = m_center.begin(); c_i != m_center.end(); c_i++) {
        if(*c_i != REAL_MAX) {
            c_e += *c_i;
            c_e2 += (*c_i)*(*c_i);
            n++;
        }
    }
    if (n == 0) {
        m_center_e = 0;
        m_center_v = 0;
        return;
    }
    m_center_e = c_e/n;
    m_center_v = c_e2/n - m_center_e*m_center_e;
}
