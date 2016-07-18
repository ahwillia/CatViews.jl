using CatViews
import Base.LinAlg: axpy!

# data params
m,n = 1000,500  # dimensions
r = 5           # rank
ξ = 1e-4        # noise level

# True loadings and components
Wtr = randn(m,r)
Ctr = randn(r,n)

# noisy, low-rank data
A = Wtr*Ctr + randn(m,n)*ξ

# random, initial guess for optimization
W = randn(m,r)
C = randn(r,n)

# storage for gradients
∇W = similar(W)
∇C = similar(C)

## PCA model ##
abstract Model
immutable PCA{T<:AbstractFloat} <: Model
    A::AbstractMatrix{T}
    W::AbstractMatrix{T}
    C::AbstractMatrix{T}
    ∇W::AbstractMatrix{T}
    ∇C::AbstractMatrix{T}
end
model = PCA(A,W,C,∇W,∇C)

value{T}(model::PCA{T}) = convert(T,0.5)*sumabs2(model.A - model.W*model.C)

function value_grad!{T}(m::PCA{T})
    resid = m.W*m.C - m.A
    At_mul_B!(m.∇C,m.W,resid)
    A_mul_Bt!(m.∇W,resid,m.C)
    return convert(T,0.5)*sumabs2(resid) # objective val
end

## Gradient Descent Optimization Type ##
abstract Optimizer
type GradDescent{T<:AbstractFloat} <: Optimizer
    ρ::T    # stepsize
    β::T    # backtracking linesearch
    function GradDescent(ρ::T,β::T)
        0 < β < 1 || error("β needs to be between 0 and 1.")
        ρ > 0 || error("ρ must be positive")
        new(ρ,β)
    end
end
GradDescent{T<:AbstractFloat}(ρ::T=1.0) = GradDescent{T}(ρ,convert(T,0.5))
opt = GradDescent()

# collect optimization variables into a vector
x = CatView(view(W,:),view(C,:))
∇x = CatView(view(∇W,:),view(∇C,:))

function update!(x::CatView,∇x::CatView,model::Model,opt::GradDescent)
    f = value_grad!(model)      # update ∇x
    axpy!(-opt.ρ,∇x,x)          # updates model params
    f_next = value(model)
    while f_next > f
        s = opt.ρ*opt.β         # smaller stepsize
        axpy!(opt.ρ-s,∇x,x)     # backtrack
        opt.ρ = s               # update stepsize
        f_next = value(model)
        opt.ρ < 1e-10 && break
    end
    return f_next
end

iterations = 100
f_trace = [ update!(x,∇x,model,opt) for iter in 1:iterations ]

