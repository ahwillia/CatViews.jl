__precompile__()

module CatViews

using Base.Cartesian
import Base.ReshapedArray
import Iterators: chain, repeated

export CatView, splitview, vecidx

include("catview.jl")
include("splitview.jl")

# end module
end