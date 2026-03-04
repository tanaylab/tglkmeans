# tglkmeans 0.6.0

## New features

* Added `predict_tgl_kmeans()` function to assign new observations to existing k-means cluster centers (#5).
* Auto-detect character/factor first column as ID column.
* Exported `match_clusters()` and `test_clustering()` functions.

## Bug fixes

* Fixed memory leak in C++ k-means core — center objects are now managed with `std::unique_ptr`.
* Fixed Pearson distance sign bug — distance is now properly negated (consistent with Spearman) so that highly correlated observations are placed in the same cluster.
* Fixed `km$clust` typo that silently broke cluster size reporting.
* Fixed uninitialized `new_order` variable when all features have zero variance.
* Fixed `detectCores()` returning `NA` on some systems, which crashed package load.
* Fixed k-means seeding crash when `k` is large relative to data size.
* Fixed race condition and vote merging bugs in parallel workers.
* Fixed division-by-zero guard in Pearson center statistics.
* Fixed downsample per-column seed to ensure distinct randomization per column.
* Fixed assert condition in `DownsampleWorker.cpp` for non-power-of-two input sizes.
* Added bounds clamp for first seed selection in k-means initialization.

## Improvements

* Parallelized k-means initialization.
* Added `override` keyword to all C++ virtual method overrides (fixes macOS compiler warnings).
* Changed `REAL_MAX` from `#define` to `constexpr float` for type safety.
* Added virtual destructor to `KMeansCenterBase`.
* Removed `using namespace std` from all header files.
* Removed `plyr` dependency — replaced with `dplyr`/`purrr` equivalents.
* Moved `ggplot2` from Imports to Suggests.
* Replaced deprecated `purrr::map_dfr()` with `purrr::map() |> purrr::list_rbind()`.
* Replaced deprecated `dplyr::top_n()` with `dplyr::slice_max()`.
* Updated GitHub Actions to v4, removed legacy `.travis.yml`.
* Fixed documentation typos and improved `@return` tags for CRAN compliance.

# tglkmeans 0.5.8

* Fix: Registered "id" as a global variable to maintain compatibility with future versions of dplyr (addressing the removal of `dplyr::id()`).

# tglkmeans 0.5.7 

* Bug fix: crashed on some machines when `id_column=TRUE` and data had a single column.

# tglkmeans 0.5.6

* Removed parallelization for `hclust_intra_clusters` - it was causing hangs in some systems. The `parallel` parameter was removed from `TGL_kmeans` and `TGL_kmeans_tidy`. 

# tglkmeans 0.5.5 

* Fix: clustering crashed when `hclust_intra_clusters` was TRUE and input was a matrix. 

# tglkmeans 0.5.4

* Fixed usage of more than 2 cores when testing on CRAN. 

# tglkmeans 0.5.3

* Fix: colnames and rownames were removed in `downsample_matrix` function.

# tglkmeans 0.5.2

* Fixed docs. 

# tglkmeans 0.5.1

* Fix: `cluster` slot ids were corrupted when data was a tibble and `id_column` was `TRUE`.
* Fix: ids were not used when `id_column` was `FALSE` and data had rownames.

# tglkmeans 0.5.0

* Added `dowsample_matrix` function to downsample the columns of a count matrix to a target number. 

# tglkmeans 0.4.0

* Default of `id_column` parameter was changed to `FALSE`. Note that this is a breaking change, and if you want to use an id column, you need to set it explicitly to `TRUE`.
* Use R random number generator instead of C++11 random number generator. For backwards compatibility, the old random number generator can be used by setting `use_cpp_random` to `TRUE`.
* Added parallelization using `RcppParallel`. 

# tglkmeans 0.3.12

* Added validity checks for `k` and the number of observations. 

# tglkmeans 0.3.11

* Changed pkgdoc, see: https://github.com/r-lib/roxygen2/issues/1491.

# tglkmeans 0.3.10

* Removed broken link to one of the references in the description.

# tglkmeans 0.3.9

* Remove empty clusters. This may happen when the number of clusters is larger than the number of observations, and currently caused an error in the reordering step.

# tglkmeans 0.3.8

* Removed C++11 specification + require R >= 4.0.0.

# tglkmeans 0.3.6

* Fixed error on debian systems. 

# tglkmeans 0.3.5

* Changed errors from cpp to 1 based indexing.
* fix: loading the package failed on machines with a single core. 

# tglkmeans 0.3.4 

* First CRAN release.

# tglkmeans 0.3.3

* Set NA values to zeros in correlation matrix when reordering clusters 
(avoid crashing on some datasets with NA's in the `dist` object)

# tglkmeans 0.3.1

* Use rownames when exist.
* Do not fail when "id" column doesn't exist (warn instead).

# tglkmeans 0.3.0

* Removed bootstrapping (it was causing a lot of problems in travis testing and almost wasn't used).
* Added a `NEWS.md` file to track changes to the package.
