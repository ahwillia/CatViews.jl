__precompile__()

module CatViews

using Base.Cartesian
import Base.ReshapedArray
isdefined(Base, :Iterators) && (const repeated = Base.Iterators.repeated)
import Iterators: chain, repeated

export CatView, splitview, vecidx

include("catview.jl")
include("splitview.jl")

# end module
end
