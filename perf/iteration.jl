using BenchmarkTools
using CatViews
import Base.Cartesian: @ntuple

x = CatView( @ntuple 1000 (n)->randn(10) )

@benchmark begin
    for xi in $x
        nothing
    end
end
