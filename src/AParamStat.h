#ifndef TGLKMEANS_APARAMSTAT_H
#define TGLKMEANS_APARAMSTAT_H


#include <vector>
#include <list>
#include <cmath>
#include "KMeans.h"
#include <Rcpp.h>

using namespace std;

float corr_pv(float corr, int n);

float spearman(const vector<float> &v1, const vector<float> &v2,
               vector<float> &rank1, vector<float> &rank2,
               double &pv);

//Return a p-value for the wilcoxon rank sum test, T should support
//a casting to pair<float, int> where the first param store the value
//and the second should be 0 for the test and 1 for the control
//
//Note that the samples list should be sorted
template<class T>
float wilcoxon_rank_sum(list <T> &samples, int type = 1) {
    float prev_val = samples.front().get_val();
    int ecount = 0;
    int count = 1;
    int W = 0;
    int t3_minus_t = 0;
    int n2 = 0;
    for (typename list<T>::iterator i = samples.begin(); i != samples.end(); i++) {
        float val = i->get_val();
        if (val == -REAL_MAX) {
            continue;
        }
        if (val != prev_val) {
            t3_minus_t += ecount * ecount * ecount - ecount;
            prev_val = val;
            ecount = 1;
        } else {
            ecount++;
        }
        if (i->get_type() == type) {
            W += count;
            n2++;
        }
        count++;
    }
    int n1 = samples.size() - n2;
    t3_minus_t += ecount * ecount * ecount - ecount;

    float U = W - (n2 * (n2 + 1)) / 2;

    float EU = n1 * n2 / 2.0;
    float VarU = n1 * n2 * (samples.size() + 1) / 12.0;

    Rcpp::Rcout << "W " << W << " n2 " << n2 << " EU " << EU << " Var " << VarU << " t2_minus_t " << t3_minus_t << endl;

    float pv = erfc((U - EU) / sqrt(VarU));

    return (pv);
}

//Return a p-value for the siegel_tukey test, T should support
//a casting to pair<float, int> where the first param store the value
//and the second should be 0 for the test and 1 for the control
template<class T>
float siegel_tukey(list <T> &samples, int type = 1) {
    int ecount = 0;
    int ecount_end = 0;
    int count = 1;
    int W = 0;
    int t3_minus_t = 0;
    int n2 = 0;
    float prev_val = samples.front().get_val();
    float prev_val_end = samples.back().get_val();
    typename list<T>::iterator i_end = samples.end();
    i_end--;
    for (typename list<T>::iterator i = samples.begin(); i != samples.end(); i++) {
        float val = i->get_val();
        if (val != -REAL_MAX) {
            if (val != prev_val) {
                t3_minus_t += ecount * ecount * ecount - ecount;
                prev_val = val;
                ecount = 1;
            } else {
                ecount++;
            }
            if (i->get_type() == type) {
                W += count;
                n2++;
            }
        }
        if (i_end == i) {
            break;
        }
        count++;
        float val_end = i_end->get_val();
        if (val_end != -REAL_MAX) {
            if (val_end != prev_val_end) {
                t3_minus_t += ecount_end * ecount_end * ecount_end - ecount_end;
                prev_val_end = val_end;
                ecount_end = 1;
            } else {
                ecount_end++;
            }
            if (i_end->get_type() == type) {
                W += count;
                n2++;
            }
        }
        count++;
        i_end--;
        if (i_end == i) {
            break;
        }
    }
    int n1 = samples.size() - n2;
    t3_minus_t += ecount * ecount * ecount - ecount;

    float U = W - (n2 * (n2 + 1)) / 2;

    float EU = n1 * n2 / 2.0;
    float VarU = n1 * n2 * (samples.size() + 1) / 12.0;

    Rcpp::Rcout << "W " << W << " n2 " << n2 << " EU " << EU << " Var " << VarU << " t2_minus_t " << t3_minus_t << endl;
    float pv = erfc((U - EU) / sqrt(VarU));

    return (pv);
}

double dbl_gamma_ln(float xx);
double betai(double a, double b, double x);
double betacf(double a, double b, double x);

#endif //TGLKMEANS_APARAMSTAT_H
