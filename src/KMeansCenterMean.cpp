//
// Created by aviezerl on 6/5/17.
//

#include <limits>
#include "KMeansCenterMean.h"

void KMeansCenterMean::init(vector<float> &cent) {
    m_center = cent;
    m_votes.resize(m_center.size());

    update_center_stats();
}

void KMeansCenterMean::vote(const vector<float> &x, float wgt) {
    vector<float>::const_iterator x_i = x.begin();
    vector<float>::iterator wgt_i = m_tot_wgt.begin();
    for (auto v_i = m_votes.begin(); v_i != m_votes.end(); v_i++) {
        if (REAL_MAX != *x_i) {
            *v_i += *x_i * wgt;
            *wgt_i += wgt;
        }
        wgt_i++;
        x_i++;
    }
}

void KMeansCenterMean::reset_votes() {
    fill(m_votes.begin(), m_votes.end(), 0);
    fill(m_tot_wgt.begin(), m_tot_wgt.end(), 0);
}

void KMeansCenterMean::init_to_votes() {
    vector<float>::iterator v_i = m_votes.begin();
    vector<float>::iterator wgt_i = m_tot_wgt.begin();
    for (auto c_i = m_center.begin(); c_i != m_center.end(); c_i++) {
        if (0 != *wgt_i) {
            *c_i = *v_i / (*wgt_i);
        } else {
            *c_i = REAL_MAX;
        }
        v_i++;
        wgt_i++;
    }
    update_center_stats();
}

void KMeansCenterMean::update_center_stats() {
    //do nothing by default
}

void KMeansCenterMean::report(ostream &out) {
    for (size_t i = 0; i < m_center.size(); i++) {
        if (i != 0) {
            out << "\t";
        }
        out << m_center[i];
    }
}

vector<float> KMeansCenterMean::report_vector() {
    return m_center;
}
