# tglkmeans (development version)

# tgkmeans 0.3.11

* Changed pkgdoc, see: https://github.com/r-lib/roxygen2/issues/1491.

# tgkmeans 0.3.10

* Removed broken link to one of the references in the description.

# tgkmeans 0.3.9

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
