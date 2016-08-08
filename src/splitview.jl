@inline splitview(a::Tuple{Int,Int}...) = splitview(Float64,a)
@inline splitview{T}(::Type{T},a::Tuple{Int,Int}...) = splitview(T,a)
@inline splitview(x::AbstractVector,a::Tuple{Int,Int}...) = splitview(x,a)

@generated function splitview{T,N}(::Type{T},arr::NTuple{N,Tuple{Int,Int}})
    quote
      len = 0
      @nexprs $N (n)->(s_n = len+1; e_n = len+prod(arr[n]); len = e_n) 
      x = Array(T,len)
      X = @ntuple $N (n)->(reshape(view(x,s_n:e_n),arr[n]))
      return x,X
    end
end

@generated function splitview{T,N}(x::AbstractVector{T},arr::NTuple{N,Tuple{Int,Int}})
    quote
      len = 0
      @nexprs $N (n)->(s_n = len+1; e_n = len+prod(arr[n]); len = e_n) 
      X = @ntuple $N (n)->(reshape(view(x,s_n:e_n),arr[n]))
      return X,view(x,(len+1):length(x))
    end
end
