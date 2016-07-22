@inline vecmats(a::Tuple{Int,Int}...) = vecmats(Float64,a)
@inline vecmats{T}(::Type{T},a::Tuple{Int,Int}...) = vecmats(T,a)

@generated function vecmats{T,N}(::Type{T},arr::NTuple{N,Tuple{Int,Int}})
    quote
    len = 0
    @nexprs $N (n)->(s_n = len+1; e_n = len+prod(arr[n]); len = e_n) 
    x = Array(T,len)
    X = @ntuple $N (n)->(reshape(view(x,s_n:e_n),arr[n]))
    return x,X
    end
end

