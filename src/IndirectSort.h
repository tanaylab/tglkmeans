#ifndef TGLKMEANS_INDIRECTSORT_H
#define TGLKMEANS_INDIRECTSORT_H


#include <vector>
using namespace std;

template<class T>
class IndirectSort {

protected:
	const vector<T> &m_vals;
public:
	IndirectSort(const vector<T> &vals) :
		m_vals(vals)
	{}

	bool operator()(int i1, int i2) {
		return(m_vals[i1] < m_vals[i2]);
	}
};


#endif // TGLKMEANS_INDIRECTSORT_H
