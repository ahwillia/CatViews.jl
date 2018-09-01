# CatViews

[![Build Status](https://travis-ci.org/ahwillia/CatViews.jl.svg?branch=master)](https://travis-ci.org/ahwillia/CatViews.jl)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)

<img src="http://i.imgur.com/OHtZ2HZ.jpg" width="300px">

In optimization and machine learning, model parameters can be distributed across multiple arrays and can interact in complex ways.
However, it can be useful to abstract away these details (e.g. when computing gradients) and collect all the parameters into a single vector.
This is a lightweight package that enables you to switch between these two perspectives seemlessly.

CatViews exports two main things:

* **`CatView`** - An array that can represent a sequence of preallocated arrays within a vector. 
* **`splitview`** - A function that produces a sequence of new arrays as views into a vector.

Both of these functions make use of array [`view`s](http://docs.julialang.org/en/latest/stdlib/arrays/?highlight=view#Base.view) so that ***copying is not required!***

In general, you should use `splitview` when you know the array shapes beforehand, and only use `CatView` when you don't have access to this information. Iterating through the parameter vector should be faster if you use `splitview`.

### `splitview` documentation

In the following example, we create two matrices `A` and `B` that are linked to a parameter vector `x`.

```julia
x, (A, B) = splitview((2, 3), (3, 2))

# mutating x updates A and B
x[1:6] = 1:6
x[7:12] = -6:-1

@show A  # prints [1 3 5; 2 4 6]
@show B  # prints [-6 -3; -5 -2; -4 -1]
```

Under the hood, `A` and `B` are reshaped [`view`](http://docs.julialang.org/en/latest/stdlib/arrays/?highlight=view#Base.view)s into `x`.
Reshaping a view does not causing copying in Julia as of v0.5

You can also get a list of the indices in `x` that represent the start and end of the arrays:

```julia
using Random: randn!
x, (A, B, C), s, e = splitview((3, 3), (3, 3), (3, 3, 3))
for X in (A, B, C)
  randn!(X)
end
x[s[1]:e[1]] .== vec(A)
x[s[2]:e[2]] .== vec(B)
x[s[3]:e[3]] .== vec(C)
```

#### Use `vecidx` to get the index into the parent array

CatViews also exports a simple function that allows you to match indices between the parameter vector and the reshaped matrices:

```julia
x, (A, B) = splitview((2, 3), (3, 2))

# fill x with random numbers
randn!(x)

i = vecidx(A, 2, 1) # i == 2
x[i] == A[2, 1]

j = vecidx(B,(3, 2)) # j == 12
x[j] == B[3, 2]
```


### `CatView` documentation

Suppose we have `A` and `B` already preallocated, and we want to represent them as a parameter vector `x`:

```julia
A = randn(10, 10);   # imagine this is a large matrix so copying is really undesirable
B = randn(10, 10);   # imagine this is also large so copying totally sucks
a = view(A, :);      # vector view of A, no copying
b = view(B, :);      # vector view of B, no copying
x = vcat(a, b);      # ACK!! causes copying!!
typeof(x)            # returns Array, rather than SubArray
```

Furthermore, if you mutate `x` in this example, the chances aren't automatically reflected in `A` and `B`.

```julia
A = randn(10, 10);
B = randn(10, 10);
a = view(A, :);      # no copying
b = view(B, :);      # no copying
x = CatView(a, b);   # no copying!!!
```

You can treat `x` as you would any other vector in Julia! Like `splitview`, mutating `x` will also update `A` and `B`:

```julia
x[1:3] = 999
@show A[1:4, 1:4]
```

```
4×4 Array{Float64,2}:
 999.0       0.0188983  -0.720472   1.01939  
 999.0       2.4073     -2.52788   -0.0497283
 999.0      -1.9217     -0.256222   0.642362 
 1.52075  -0.173562    0.604112  -0.574269 
```

Did I mention that this happens without copying? That's kind of the whole point.

### Why is this useful?

See [`examples/pca.jl`](https://github.com/ahwillia/CatViews.jl/blob/master/examples/pca.jl) for a self-contained use case of `CatView`s. In this optimization problem, there are two matrices (corresponding to the principal components and loadings) of optimization variables. Concatenating these variables into a single vector would provide a way to link this model to many generic optimization solvers. A `CatView` is a very simple way to do this. It avoids unnecessary copy operations (a potential performance enhancement) and also simplifies the code to implement this.
