//
// Created by aviezerl on 6/5/17.
//

#include <limits>
#include <cmath>
#include "KMeansCenterMeanEuclid.h"


float KMeansCenterMeanEuclid::dist(const vector<float> &x) {
    vector<float>::const_iterator x_i = x.begin();
    float dist2 = 0;
    float n = 0;
    for (vector<float>::const_iterator c_i = m_center.begin(); c_i != m_center.end(); c_i++) {
        if (*x_i != REAL_MAX && *c_i != REAL_MAX) {
            dist2 += (*c_i - *x_i) * (*c_i - *x_i);
            n++;
        }
        x_i++;
    }
    return (n > 0 ? sqrt(dist2) / n : REAL_MAX);
};
