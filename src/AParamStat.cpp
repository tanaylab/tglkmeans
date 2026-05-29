#include "AParamStat.h"
#include "Ranking.h"
#include "IndirectSort.h"
#include "KMeansCenterBase.h"
#include <algorithm>
#include <cmath>

using namespace std;

// Spearman rank correlation between v1 and v2 over jointly non-missing
// positions. The k-means hot path only needs the correlation, so (unlike the
// historical version) no p-value is computed - dropping the per-call
// incomplete-beta evaluation. Sorting buffers are thread_local to avoid
// per-call allocation while remaining safe under RcppParallel (dist() is called
// concurrently). std::sort is used instead of list::sort; tie handling in
// cond_mid_ranking makes the result independent of the (unstable) tie order.
float spearman(const vector<float> &v1, const vector<float> &v2)
{
	static thread_local vector<int> order;
	static thread_local vector<float> rank1;
	static thread_local vector<float> rank2;

	int max_i = (int)v1.size();
	order.resize(max_i);
	for(int i = 0; i < max_i; i++) {
		order[i] = i;
	}
	rank1.resize(v1.size());
	rank2.resize(v2.size());

	std::sort(order.begin(), order.end(), IndirectSort<float>(v1));
	cond_mid_ranking(rank1, order, v1, v2);
	std::sort(order.begin(), order.end(), IndirectSort<float>(v2));
	cond_mid_ranking(rank2, order, v2, v1);

	vector<float>::iterator r1 = rank1.begin();
	vector<float>::iterator r2 = rank2.begin();
	vector<float>::iterator max_r1 = rank1.end();

	int num = 0;
	float cov = 0;
	float e1 = 0; float e2 = 0;
	float var1 = 0; float var2 = 0;

	while(r1 != max_r1) {
		if(*r1 != -REAL_MAX) {
			cov += (*r1) * (*r2);

			e1 += (*r1);
			e2 += (*r2);
			var1 += (*r1)*(*r1);
			var2 += (*r2)*(*r2);
			num++;
		}
		r1++;
		r2++;
	}

	if(num == 0) {
		return(0);
	}

	e1 /= num;
	e2 /= num;
	var1 = var1/num - e1*e1;
	var2 = var2/num - e2*e2;

	if(var1 <= 0 || var2 <= 0) {
		return(0);
	}

	return(((cov/num) - e1*e2)/sqrt(var1*var2));
}
