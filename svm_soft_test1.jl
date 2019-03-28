include("svm_soft.jl")

using .svm_soft
using Plots
using Random

Random.seed!(0)
X0 = randn(20, 2)
println("X0 : ", X0)

#X0 = [ 1.76405235  0.40015721;
#  0.97873798  2.2408932 ;
#  1.86755799 -0.97727788;
#  0.95008842 -0.15135721;
# -0.10321885  0.4105985 ;
#  0.14404357  1.45427351;
#  0.76103773  0.12167502;
#  0.44386323  0.33367433;
#  1.49407907 -0.20515826;
#  0.3130677  -0.85409574;
# -2.55298982  0.6536186 ;
#  0.8644362  -0.74216502;
#  2.26975462 -1.45436567;
#  0.04575852 -0.18718385;
#  1.53277921  1.46935877;
#  0.15494743  0.37816252;
# -0.88778575 -1.98079647;
# -0.34791215  0.15634897;
#  1.23029068  1.20237985;
# -0.38732682 -0.30230275;]

X1 = randn(20, 2) .+ [2.5 3]
println("X1 : ", X1)

#X1 = [ 1.45144703 1.57998206;
# 0.79372981 4.9507754 ;
# 1.99034782 2.5619257 ;
# 1.24720464 3.77749036;
# 0.88610215 2.78725972;
# 1.60453344 3.3869025 ;
# 1.98919486 1.81936782;
# 2.47181777 3.42833187;
# 2.56651722 3.3024719 ;
# 1.86567791 2.63725883;
# 1.82753955 2.64044684;
# 1.68685372 1.2737174 ;
# 2.67742614 2.59821906;
# 0.86980165 3.46278226;
# 1.59270164 3.0519454 ;
# 3.22909056 3.12898291;
# 3.63940068 1.76517418;
# 2.90234164 2.31518991;
# 1.62920285 2.42115034;
# 2.18844747 3.05616534;]

y = vcat([1 for x in 1:20], [-1 for x in 1:20])

X = vcat(X0, X1)
println("X: ", X)

model = svm_soft.SVC()
svm_soft.fit(model, X, y)

scatter(X0[:, 1], X0[:, 2], color="black", markershape=:+, label="")
scatter!(X1[:, 1], X1[:, 2], color="black", markershape=:star6, label="")

f(model, x) = (-model.w0_ - model.w_[1] * x) / model.w_[2]

x1 = -2
x2 = 4
plot!([x1, x2], [f(model, x1), f(model, x2)], color="black", label="")
tf = model.a_ .!= 0
Xfalse = [false for x in 1:size(X)[1]]
print("正しく分類できた数:", sum(svm_soft.predict(model, X) .== y))
scatter!(X[hcat(tf, Xfalse)], X[hcat(Xfalse, tf)], color="red", markersize=10, markershape=:circle, markeralpha=0.1, label="")
