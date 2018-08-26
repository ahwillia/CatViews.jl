@inline splitview(a::Tuple...) = splitview(Float64,a)
@inline splitview(::Type{T},a::Tuple...) where {T} = splitview(T,a)
@inline splitview(x::AbstractVector,a::Tuple...) = splitview(x,a)

@generated function splitview(::Type{T},arr::NTuple{N,Tuple}) where {T,N}
    quote
      len = 0
      @nexprs $N (n)->(s_n = len+1; e_n = len+prod(arr[n]); len = e_n)
      x = Array{T}(undef, len)
      X = @ntuple $N (n)->(reshape(view(x,s_n:e_n),arr[n]))
      start = @ntuple $N (n)->(s_n)
      stop = @ntuple $N (n)->(e_n)
      return x,X,start,stop
    end
end

@generated function splitview(x::AbstractVector{T},arr::NTuple{N,Tuple}) where {T,N}
    quote
      len = 0
      @nexprs $N (n)->(s_n = len+1; e_n = len+prod(arr[n]); len = e_n)
      X = @ntuple $N (n)->(reshape(view(x,s_n:e_n),arr[n]))
      start = @ntuple $N (n)->(s_n)
      stop = @ntuple $N (n)->(e_n)
      return X,start,stop
    end
end

# unexported from Base
const FastContiguousSubArray{T,N,P,I<:Tuple{Union{Colon, UnitRange}, Vararg{Any}}} = SubArray{T,N,P,I,true}

parentindex(A::FastContiguousSubArray, i::Int) = A.offset1 + i
parentindex(A::FastContiguousSubArray, i::Int...) = A.offset1 + prod(i)
parentindex(A::FastContiguousSubArray, i::NTuple{N,Int}) where {N} = A.offset1 + prod(i)

@inline parentindex(A::ReshapedArray, i::Int...) = LinearIndices(size(A))[i...]
parentindex(A::ReshapedArray, i::NTuple{N,Int}) where {N} = LinearIndices(size(A))[i...]

vecidx(A::Array, i::Int) = i

vecidx(A::FastContiguousSubArray, i::Int) = vecidx(A.parent, parentindex(A, i))
@inline vecidx(A::FastContiguousSubArray, i::Int...) = vecidx(A.parent, parentindex(A, i...))
vecidx(A::FastContiguousSubArray, i::NTuple{N,Int}) where {N} = vecidx(A.parent, parentindex(A, i))

@inline vecidx(A::ReshapedArray, i::Int...) = vecidx(A.parent, parentindex(A, i...))
vecidx(A::ReshapedArray, i::NTuple{N,Int}) where {N} = vecidx(A.parent, parentindex(A, i))
