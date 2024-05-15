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
