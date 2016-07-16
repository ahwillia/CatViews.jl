using CatViews
using Base.Test

## Basic functions ##
x = CatView([1,2,3,4],[5,6,7,8])

@test length(x) == 8
@test ndims(x) == 1
[ @test x[i] == i for i in 1:length(x) ]
@test x[end] == 8
@test_throws BoundsError x[0]
@test_throws BoundsError x[9]

a = randn(10,10)
b = randn(9,9)

x = CatView(view(a,:,2),view(b,:,3))
@test length(x) == 19
[ @test x[i] == a[i,2] for i in 1:size(a,1) ]
[ @test x[size(a,1)+i] == b[i,3] for i in 1:size(b,1) ]

## Test mutates original object
x[1] = 55
@test a[1,2] == 55.0
x[1:3] = [55, 56, 57]
@test a[1,2] == 55.0
@test a[2,2] == 56.0
@test a[3,2] == 57.0

randn!(x)
@test isapprox(a[:,2],x[1:10])
@test isapprox(b[:,3],x[11:end])

## Matrix multiply
c = vcat(a[:,2],b[:,3])
A = randn(19,19)
@test isapprox(A*c,A*x)
