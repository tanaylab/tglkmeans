//
// Created by aviezerl on 6/5/17.
//

#include <algorithm>
#include "KMeans.h"
#include "UpdateMinDistanceWorker.h"
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
    for (int i = 0; i < m_k; i++) {        
        Rcpp::Rcout << "at seed " << i << endl;
        m_min_dist.resize(0);
        //compute minimal distance from centers
        //select next seed by sampling
        int seed_i = -1;
        if (i == 0) {
            // select the first seed randomly
            seed_i = random_fraction() * m_data.size();
        } else {
            update_min_distance(i);
            Rcpp::Rcout << "done update min distance" << endl;
            
            //select from 1/k of the data which is in the 1-1/2k quantile of the min distance
            int to_i = int(m_min_dist.size() * (1 - 1 / (2 * m_k)));
            int from_i = to_i - int(m_data.size() / m_k);
            Rcpp::Rcout << "seed range " << from_i << " " << to_i << endl;
            if (from_i < 0) {
                from_i = 0;
            }

            int rnd_i = from_i + int(random_fraction() * (to_i - from_i));
            seed_i = m_min_dist[rnd_i].second;
            Rcpp::Rcout << "picked up " << seed_i << " dist was " << m_min_dist[rnd_i].first << endl;
        }

        add_new_core(seed_i, i);
        Rcpp::checkUserInterrupt();
    }
}


void KMeans::update_min_distance(int cur_k) {
    m_min_dist.resize(m_data.size());
    UpdateMinDistanceWorker worker(m_data, m_centers, m_min_dist, m_assignment, cur_k);
    RcppParallel::parallelFor(0, m_data.size(), worker);
    worker.prepare_min_dist(m_min_dist);
    sort(m_min_dist.begin(), m_min_dist.end());
}


void KMeans::add_new_core(int seed_i, int center_i) {
    Rcpp::Rcout << "add new core from " << seed_i << " to " << center_i << endl;
    m_centers[center_i]->reset_votes();
    m_centers[center_i]->vote(m_data[seed_i], 1);
    m_centers[center_i]->init_to_votes();

    m_core_dist.resize(0);

    vector<int>::iterator assign_i = m_assignment.begin();
    int samp_i = 0;
    for (auto data_i = m_data.begin(); data_i != m_data.end(); data_i++) {
        if (*assign_i == -1) {
            float dist = m_centers[center_i]->dist(*data_i);
            m_core_dist.push_back(pair<float, int>(dist, samp_i));
        }
        samp_i++;
        assign_i++;
    }
    sort(m_core_dist.begin(), m_core_dist.end());

    int to_add_n = int(m_data.size() / (2 * m_k));
    int count = 0;
    m_centers[center_i]->reset_votes();
    for (auto i = m_core_dist.begin(); count < to_add_n; i++) {
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
    
    // Perform parallel computation for reassignment
    RcppParallel::parallelFor(0, m_data.size(), worker);

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
