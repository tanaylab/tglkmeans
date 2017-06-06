#include "Ranking.h"
#include <limits>
#define REAL_MAX std::numeric_limits<float>::max()

void mid_ranking(vector<float> &ranks, const list<int> &order, 
						const vector<float> &vals)
{
	float count = 1;
	float ecount = 0;
	list<int>::const_iterator i = order.begin(); 
	while(i != order.end() && vals[*i] == -REAL_MAX) {
		ranks[*i] = -REAL_MAX;
		i++;
	}
	float prev_val = 0;
       	if(i != order.end()) {
		prev_val = vals[*i];
	}
	while(i != order.end()) {
		if(vals[*i] == -REAL_MAX) {
			ranks[*i] = -REAL_MAX;
			i++;
			continue;
		}
		float val = vals[*i];
		if(val != prev_val) {
			if(ecount > 1) {
				float mean_count = count + (ecount-1)/2;
				list<int>::const_iterator j = i;
				for(int k = 0; k < ecount; k++) {
					do {
						j--;
					} while(j != order.begin()
					&& vals[*j] == -REAL_MAX);
					ranks[*j] = mean_count;
				}
			} 
			count += ecount;
			ecount = 1;
			prev_val = val;
		} else {
			ecount++;
		}
		ranks[*i] = count;
		i++;
	}
	if(ecount > 1) {
		float mean_count = count + (ecount-1)/2;
		list<int>::const_reverse_iterator j = order.rbegin();
		while(vals[*j] == -REAL_MAX) {
			j++;
		}
		for(int k = 0; k < ecount; k++) {
			ranks[*j] = mean_count;
			do {
				j++;
			} while(j != order.rend()
			&& vals[*j] == -REAL_MAX);
		}
		count += ecount;
	}
}
void cond_mid_ranking(vector<float> &ranks, 
		const list<int> &order, const 
		vector<float> &vals, const vector<float> &noz_vals) 
{
	float count = 1;
	float ecount = 0;
	list<int>::const_iterator i = order.begin(); 
	while(i != order.end()
	&& (vals[*i] == -REAL_MAX || noz_vals[*i] == -REAL_MAX)) {
		ranks[*i] = -REAL_MAX;
		i++;
	}
	float prev_val = 0;
       	if(i != order.end()) {
		prev_val = vals[*i];
	}
	while(i != order.end()) {
		if(vals[*i] == -REAL_MAX || noz_vals[*i] == -REAL_MAX) {
			ranks[*i] = -REAL_MAX;
			i++;
			continue;
		}
		float val = vals[*i];
		if(val != prev_val) {
			if(ecount > 1) {
				float mean_count = count + (ecount-1)/2;
				list<int>::const_iterator j = i;
				for(int k = 0; k < ecount; k++) {
					do {
						j--;
					} while(j != order.begin()
					&& (vals[*j] == -REAL_MAX
					|| noz_vals[*j] == -REAL_MAX));
					ranks[*j] = mean_count;
				}
			} 
			count += ecount;
			ecount = 1;
			prev_val = val;
		} else {
			ecount++;
		}
		ranks[*i] = count;
		i++;
	}
	if(ecount > 1) {
		float mean_count = count + (ecount-1)/2;
		list<int>::const_reverse_iterator j = order.rbegin();
		while(vals[*j] == -REAL_MAX || noz_vals[*j] == -REAL_MAX) {
			j++;
		}
		for(int k = 0; k < ecount; k++) {
			ranks[*j] = mean_count;
			do {
				j++;
			} while(j != order.rend()
			&& (vals[*j] == -REAL_MAX
			|| noz_vals[*j] == -REAL_MAX));
		}
		count += ecount;
	}
}
