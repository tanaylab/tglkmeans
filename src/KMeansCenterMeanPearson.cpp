//
// Created by aviezerl on 6/5/17.
//

#include <cmath>
#include "KMeansCenterMeanPearson.h"

float KMeansCenterMeanPearson::dist(const vector<float> &x)
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
        return(0);
    }
    x_e /= n;
    float cov = cov2/n - x_e * m_center_e;

    float x_v = x_v2/n - x_e * x_e;
    if(x_v == 0) {
        return(0);
    }
    return(cov/sqrt(m_center_v * x_v));
};

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
    m_center_e = c_e/n;
    m_center_v = c_e2/n - m_center_e*m_center_e;
}
