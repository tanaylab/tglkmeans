//
// Created by aviezerl on 6/5/17.
//

#include <algorithm>
#include "KMeans.h"
#include "Random.h"
#include <Rcpp.h>

KMeans::KMeans(const vector<vector<float>> &data, int k, vector<KMeansCenterBase *> &centers) :
        m_k(k),
        m_centers(centers),
        m_assignment(data.size(), -1),
        m_data(data) {
}

void KMeans::cluster(int max_iter, float min_assign_change_fraction) {
    Rcpp::Rcout << "KMEans: will generate seeds" << endl;
    generate_seeds();

    int iter = 0;
    m_changes = 0;

    Rcpp::Rcout << "KMEans: reassign after init" << endl;
    reassign();

    while (iter < max_iter && m_changes / m_assignment.size() > min_assign_change_fraction) {
        Rcpp::Rcout << "KMEans: iter " << iter << endl;
        m_changes = 0;
        update_centers();
        reassign();
        iter++;
        Rcpp::Rcout << "KMEans: iter " << iter << " changed " << m_changes << endl;
    }
}

void KMeans::generate_seeds() {
    Rcpp::Rcout << "KMeans into generate seeds" << endl;
    for (int i = 0; i < m_k; i++) {
        Rcpp::Rcout << "at seed " << i << endl;
        m_min_dist.resize(0);
        //compute minimal distance from centers
        //select next seed by sampling
        int seed_i = -1;
        if (i == 0) {
            seed_i = Random::fraction() * m_data.size();
        } else {
            update_min_distance(i);
            Rcpp::Rcout << "done update min distance" << endl;
            sort(m_min_dist.begin(), m_min_dist.end());
            //select from 1/k of the data which is in the 1-1/2k quantile of the min distance
            int to_i = int(m_min_dist.size() * (1 - 1 / (2 * m_k)));
            int from_i = to_i - int(m_data.size() / m_k);
            Rcpp::Rcout << "seed range " << from_i << " " << to_i << endl;
            if (from_i < 0) {
                from_i = 0;
            }
            int rnd_i = from_i + int(Random::fraction() * (to_i - from_i));
            seed_i = m_min_dist[rnd_i].second;
            Rcpp::Rcout << "picked up " << seed_i << " dist was " << m_min_dist[rnd_i].first << endl;
        }

        add_new_core(seed_i, i);
    }
}


void KMeans::update_min_distance(int cur_k) {
    vector<int>::iterator assign_i = m_assignment.begin();
    int samp_i = 0;
    for (auto data_i = m_data.begin(); data_i != m_data.end(); data_i++) {
        if (*assign_i != -1) {
            samp_i++;
            assign_i++;
            continue;
        }
        float best_dist = REAL_MAX;
        int id_i = 0;
        for (auto cent_i = m_centers.begin(); id_i < cur_k; cent_i++) {
            float dist = (*cent_i)->dist(*data_i);
            if (dist < best_dist) {
                best_dist = dist;
            }
            id_i++;
        }
        m_min_dist.push_back(pair<float, int>(best_dist, samp_i));

        samp_i++;
        assign_i++;
    }
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
    }
}

void KMeans::reassign() {
    vector<int>::iterator assign_i = m_assignment.begin();

    for (auto data_i = m_data.begin(); data_i != m_data.end(); data_i++) {
        int id_i = 0;
        float best_dist = REAL_MAX;
        int best_id_i = -1;
        for (auto cent_i = m_centers.begin(); cent_i != m_centers.end(); cent_i++) {
            float dist = (*cent_i)->dist(*data_i);
            if (dist < best_dist) {
                best_dist = dist;
                best_id_i = id_i;
            }
            id_i++;
        }

        if (best_id_i == -1) {
            throw std::logic_error(
                    "Cannot assign any center to element " + to_string(data_i - m_data.begin() + 1) + " all dist is NA");
        }

        if (*assign_i != best_id_i) {
            *assign_i = best_id_i;
            m_changes++;
        }
        m_centers[best_id_i]->vote(*data_i, 1);
        assign_i++;
    }
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
