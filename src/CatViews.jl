#__precompile__()

module CatViews

using Base.Cartesian
import Iterators: chain, repeated

export CatView, vecmats

include("catview.jl")
include("vecmats.jl")

# end module
end