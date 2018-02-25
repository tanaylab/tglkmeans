// [[Rcpp::plugins("cpp11")]]

#include <Rcpp.h>

using namespace Rcpp;
using namespace std;

void reduce_coclust_single(const NumericVector& boot_nodes, const NumericMatrix& cc_ij_mat, NumericMatrix& cc_mat){
    for (int i=0; i < boot_nodes.length(); ++i){
        NumericMatrix::Column cc_col = cc_mat(_, boot_nodes[i] - 1);
        NumericMatrix::ConstColumn cc_ij_col = cc_ij_mat(_, i);

        for (int j = 0; j < boot_nodes.length(); ++j){
            cc_col[boot_nodes[j] - 1] = cc_col[boot_nodes[j] - 1] + cc_ij_col[j];
        }           
    }   
}

// [[Rcpp::export]]
void reduce_coclust(const List& boot_nodes_l, const List& cc_ij_mat_l, NumericMatrix& cc_mat){
    for (int i=0; i < boot_nodes_l.length(); ++i){
        reduce_coclust_single(Rcpp::as<const Rcpp::NumericVector>(boot_nodes_l[i]), Rcpp::as<const Rcpp::NumericMatrix>(cc_ij_mat_l[i]), cc_mat);
    }
}

void reduce_num_trials_single(const NumericVector& boot_nodes, NumericMatrix& cc_mat){
    for (int i=0; i < boot_nodes.length(); ++i){
        NumericMatrix::Column cc_col = cc_mat(_, boot_nodes[i] - 1);
        for (int j = 0; j < boot_nodes.length(); ++j){
            cc_col[boot_nodes[j] - 1] = cc_col[boot_nodes[j] - 1] + 1;
        }   
    }   
}

// [[Rcpp::export]]
void reduce_num_trials(const List& boot_nodes_l, NumericMatrix& cc_mat){
    for (int i=0; i < boot_nodes_l.length(); ++i){
        reduce_num_trials_single(Rcpp::as<const Rcpp::NumericVector>(boot_nodes_l[i]), cc_mat);
    }
}
