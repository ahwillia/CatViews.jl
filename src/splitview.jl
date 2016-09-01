@inline splitview(a::Tuple...) = splitview(Float64,a)
@inline splitview{T}(::Type{T},a::Tuple...) = splitview(T,a)
@inline splitview(x::AbstractVector,a::Tuple...) = splitview(x,a)

@generated function splitview{T,N}(::Type{T},arr::NTuple{N,Tuple})
    quote
      len = 0
      @nexprs $N (n)->(s_n = len+1; e_n = len+prod(arr[n]); len = e_n) 
      x = Array(T,len)
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
