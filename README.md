
<!-- badges: start -->

[![Travis build
status](https://travis-ci.com/tanaylab/tglkmeans.svg?branch=master)](https://travis-ci.org/tanaylab/tglkmeans)
[![Codecov test
coverage](https://codecov.io/gh/tanaylab/tglkmeans/branch/master/graph/badge.svg)](https://codecov.io/gh/tanaylab/tglkmeans?branch=master)
<!-- badges: end -->

# tglkmeans - efficient implementation of kmeans++ algorithm

This package provides R binding to a cpp implementation of kmeans++
algorithm (<https://en.wikipedia.org/wiki/K-means%2B%2B>).

### Installation

``` r
install.packages('tglkmeans', repos=c(getOption('repos'), 'https://tanaylab.github.io/repo'))
```

#### Using the package

Please refer to the package vignettes for usage and workflow, or look at
the [usage](https://tanaylab.github.io/tglkmeans/articles/usage.html)
section in the site.

``` r
browseVignettes('usage') 
```
