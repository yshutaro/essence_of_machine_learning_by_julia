module svm_soft
using LinearAlgebra

mutable struct SVC
    a_
    w_
    w0_
    C
    max_iter::Int
    function SVC(C=1.)
        new(Nothing, Nothing, Nothing, C, 10000)
    end
end

function fit(s::SVC, X, y)
    a = zeros(size(X)[1])
    ay = 0
    ayx = zeros(size(X)[2])
    yx = y .* X
    for i in 1:s.max_iter
        ydf = y .* (1 .- (yx * ayx))
        i = findfirst(ydf .== minimum(ydf[((a .> 0) .& (y .> 0)) .| ((a .< s.C) .& (y .< 0))]))
        j = findfirst(ydf .== maximum(ydf[((a .> 0) .& (y .< 0)) .| ((a .< s.C) .& (y .> 0))]))
        if ydf[i] >= ydf[j]
            break
        end
        ay2 = ay - y[i]*a[i] - y[j]*a[j]
        ayx2 = ayx .- y[i]*a[i].*X[i, :] .- y[j]*a[j].*X[j, :]
        ai = (1 - y[i]*y[j] + y[i] * dot( (X[i, :] .- X[j, :]) , (X[j, :] .* ay2 .- ayx2) ) ) / sum((X[i, :] .- X[j, :]).^2)
        if ai < 0
            ai = 0
        elseif ai > s.C
            ai = s.C
        end
        aj = (-ai * y[i] - ay2) * y[j]
        if aj < 0
            aj = 0
            ai = (-aj * y[j] - ay2) * y[i]
        elseif aj > s.C
            aj = s.C
            ai = (-aj * y[j] - ay2) * y[i]
        end
        ay = ay + y[i] * (ai - a[i]) + y[j] * (aj -a[j])
        ayx = ayx .+ y[i] * (ai - a[i]) .* X[i, :] + y[j] * (aj -a[j]) .* X[j, :]
        if ai == a[i]
            break
        end
        a[i] = ai
        a[j] = aj
    end
    s.a_ = a
    ind = a .!= 0.
    s.w_ = sum((a[ind] .* y[ind]) .* X[ind, :], dims=1)
    s.w0_ = sum(y[ind] .- (X[ind, :] * (s.w_)')) / sum(ind)
end

function predict(s::SVC, X)
    sign.(s.w0_ .+ X * (s.w_)')
end

end
