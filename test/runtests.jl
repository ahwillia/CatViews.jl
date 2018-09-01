using CatViews
using Test
using Random: randn!

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
    @testset "without preallocation" begin

        x,(A,B),s,e = splitview(Int64,(2,3),(4,5))
        
        # test sizes
        @test length(x) == 26
        @test size(A) == (2,3)
        @test size(B) == (4,5)
        @test eltype(A) == Int64
        @test eltype(B) == Int64

        # test partititions between vectors
        @test s == (1,7)
        @test e == (6,26)

        # set A to 1:6 by mutating x
        [ x[i] = i for i = s[1]:e[1] ]
        @test all(A == [1 3 5; 2 4 6])

        # set B to 1:20 by mutating it directly
        [ B[i] = i for i in 1:length(B) ]
        [ @test x[i+6] == i for i in 1:20 ]

        # test on a higher-order array
        sz1 = (2,2,2)
        sz2 = (2,3,2)
        sz3 = (3,2,2)
        x,(A,B,C),s,e = splitview(Int64,sz1,sz2,sz3)

        @test size(A) == sz1
        @test size(B) == sz2
        @test size(C) == sz3
        @test s == (1, length(A)+1, length(A)+length(B)+1)
        @test e == (length(A), length(A)+length(B), length(A)+length(B)+length(C))
    end

    @testset "with preallocation" begin
        
        # preallocate x
        x = collect(1:26)
        (A,B),s,e = splitview(x,(2,3),(4,5))

        #test sizes 
        @test size(A) == (2,3)
        @test size(B) == (4,5)
        @test s == (1,7)
        @test e == (6,26)

        # test that A and B faithfully view into x
        for i = 1:6
            @test A[i] == i
            @test B[i] == 6+i
        end

        # test on higher-order array
        sz1 = (2,2,2)
        sz2 = (2,3,2)
        sz3 = (3,2,2)
        N = prod(sz1)+prod(sz2)+prod(sz3)
        x = collect(1:N)
        (A,B,C),s,e = splitview(x,sz1,sz2,sz3)

        @test eltype(A) == Int
        @test size(A) == sz1
        @test size(B) == sz2
        @test size(C) == sz3
        @test s == (1, length(A)+1, length(A)+length(B)+1)
        @test e == (length(A), length(A)+length(B), length(A)+length(B)+length(C))

        # test that arrays correctly hold 1:N
        for (i,j,X) in zip(s,e,(A,B,C))
            for (xi,Xi) in zip(i:j,eachindex(X))
                @test x[xi] == X[Xi] == xi
            end
        end

    end
end

@testset "indexing" begin

    x,children, = splitview(Int64,(3,3),(2,2,2,2,2,2),(4,5,2),(10,),(1,10),(3,3))
    copyto!(x,1:length(x))

    for child in children
        for child_idx = eachindex(child)
            parent_idx = vecidx(child, child_idx)
            @test x[parent_idx] == child[child_idx]
        end
    end

    for child in children
        d = size(child)
        for i = 1:prod(d)
            idx = Tuple(CartesianIndices(d)[i])
            pi1 = vecidx(child, idx)
            pi2 = vecidx(child, idx...)
            @test x[pi1] == x[pi2] == child[idx...] == child[i]
        end
    end

end
