module CatViews

using Base.Cartesian

export CatView

immutable CatView{T<:Number,N} <: AbstractArray
    arr::NTuple{N,AbstractVector{T}}
    len::NTuple{N,Integer}
end

Base.size(A::CatView) = (sum(A.len),)

# TODO: Base.@propagate_inbounds ?

Base.@propagate_inbounds function Base.getindex(A::CatView, i::Int)
    i < 1 || i > length(A) && throw("index out of bounds.")

    a = 0
    b = A.len[1]
    for j = 1:length(A.len)
        if i < b
            return A.arr[j][i-a]
        else
            a = b
            b = b + A.len[j+1]
        end
    end   
end

function CatView{T}(a::AbstractVector{T})
    CatView((a,),(length(a),))
end

function CatView{T}(a::AbstractVector{T},b::AbstractVector{T})
    CatView((a,b),(length(a),length(b)))
end

function CatView{T,N}(
        a::NTuple{N,AbstractVector{T}},
        b::AbstractVector{T}
    )

    CatView((a,b),(length(a),length(b)))
end

@generated function CatView{N,T}(arr::NTuple{N,AbstractArray{T}})
  quote
  len = @ntuple $N (n)->length(arr[n])
  CatView{T,N}(arr,len)
  end
end


end # module
