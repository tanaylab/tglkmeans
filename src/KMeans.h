//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_KMEANS_H
#define TGLKMEANS_KMEANS_H

#include "KMeansCenterBase.h"

class KMeans {
protected:

    int m_k;

    std::vector<KMeansCenterBase *> m_centers;

    std::vector<int> m_assignment;

    std::vector<std::pair<float, int>> m_min_dist;
    std::vector<std::pair<float, int>> m_core_dist;

    const std::vector<std::vector<float>> &m_data;

    // Intentionally float, not an integer count: cluster() tests convergence
    // with m_changes / m_assignment.size(). As an int this would be integer
    // division and always evaluate to 0, so the loop would stop after one pass.
    float m_changes;

    bool m_use_cpp_random;

    // When false the algorithm runs silently; when true it reports concise
    // per-iteration progress to Rcout. Set at the start of cluster().
    bool m_verbose = false;

public:

    KMeans(const std::vector<std::vector<float>> &data, int k, std::vector<KMeansCenterBase *> &centers, const bool& use_cpp_random);

    void cluster(int max_iter, float min_delta_assign, bool verbose);

    void update_min_distance(int center_idx);

    void add_new_core(int seed_i, int center_i);

    void generate_seeds();

    void update_centers();

    void reassign();

    void report_centers(std::ostream &center_tab);

    void report_centers_to_vector(std::vector<std::vector<float>> &centers);

    void report_assignment(std::vector<std::string> &row_names, std::ostream &assign_tab);

    std::vector<int> report_assignment_to_vector();

    float random_fraction();

    bool is_valid_seed(int index);
};


#endif //TGLKMEANS_KMEANS_H
