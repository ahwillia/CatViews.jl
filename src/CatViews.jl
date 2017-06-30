__precompile__()

module CatViews

using Base.Cartesian
import Base.ReshapedArray
import IterTools: chain, repeated

export CatView, splitview, vecidx

include("catview.jl")
include("splitview.jl")

# end module
end
