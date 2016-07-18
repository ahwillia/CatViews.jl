# CatViews

[![Build Status](https://travis-ci.org/ahwillia/CatViews.jl.svg?branch=master)](https://travis-ci.org/ahwillia/CatViews.jl)

<img src="http://i.imgur.com/OHtZ2HZ.jpg" width="300px">

An efficient way of viewing the contents of an array (and avoid copying) is to create a `SubArray` type. In v0.5 this is done with the `view` command:

```julia
A = randn(10000,10000);  # a large matrix
a = A[:,1];              # this creates a copy of the first column
b = view(A,:,1);         # lets you view the first column, without copying
all(a .== b)             # returns true
```

In some cases, you may have two views into two separate matrices, and you'd like to concatenate them into a single view. This, however, causes copying.

```julia
A = randn(10000,10000);  # a large matrix
B = randn(10000,10000);  # another large matrix
a = view(A,:,1);         # no copying
b = view(B,:,1);         # no copying
c = vcat(a,b);           # causes copying!!
typeof(c)                # returns Array, rather than SubArray
```

This package proposes a potential solution to this (arguably) undesirable behavior. A `CatView` object contains 

```julia
A = randn(10000,10000);  # a large matrix
B = randn(10000,10000);  # another large matrix
a = view(A,:,1);         # no copying
b = view(B,:,1);         # no copying
c = CatView(a,b);        # no copying!!
```

You can treat `c` as you would any other vector in Julia!

### Why is this useful?

See [`examples/pca.jl`](https://github.com/ahwillia/CatViews.jl/blob/master/examples/pca.jl) for a self-contained use case of `CatView`s. In this optimization problem, there are two matrices (corresponding to the principal components and loadings) of optimization variables. Concatenating these variables into a single vector would provide a way to link this model to many generic optimization solvers. A `CatView` is a very simple way to do this. It avoids unnecessary copy operations (a potential performance enhancement) and also simplifies the code to implement this.

### Disclaimers

At the moment, this package only supports concatenation of vector views of Arrays (see `examples\pca.jl` for why this is useful). Concatenation of higher-order `SubArray`s could probably be accomplished, but they are not high priority. Open an issue if you think there is a good use case for this.

This is an experiment. Operations on `CatView`s should generally be outperformed by memory-contiguous Arrays. However, preliminary results seem promising to me at least. As with any `SubArray`, certain computations (e.g. matrix multiply) will cause copying.
