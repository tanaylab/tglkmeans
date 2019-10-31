
<!-- badges: start -->

[![Travis build
status](https://travis-ci.com/tanaylab/tglkmeans.svg?branch=master)](https://travis-ci.org/tanaylab/tglkmeans)
[![Codecov test
coverage](https://codecov.io/gh/tanaylab/tglkmeans/branch/master/graph/badge.svg)](https://codecov.io/gh/tanaylab/tglkmeans?branch=master)
<!-- badges: end -->

# tglkmeans - efficient implementation of kmeans++ algorithm

This package provides R binding to a cpp implementation of kmeans++
algorithm (<https://en.wikipedia.org/wiki/K-means%2B%2B>).

## Installation

You can install the released version of **tglkmeans** using the
following command:

``` r
install.packages('tglkmeans', repos=c(getOption('repos'), 'https://tanaylab.github.io/repo'))
```

Or install the develpoment version using:

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
#> [1,] 0.9530238 0.9418766
#> [2,] 1.0596298 1.1345286
#> [3,] 0.7937045 0.6180217
#> [4,] 1.3955778 1.7674674
#> [5,] 0.9952293 1.2766231
#> [6,] 1.3500851 1.9758635
```

Cluster using kmeans++:

``` r
km <- TGL_kmeans(data, k=5, id_column = FALSE)
km
#> $cluster
#>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18 
#>   2   2   2   3   2   3   2   2   2   2   2   2   2   2   2   2   2   2 
#>  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36 
#>   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2 
#>  37  38  39  40  41  42  43  44  45  46  47  48  49  50  51  52  53  54 
#>   2   2   2   2   2   2   2   2   2   2   2   2   2   2   3   3   3   3 
#>  55  56  57  58  59  60  61  62  63  64  65  66  67  68  69  70  71  72 
#>   3   3   3   2   3   3   3   3   3   3   3   3   3   3   3   3   3   3 
#>  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88  89  90 
#>   3   3   3   3   3   5   3   3   3   3   2   3   3   3   3   3   3   3 
#>  91  92  93  94  95  96  97  98  99 100 101 102 103 104 105 106 107 108 
#>   3   3   3   3   3   3   3   3   3   3   5   5   5   5   5   5   5   5 
#> 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 
#>   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5 
#> 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 
#>   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5   5 
#> 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 
#>   5   5   5   5   5   5   1   1   1   1   1   1   1   1   1   1   1   1 
#> 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 
#>   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1 
#> 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 
#>   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1 
#> 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 
#>   1   1   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4 
#> 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 
#>   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4 
#> 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 
#>   4   4   4   4   4   4   4   4   4   4   1   4   4   4   4   4 
#> 
#> $centers
#>              x         y
#> [1,] 3.9679554 4.0043440
#> [2,] 0.9621912 0.9825687
#> [3,] 1.9740058 1.9784214
#> [4,] 5.0905957 5.0127778
#> [5,] 2.9860275 2.9522712
#> 
#> $size
#>  1  2  3  4  5 
#> 51 50 49 49 51
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
