//
// Created by aviezerl on 6/5/17.
//

#include "Random.h"

std::random_device   Random::m_rd;
std::mt19937         Random::m_rng(Random::m_rd());

Random::Random() {
}

float Random::fraction() {
    std::uniform_real_distribution<> dis(0, 1);
    return (dis(Random::m_rng));
}

void Random::seed(const int &seed) {
    Random::m_rng.seed(seed);
}

