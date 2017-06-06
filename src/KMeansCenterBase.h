//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANSCENTERBASE_H
#define TGLKMEANS_KMEANSCENTERBASE_H

#include <vector>
#include <iostream>
#include <string>
#include <limits>
#define REAL_MAX std::numeric_limits<float>::max()

using namespace std;

class KMeansCenterBase {
public:
    virtual float dist(const vector<float> &v) = 0;

    virtual void vote(const vector<float> &v, float wgt) = 0;

    virtual void reset_votes() = 0;

    virtual void init_to_votes() = 0;

    virtual void report_meta_data_header(ostream &out);

    virtual void report_meta_data(ostream &out, const vector<float> &v);

    virtual void report(ostream &out) = 0;

    virtual vector<float> report_vector() = 0;
};


#endif //TGLKMEANS_KMEANSCENTERBASE_H
