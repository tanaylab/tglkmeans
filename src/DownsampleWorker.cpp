#include <vector>
#include <algorithm>
#include <cassert>
#include <random>
#include <Rcpp.h>
#include <RcppParallel.h>
#include "DownsampleWorker.h"

typedef float float32_t;
typedef double float64_t;
typedef unsigned char uint8_t;
typedef unsigned int uint_t;

static size_t
ceil_power_of_two(const size_t size) {
    return size_t(1) << size_t(ceil(log2(float64_t(size))));
}

template<typename D>
static void initialize_tree(const std::vector<D>& input, std::vector<size_t>& tree) {
    assert(input.size() >= 2); 

    size_t input_size = ceil_power_of_two(input.size());
    tree.resize(2 * input_size - 1); // Resize the tree to the necessary size

    // Copy input to the beginning of the tree and fill the rest with zeros
    std::copy(input.begin(), input.end(), tree.begin());
    std::fill(tree.begin() + input.size(), tree.begin() + input_size, 0);

    // Iteratively build the tree
    size_t tree_index = 0;
    while (input_size > 1) {
        size_t half_size = input_size / 2;
        for (size_t index = 0; index < half_size; ++index) {
            const auto left = tree[tree_index + index * 2];
            const auto right = tree[tree_index + index * 2 + 1];
            tree[tree_index + input_size + index] = left + right;

            assert(left >= 0);
            assert(right >= 0);
            assert(tree[tree_index + input_size + index] == size_t(left) + size_t(right));
        }
        tree_index += input_size;
        input_size = half_size;
    }
    assert(tree.size() == 2 * input.size() - 1);
}

static size_t random_sample(std::vector<size_t>& tree, ssize_t random) {
    size_t size_of_level = 1;
    ssize_t base_of_level = tree.size() - 1;
    size_t index_in_level = 0;
    size_t index_in_tree = base_of_level + index_in_level;

    while (true) {
        assert(index_in_tree == base_of_level + index_in_level);
        assert(tree[index_in_tree] > random);

        --tree[index_in_tree];
        size_of_level *= 2;
        base_of_level -= size_of_level;

        if (base_of_level < 0) {
            return index_in_level;
        }

        index_in_level *= 2;
        index_in_tree = base_of_level + index_in_level;
        ssize_t right_random = random - ssize_t(tree[index_in_tree]);

        assert(tree[base_of_level + index_in_level] + tree[base_of_level + index_in_level + 1] ==
               tree[base_of_level + size_of_level + index_in_level / 2] + 1);

        if (right_random >= 0) {
            ++index_in_level;
            ++index_in_tree;
            assert(index_in_level < size_of_level);
            random = right_random;
        }
    }
}

template<typename D, typename O>
static void downsample_slice(const std::vector<D>& input, std::vector<O>& output, const int32_t samples, const size_t random_seed) {
    assert(output.size() == input.size()); 

    if (samples < 0 || input.size() == 0) {
        return;
    }

    if (input.size() == 1) {
        output[0] = O(static_cast<double>(samples) < static_cast<double>(input[0]) ? samples : input[0]);
        return;
    }

    size_t input_size = ceil_power_of_two(input.size());
    std::vector<size_t> tree(2 * input_size - 1);
    initialize_tree(input, tree);
    size_t& total = tree[tree.size() - 1];

    if (total <= static_cast<size_t>(samples)) {
        std::copy(input.begin(), input.end(), output.begin());
        return;
    }

    std::fill(output.begin(), output.end(), O(0));

    std::minstd_rand random(random_seed);
    for (size_t index = 0; index < static_cast<size_t>(samples); ++index) {
        size_t sampled_index = random_sample(tree, random() % total);
        if (sampled_index < output.size()) {
            ++output[sampled_index];
        }
    }
}

DownsampleWorker::DownsampleWorker(const Rcpp::IntegerMatrix& input, Rcpp::IntegerMatrix& output, int samples, unsigned int random_seed)
    : input_matrix(input), output_matrix(output), samples(samples), random_seed(random_seed) {}

void DownsampleWorker::operator()(std::size_t begin, std::size_t end) {
    for (std::size_t col = begin; col < end; ++col) {        
        std::vector<int> input_vec(input_matrix.column(col).begin(), input_matrix.column(col).end());
        std::vector<int> output_vec(input_vec.size(), 0);

        downsample_slice(input_vec, output_vec, samples, random_seed);

        std::copy(output_vec.begin(), output_vec.end(), output_matrix.column(col).begin());
    }
}

DownsampleWorkerSparse::DownsampleWorkerSparse(const Rcpp::IntegerVector& i, const Rcpp::IntegerVector& p, const Rcpp::IntegerVector& x, 
                                               Rcpp::IntegerVector& out_x, int samples, unsigned int random_seed)
    : input_i(i), input_p(p), input_x(x), output_x(out_x), samples(samples), random_seed(random_seed) {}

void DownsampleWorkerSparse::operator()(std::size_t begin, std::size_t end) {
    for (std::size_t col = begin; col < end; ++col) {
        // Extract the current column from the sparse matrix
        std::vector<int> input_vec;
        for (int idx = input_p[col]; idx < input_p[col + 1]; ++idx) {
            input_vec.push_back(input_x[idx]);
        }

        std::vector<int> output_vec(input_vec.size(), 0);

        downsample_slice(input_vec, output_vec, samples, random_seed);

        // Store results in the output sparse matrix
        for (int idx = input_p[col], out_idx = 0; idx < input_p[col + 1]; ++idx, ++out_idx) {
            output_x[idx] = output_vec[out_idx];
        }
    }
}
