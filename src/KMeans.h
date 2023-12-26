//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANS_H
#define TGLKMEANS_KMEANS_H

#include "KMeansCenterBase.h"

using namespace std;

class KMeans {
protected:

    int m_k;

    vector<KMeansCenterBase *> m_centers;

    vector<int> m_assignment;

    vector <pair<float, int>> m_min_dist;
    vector <pair<float, int>> m_core_dist;

    const vector <vector<float>> &m_data;

    float m_changes;

    bool m_use_cpp_random;

public:

    KMeans(const vector <vector<float>> &data, int k, vector<KMeansCenterBase *> &centers, const bool& use_cpp_random);

    void cluster(int max_iter, float min_delta_assign);

    void update_min_distance(int max_k);

    void add_new_core(int seed_i, int center_i);

    void generate_seeds();

    void update_centers();

    void reassign();

    void report_centers(ostream &center_tab);

    void report_centers_to_vector(vector<vector<float > >& centers);

    void report_assignment(vector <string> &row_names, ostream &assign_tab);

    vector<int> report_assignment_to_vector();

    float random_fraction();
};


#endif //TGLKMEANS_KMEANS_H
