//
// Created by aviezerl on 6/5/17.
//

#include <algorithm>
#include "KMeans.h"
#include "UpdateMinDistanceWorker.h"
#include "AddCoreWorker.h"
#include "ReassignWorker.h"
#include "Random.h"
#include <Rcpp.h>

KMeans::KMeans(const vector<vector<float>> &data, int k, vector<KMeansCenterBase *> &centers, const bool& use_cpp_random) :
        m_k(k),
        m_centers(centers),
        m_assignment(data.size(), -1),
        m_data(data),
        m_use_cpp_random(use_cpp_random) {
}

float KMeans::random_fraction() {
    if (m_use_cpp_random){
        return Random::fraction();
    } else {
        return R::runif(0, 1);
    }
}

bool KMeans::is_valid_seed(int index) {
    // Check if a data point has at least one non-missing value
    for (const auto& val : m_data[index]) {
        if (val != REAL_MAX) return true;
    }
    return false;
}

void KMeans::cluster(int max_iter, float min_assign_change_fraction) {
    Rcpp::Rcout << "will generate seeds" << endl;
    generate_seeds();

    int iter = 0;
    m_changes = 0;

    Rcpp::Rcout << "reassign after init" << endl;
    reassign();

    while (iter < max_iter && m_changes / m_assignment.size() > min_assign_change_fraction) {
        Rcpp::Rcout << "iter " << iter << endl;
        m_changes = 0;
        update_centers();
        reassign();
        iter++;
        Rcpp::Rcout << "iter " << iter << " changed " << m_changes << endl;
        Rcpp::checkUserInterrupt();
    }
}

void KMeans::generate_seeds() {
    Rcpp::Rcout << "generating seeds" << endl;

    // Initialize m_min_dist ONCE - aligned with data indices
    m_min_dist.resize(m_data.size());
    for (size_t i = 0; i < m_data.size(); ++i) {
        m_min_dist[i] = std::make_pair(REAL_MAX, (int)i);
    }

    for (int i = 0; i < m_k; i++) {
        Rcpp::Rcout << "at seed " << i << endl;

        int seed_i = -1;
        if (i == 0) {
            // First seed: random selection, skipping all-NA points
            int attempts = 0;
            do {
                seed_i = random_fraction() * m_data.size();
                attempts++;
            } while (!is_valid_seed(seed_i) && attempts < (int)m_data.size());
            if (!is_valid_seed(seed_i)) {
                throw std::logic_error("No valid seed point found - all data points have missing values");
            }
        } else {
            // Create sorted copy for seed selection (m_min_dist stays index-aligned)
            vector<pair<float, int>> valid_dist;
            valid_dist.reserve(m_min_dist.size());

            for (const auto& p : m_min_dist) {
                // Filter: unassigned AND has valid distance (not sentinel values)
                if (p.first != -REAL_MAX && p.first != REAL_MAX) {
                    valid_dist.push_back(p);
                }
            }

            if (valid_dist.empty()) {
                throw std::logic_error("No valid candidates for seed selection - data may have too many missing values");
            }

            sort(valid_dist.begin(), valid_dist.end());
            Rcpp::Rcout << "done update min distance" << endl;

            // Select from 1/k of the data which is in the 1-1/2k quantile of the min distance
            // Note: Uses integer division (1 / (2 * m_k)) to match original behavior
            int to_i = int(valid_dist.size() * (1 - 1 / (2 * m_k)));
            int from_i = to_i - int(m_data.size() / m_k);
            Rcpp::Rcout << "seed range " << from_i << " " << to_i << endl;
            if (from_i < 0) {
                from_i = 0;
            }

            // Try to find a valid seed (skip all-NA points)
            int attempts = 0;
            do {
                int rnd_i = from_i + int(random_fraction() * (to_i - from_i));
                if (rnd_i >= (int)valid_dist.size()) rnd_i = valid_dist.size() - 1;
                seed_i = valid_dist[rnd_i].second;
                attempts++;
            } while (!is_valid_seed(seed_i) && attempts < (to_i - from_i + 1));

            // If no valid seed in quantile range, scan entire valid_dist
            if (!is_valid_seed(seed_i)) {
                seed_i = -1;
                for (const auto& p : valid_dist) {
                    if (is_valid_seed(p.second)) {
                        seed_i = p.second;
                        break;
                    }
                }
                if (seed_i == -1) {
                    throw std::logic_error("No valid seed candidates - too many all-NA rows in data");
                }
            }
            Rcpp::Rcout << "picked up " << seed_i << endl;
        }

        // Add core (parallel)
        add_new_core(seed_i, i);

        // Update min distances for NEXT iteration (incremental - only compares to center i)
        update_min_distance(i);

        Rcpp::checkUserInterrupt();
    }
}


void KMeans::update_min_distance(int center_idx) {
    // Note: m_min_dist must be pre-sized and initialized before first call (in generate_seeds)
    // This performs an INCREMENTAL update - only comparing to the new center
    UpdateMinDistanceWorker worker(m_data, m_centers[center_idx], m_min_dist, m_assignment);
    RcppParallel::parallelFor(0, m_data.size(), worker);
    // NOTE: Do NOT sort here - sorting happens in generate_seeds when needed
}


void KMeans::add_new_core(int seed_i, int center_i) {
    Rcpp::Rcout << "add new core from " << seed_i << " to " << center_i << endl;

    // Initialize center with seed
    m_centers[center_i]->reset_votes();
    m_centers[center_i]->vote(m_data[seed_i], 1);
    m_centers[center_i]->init_to_votes();

    // Parallel distance calculation
    m_core_dist.resize(m_data.size());
    AddCoreWorker worker(m_data, m_centers[center_i], m_assignment, m_core_dist);
    RcppParallel::parallelFor(0, m_data.size(), worker);

    // Use partial_sort for O(N) instead of O(N log N)
    int to_add_n = int(m_data.size() / (2 * m_k));
    if (to_add_n < 1) {
        to_add_n = 1;  // Ensure at least 1 point per cluster during seeding
    }

    std::partial_sort(m_core_dist.begin(),
                      m_core_dist.begin() + to_add_n,
                      m_core_dist.end());

    // Assign closest points
    int count = 0;
    m_centers[center_i]->reset_votes();
    for (auto i = m_core_dist.begin(); count < to_add_n && i != m_core_dist.end(); i++) {
        if (i->first == REAL_MAX) break;  // Hit assigned points
        m_centers[center_i]->vote(m_data[i->second], 1);
        m_assignment[i->second] = center_i;
        count++;
    }
    m_centers[center_i]->init_to_votes();
}

void KMeans::update_centers() {
    for (int i = 0; i < m_k; i++) {
        m_centers[i]->init_to_votes();
        m_centers[i]->reset_votes();
        Rcpp::checkUserInterrupt();
    }
}

void KMeans::reassign() {
    // Initialize the ReassignWorker with data, centers, and assignments
    ReassignWorker worker(m_data, m_centers, m_assignment);
    
    // Use parallelReduce instead of parallelFor to properly merge votes across threads.
    // parallelFor copies the worker for each chunk but never merges results back,
    // which causes votes to be lost. parallelReduce calls join() to merge results.
    RcppParallel::parallelReduce(0, m_data.size(), worker);

    // Apply accumulated votes to the centers
    worker.apply_votes();

    // Update the number of changes based on the worker's results
    m_changes = worker.get_changes();
}

void KMeans::report_centers(ostream &center_tab) {
    for (int i = 0; i < m_k; i++) {
        center_tab << i << "\t";
        m_centers[i]->report(center_tab);
        center_tab << "\n";
    }
}

void KMeans::report_centers_to_vector(vector<vector<float > >& centers){
    for (int i = 0; i < m_k; i++) {
        centers.push_back(m_centers[i]->report_vector());
    }
}

void KMeans::report_assignment(vector<string> &row_names, ostream &assign_tab) {
    assign_tab << "id\tclust";
    m_centers[0]->report_meta_data_header(assign_tab);
    assign_tab << "\n";
    for (size_t i = 0; i < m_data.size(); i++) {
        assign_tab << row_names[i] << "\t" << m_assignment[i];

        m_centers[m_assignment[i]]->report_meta_data(assign_tab, m_data[i]);

        assign_tab << "\n";
    }
}

vector<int> KMeans::report_assignment_to_vector() {
    return std::vector<int>(m_assignment);
}
