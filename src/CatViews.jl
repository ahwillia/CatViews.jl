__precompile__()

module CatViews

using Base.Cartesian
import Base.ReshapedArray
using Base.Iterators: repeated, flatten

export CatView, splitview, vecidx

include("catview.jl")
include("splitview.jl")

# end module
end
