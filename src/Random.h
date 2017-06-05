//
// Created by aviezerl on 6/5/17.
//

#ifndef TGLKMEANS_RANDOM_H
#define TGLKMEANS_RANDOM_H


#include <random>

class Random {
private:
    static std::random_device m_rd;
    static std::mt19937 m_rng;
public:
    Random();

    static void seed(const int& seed);

    static float fraction();

};


#endif //TGLKMEANS_RANDOM_H
