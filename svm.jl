module svm
using LinearAlgebra

mutable struct RBFKernel
    X
    σ2
    values_
    function RBFKernel(X, σ)
        new(X, σ^2, similar(Array{Float64}, (size(X)[1],size(X)[1])))
    end
end

value(obj::RBFKernel, i, j)  = exp((sum(-(obj.X[i, :] .- obj.X[j, :]).^2)) / (2*obj.σ2))

function eval(obj::RBFKernel, Z, s)
   # println("obj.X[hcat(s, s)] ", obj.X[hcat(s, s)] )
    #exp(-(sum((obj.X[s, 1, :] .- Z[1, : , :]).^2,dims=2) / 2(obj.σ2)))
    XX = obj.X[hcat(s, s)]
    X_Z = [sum((XX[i, :] .- Z[j, :]).^2) for i in 1:size(XX)[1], j in 1:size(Z)[1]]
    println("size(X_Z) :",size(X_Z))
    col, row = size(X_Z)
    if (col, row) == (0, 0)
        return []
    end
    println("(X_Z) :",(X_Z))
    println("(2*obj.σ2)",(2*obj.σ2))
    exp.(-X_Z ./ (2*obj.σ2))
end

mutable struct SVC
   a_
   w0_
   y_
   kernel_
   C::Float64
   σ
   max_iter::Int
   function SVC()
       new(Nothing, Nothing, Nothing, Nothing, 1., 1, 10000)
   end
end

function fit(obj::SVC, X, y)
    a = zeros(size(X)[1])
    ay = 0
    kernel = RBFKernel(X, obj.σ)
    for i in 1:obj.max_iter
        s = a .!= 0.
        println("a :",a)
        println("s :",s)
        println("size(y) :",size(y))
        println("size(a[s]) :",size(a[s]))
        println("size(y[s]) :",size(y[s]))
        #println("size svm.eval(kernel, X, s)",size(svm.eval(kernel, X, s)))
        println("a[s].*y[s] :", a[s].*y[s])
        println("a[s].*y[s] :", a[s].*y[s])
        println("svm.eval(kernel, X, s), ", svm.eval(kernel, X, s))
        println("dot(a[s].*y[s], svm.eval(kernel, X, s)) : ", dot.(a[s].*y[s], svm.eval(kernel, X, s)))
        if isempty(a[s].*y[s]) || svm.eval(kernel, X, s)
            ydf = y
        else
            #ydf = y .* (1 .- y .* dot.(a[s].*y[s], svm.eval(kernel, X, s)))
            ydf = y .* (1 .- y .* ( (a[s].*y[s]) * svm.eval(kernel, X, s)) )
        end
        println("ydf size : ", size(ydf))
        i = findfirst(ydf .== minimum(ydf[((a .> 0) .& (y .> 0)) .| ((a .< obj.C) .& (y .< 0))]))
        println("i :", i)
        j = findfirst(ydf .== maximum(ydf[((a .> 0) .& (y .< 0)) .| ((a .< obj.C) .& (y .> 0))]))
        println("j :", j)
        if ydf[i] >= ydf[j]
            break
        end

        ay2 = ay - y[i]*a[i] - y[j]*a[j]
        println("ay2 :", ay2)
        kii = svm.value(kernel, i, i)
        println("kii :", kii)
        kij = svm.value(kernel, i, j)
        println("kij :", kij)
        kjj = svm.value(kernel, j, j)
        println("kjj :", kjj)
        s = a .!= 0.
        println("s :", s)
        println("s size:", size(s))
        s[i] = false
        s[j] = false
        # TODO
        println("X[i, :] :", X[i, :]  )
        kxi = vec(svm.eval(kernel, X[i, :], s))
        println("kxi :", kxi)
        kxj = vec(svm.eval(kernel, X[j, :], s))
        println("kxj :", kxj)
        println("(kii + kjj - 2*kij): ", (kii + kjj - 2*kij))
        println("(kij - kjj)*ay2 : ", (kij - kjj)*ay2 )
        println("a[s].*y[s].*(kxi .- kxj) :", a[s].*y[s].*(kxi .- kxj))
        println("sum(a[s].*y[s].*(kxi .- kxj)) :", sum( (a[s].*y[s].*(kxi .- kxj) == []) ? 0 : a[s].*y[s].*(kxi .- kxj) ) )
        ai = (1 - y[i]*y[j] + y[i]*( (kij - kjj)*ay2 - sum( (a[s].*y[s].*(kxi .- kxj) == []) ? 0 : a[s].*y[s].*(kxi .- kxj) ) ) ) / (kii + kjj - 2*kij)
        println("ai :", ai)
        if ai < 0
            ai = 0
        elseif ai > obj.C
            ai = obj.C
        end

        aj = (-ai*y[i] - ay2)*y[i]
        if aj < 0
            aj = 0
            ai = (-ai*y[i] - ay2)*y[i]
        elseif aj > obj.C
            aj = obj.C
            ai = (-ai*y[i] - ay2)*y[i]
        end
        ay = ay + y[i] * (ai - a[i]) + y[j] * (aj -a[j])
        if ai == a[i]
            break
        end
        a[i] = ai
        a[j] = aj
    end
    obj.a_ = a
    obj.y_ = y
    obj.kernel_ = kernel
    s = a .!= 0.
    obj.w0_ = sum(y[s] - dot(a[s]*y[s], eval(kernel, X[s], s))) / sum(s)
end

function predict(obj::SVC, X)
    s = obj.a_ != 0.
    sign(obj.w0_ + dot(obj.a_[s]*obj.y_[s], eval(obj.kernel_, X, s)))
end

end