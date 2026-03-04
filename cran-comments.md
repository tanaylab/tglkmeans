## R CMD check results

0 errors | 0 warnings | 1 note

* This is an update to an existing CRAN package (previous version: 0.5.8).

## Changes in this version

* Added `predict_tgl_kmeans()` to assign new observations to existing cluster centers.
* Fixed memory leak (RAII with `unique_ptr`), Pearson distance sign bug, and several other correctness issues.
* Removed `plyr` dependency; moved `ggplot2` from Imports to Suggests.
* Replaced deprecated `purrr` and `dplyr` functions.
* Fixed macOS compiler warnings (`-Winconsistent-missing-override`).
* Updated GitHub Actions to v4.

## Test environments

* local: Ubuntu 22.04 (R 4.4.x)
* GitHub Actions: ubuntu-latest (R release, R devel), macOS-latest (R release), windows-latest (R release)

## Downstream dependencies

None known.
