using CatViews
using Base.Test

## Basic functions ##
@testset "CatView tests" begin
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

    ## Test other constructors
    x = CatView([1,2,3,4],[5,6,7,8])
    x = CatView(x,[9,10,11,12])
    @test length(x) == 12
    [ @test x[i] == i for i in 1:length(x) ]

    y = CatView([1,2,3,4],[5,6,7,8],[9,10,11,12])
    @test length(y) == 12
    [ @test y[i] == i for i in 1:length(y) ]

    ## Iteration
    x = CatView([1,2],[3,4])
    @test all(x .== [1,2,3,4])
end

@testset "splitview tests" begin
    ## splitview
    x,(A,B) = splitview(Int64,(2,3),(4,5))
    @test length(x) == 26
    @test size(A) == (2,3)
    @test size(B) == (4,5)
    [ x[i] = i for i = 1:6 ]
    @test A[1,1] == 1
    @test A[2,1] == 2
    @test A[2,3] == 6
    [ B[i] = i for i in eachindex(B) ]
    [ @test x[i+6] == i for i in 1:6 ]

    ## splitview
    x = collect(1:15)
    (A,B),y = splitview(x,(2,3),(3,2))

    @test size(A) == (2,3)
    @test size(B) == (3,2)
    for i = 1:6
        @test A[i] == i
        @test B[i] == 6+i
    end
    @test y == [13,14,15]

    x = collect(1:8)
    (A,B),y = splitview(x,(2,2),(2,2))
    @test isempty(y)
end
