struct CatView{N, T, NR} <: AbstractVector{T}
    arr::NR
    len::NTuple{N,Int}
end

## Constructors ##
@inline CatView(a::AbstractVector...) = CatView(tuple(a...))

@generated function CatView(arr::NR) where NR<:Tuple
    N = length(NR.parameters)
    array_types = eltype(NR)
    array_types <: AbstractVector || throw(DomainError(array_types, "CatView is only valid on AbstractVectors."))
    T = eltype(array_types)

    quote
    len = @ntuple $N (n)->length(arr[n])
    CatView{$N, $T, $NR}(arr, len)
    end
end

## size ##
Base.size(A::CatView) = (sum(A.len),)

## get index and set index ##

function Base.getindex(A::CatView, i::Int)
    i < 1 || i > length(A) && throw(BoundsError("index out of bounds."))

    a = 0
    b = A.len[1]
    @inbounds for j = 1:length(A.len)
        if i <= b
            return A.arr[j][i-a]
        else
            a = b
            b = b + A.len[j+1]
        end
    end
end

function Base.setindex!(A::CatView, val, i::Int)
    i < 1 || i > length(A) && throw(BoundsError("index out of bounds."))

    a = 0
    b = A.len[1]
    @inbounds for j = 1:length(A.len)
        if i <= b
            A.arr[j][i-a] = val
            return val
        else
            a = b
            b = b + A.len[j+1]
        end
    end
end

#Base.@propagate_inbounds
function Base.getindex(A::CatView, idx::Tuple{Integer,Integer})
    i,j = idx
    return A.arr[i][j]
end

#Base.@propagate_inbounds
function Base.setindex!(A::CatView, val, idx::Tuple{Integer,Integer})
    i,j = idx
    return setindex!(A.arr[i], val, j)
end

## Fast iteration ##
@generated function Base.eachindex(A::CatView{N,T}) where {N,T}
    quote
    @nexprs $N (n)->(i_n = zip(repeated(n,length(A.arr[n])),eachindex(A.arr[n])))
    flatten( (@ntuple $N (n)->i_n) )
    end
end


function Base.mapreduce(f, op, A::CatView)
    reduce(op, mapreduce(f, op, aa) for aa in A.arr)
end
