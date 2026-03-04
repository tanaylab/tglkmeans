#ifndef stdalg_alg_Ranking_h
#define stdalg_alg_Ranking_h 1

#include <vector>
#include <list>

void mid_ranking(std::vector<float> &ranks, const std::list<int> &order, const std::vector<float> &vals);
void cond_mid_ranking(std::vector<float> &ranks, const std::list<int> &order, const std::vector<float> &vals, const std::vector<float> &noz_vals);

#endif //stdalg_alg_Ranking_h
