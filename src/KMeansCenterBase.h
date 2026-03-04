//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANSCENTERBASE_H
#define TGLKMEANS_KMEANSCENTERBASE_H

#include <vector>
#include <iostream>
#include <string>
#include <limits>
constexpr float REAL_MAX = std::numeric_limits<float>::max();

class KMeansCenterBase {
public:
    virtual ~KMeansCenterBase() = default;

    virtual float dist(const std::vector<float> &v) const = 0;

    virtual void vote(const std::vector<float> &v, float wgt) = 0;

    virtual void reset_votes() = 0;

    virtual void init_to_votes() = 0;

    virtual void report_meta_data_header(std::ostream &out);

    virtual void report_meta_data(std::ostream &out, const std::vector<float> &v);

    virtual void report(std::ostream &out) = 0;

    virtual std::vector<float> report_vector() = 0;
};


#endif //TGLKMEANS_KMEANSCENTERBASE_H
