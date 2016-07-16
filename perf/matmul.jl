using BenchmarkTools
using CatViews
import Base.Cartesian: @ntuple

A = randn(5000,5000)
x = CatView( @ntuple 500 (n)->randn(10) )

@benchmark ($A)*($x) 
