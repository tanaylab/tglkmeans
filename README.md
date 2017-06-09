# tglkmeans - efficient implementation of kmeans++ algorithm
https://bitbucket.org/aviezerl/tglkmeans

This package provides R binding to cpp implementation of kmeans++ algorithm (https://en.wikipedia.org/wiki/K-means%2B%2B).

Site for the package is at:
https://tanaylab.bitbucket.io/tglkmeans


### Code
Source code can be found at: https://bitbucket.org/aviezerl/tglkmeans


### Installation 

#### Installing tglkmeans package:
Download and install *tglkmeans*: 
```
devtools::install_bitbucket("aviezerl/tglkmeans", ref='default')
library(tglkmeans)
```

#### Using the package
Please refer to the package vignettes for usage, or look at the 'basic usage' section in the site.

```
browseVignettes('usage') 
```

#### Adding the package as dependency
In order to add tglkmeans as dependency in your package, add the following lines to the DESCRIPTION file:
```
Imports: 
	tglkmeans
Remotes: bitbucket::aviezerl/tglkmeans@default
```
