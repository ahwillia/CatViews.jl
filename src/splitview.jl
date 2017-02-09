@inline splitview(a::Tuple...) = splitview(Float64,a)
@inline splitview{T}(::Type{T},a::Tuple...) = splitview(T,a)
@inline splitview(x::AbstractVector,a::Tuple...) = splitview(x,a)

@generated function splitview{T,N}(::Type{T},arr::NTuple{N,Tuple})
    quote
      len = 0
      @nexprs $N (n)->(s_n = len+1; e_n = len+prod(arr[n]); len = e_n) 
      x = Array{T}(len)
      X = @ntuple $N (n)->(reshape(view(x,s_n:e_n),arr[n]))
      start = @ntuple $N (n)->(s_n)
      stop = @ntuple $N (n)->(e_n)
      return x,X,start,stop
    end
end

@generated function splitview{T,N}(x::AbstractVector{T},arr::NTuple{N,Tuple})
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
typealias FastContiguousSubArray{T,N,P,I<:Tuple{Union{Colon, UnitRange}, Vararg{Any}}} SubArray{T,N,P,I,true}

parentindex(A::FastContiguousSubArray, i::Int) = A.offset1 + i
parentindex(A::FastContiguousSubArray, i::Int...) = A.offset1 + prod(i)
parentindex{N}(A::FastContiguousSubArray, i::NTuple{N,Int}) = A.offset1 + prod(i)

@inline parentindex(A::ReshapedArray, i::Int...) = sub2ind(size(A), i...)
parentindex{N}(A::ReshapedArray, i::NTuple{N,Int}) = sub2ind(size(A), i...)

vecidx(A::Array, i::Int) = i

vecidx(A::FastContiguousSubArray, i::Int) = vecidx(A.parent, parentindex(A, i))
@inline vecidx(A::FastContiguousSubArray, i::Int...) = vecidx(A.parent, parentindex(A, i...))
vecidx{N}(A::FastContiguousSubArray, i::NTuple{N,Int}) = vecidx(A.parent, parentindex(A, i))

@inline vecidx(A::ReshapedArray, i::Int...) = vecidx(A.parent, parentindex(A, i...))
vecidx{N}(A::ReshapedArray, i::NTuple{N,Int}) = vecidx(A.parent, parentindex(A, i))
