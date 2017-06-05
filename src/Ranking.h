#ifndef stdalg_alg_Ranking_h
#define stdalg_alg_Ranking_h 1

#include <vector>
#include <list>
using namespace std;

void mid_ranking(vector<float> &ranks, const list<int> &order, const vector<float> &vals);
void cond_mid_ranking(vector<float> &ranks, const list<int> &order, const vector<float> &vals, const vector<float> &noz_vals);

#endif //stdalg_alg_Ranking_h
