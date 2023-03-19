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
