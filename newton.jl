module newton

mutable struct Newton
  ϵ::Float64
  max_iter::Int
  path_x_::Array
  path_y_::Array

  function Newton(ϵ=1e-10, max_iter=1000)
    new(ϵ, max_iter, [], [])
  end
end

function solveNewton(newton::Newton, f, df, x0)
  x = x0
  x_new = 0
  iter = 0
  push!(newton.path_x_, x0[1])
  push!(newton.path_y_, x0[2])
  while true
    x_new = x - inv(df(x)) * f(x)
    push!(newton.path_x_, x_new[1])
    push!(newton.path_y_, x_new[2])
    if sum((x - x_new).^2) < (newton.ϵ)^2
      break
    end
    x = x_new
    iter += 1
    if iter == newton.max_iter
      break
    end
  end
  return x_new
end

end
