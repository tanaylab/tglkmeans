
<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/tglkmeans)](https://CRAN.R-project.org/package=tglkmeans)
[![Codecov test
coverage](https://codecov.io/gh/tanaylab/tglkmeans/branch/master/graph/badge.svg)](https://app.codecov.io/gh/tanaylab/tglkmeans?branch=master)
<!-- badges: end -->

# tglkmeans - efficient implementation of kmeans++ algorithm

This package provides R binding to a cpp implementation of the [kmeans++
algorithm](<https://en.wikipedia.org/wiki/K-means%2B%2B>).

## Installation

You can install the released version of **tglkmeans** using the
following command:

``` r
install.packages('tglkmeans')
```

Or install the development version using:

``` r
if (!require("remotes")) install.packages("remotes")
remotes::install_github("tanaylab/tglkmeans")
```

## Basic usage

``` r
library(tglkmeans)
```

Create 5 clusters normally distributed around 1 to 5, with sd of 0.3:

``` r
data <- rbind(matrix(rnorm(100, mean = 1, sd = 0.3), ncol = 2),
              matrix(rnorm(100, mean = 2, sd = 0.3), ncol = 2),
              matrix(rnorm(100, mean = 3, sd = 0.3), ncol = 2),
              matrix(rnorm(100, mean = 4, sd = 0.3), ncol = 2),
              matrix(rnorm(100, mean = 5, sd = 0.3), ncol = 2))
colnames(data) <- c("x", "y")
head(data)
#>              x         y
#> [1,] 1.6039844 0.7245403
#> [2,] 0.8581481 0.7696879
#> [3,] 1.0442647 1.2516017
#> [4,] 0.7696542 1.5545830
#> [5,] 0.5586013 0.7805132
#> [6,] 1.6963144 0.8346386
```

Cluster using kmeans++:

``` r
km <- TGL_kmeans(data, k=5, id_column = FALSE)
km
#> $cluster
#>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20 
#>   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4 
#>  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40 
#>   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4 
#>  41  42  43  44  45  46  47  48  49  50  51  52  53  54  55  56  57  58  59  60 
#>   4   4   4   4   4   4   4   4   4   4   3   3   3   3   3   3   3   3   3   3 
#>  61  62  63  64  65  66  67  68  69  70  71  72  73  74  75  76  77  78  79  80 
#>   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3 
#>  81  82  83  84  85  86  87  88  89  90  91  92  93  94  95  96  97  98  99 100 
#>   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3   3 
#> 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 
#>   1   1   1   1   1   1   1   1   1   2   1   1   1   1   1   1   1   1   1   1 
#> 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 
#>   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1 
#> 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 
#>   1   1   1   1   1   1   1   1   1   1   2   2   2   2   2   2   5   2   2   2 
#> 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 
#>   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2 
#> 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 
#>   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2 
#> 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 
#>   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5 
#> 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 
#>   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5 
#> 241 242 243 244 245 246 247 248 249 250 
#>   5   5   5   5   5   5   5   5   5   5 
#> 
#> $centers
#>             x         y
#> [1,] 2.954139 3.0003254
#> [2,] 3.982430 4.0727830
#> [3,] 2.038905 2.0517421
#> [4,] 1.017625 0.9381206
#> [5,] 4.984231 4.9377022
#> 
#> $size
#>  1  2  3  4  5 
#> 49 50 50 50 51
```

Plot the results:

``` r
plot(data, col = km$cluster)
points(km$centers, pch=8, cex=2)
```

![](README-clustering-1.png)<!-- -->

## Vignette

Please refer to the package vignettes for usage and workflow, or look at
the [usage](https://tanaylab.github.io/tglkmeans/articles/usage.html)
section in the site.

``` r
browseVignettes('usage') 
```
