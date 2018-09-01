struct CatView{N,T<:Number} <: AbstractArray{T,1}
    arr::NTuple{N,SubArray{T}}
    len::NTuple{N,Integer}
    inner::NTuple{N}  # iterators for each array
end

## Constructors ##
@inline CatView(a::AbstractArray...) = CatView(a)

@generated function CatView(arr::NTuple{N,SubArray{T}}) where {N,T}
    quote
    len = @ntuple $N (n)->length(arr[n])
    inner = @ntuple $N (n)->eachindex(arr[n])
    CatView{N,T}(arr,len,inner)
    end
end

@generated function CatView(arr::NTuple{N,AbstractArray{T}}) where {N,T}
    quote
    CatView(@ntuple $N (n)->view(arr[n],:))
    end
end

## size ##
Base.size(A::CatView) = (sum(A.len),)

## get index and set index ##

function Base.getindex(A::CatView, i::Int)
    i < 1 || i > length(A) && throw(BoundsError("index out of bounds."))

    a = 0
    b = A.len[1]
    for j = 1:length(A.len)
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
    for j = 1:length(A.len)
        if i <= b
            A.arr[j][i-a] = val
            return val
        else
            a = b
            b = b + A.len[j+1]
        end
    end   
end

function Base.getindex(A::CatView, idx::Tuple{Integer,Integer})
    i,j = idx
    return A.arr[i][j]
end

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
