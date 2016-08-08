__precompile__()

module CatViews

using Base.Cartesian
import Iterators: chain, repeated
import Compat: view

export CatView, splitview

include("catview.jl")
include("splitview.jl")

# end module
end