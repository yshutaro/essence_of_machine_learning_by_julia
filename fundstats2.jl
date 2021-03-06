using Printf

# 2018年4月の東京の最高気温（日別）
x = [21.9, 24.5, 23.4, 26.2, 15.3, 22.4, 21.8, 16.8,
     19.9, 19.1, 21.9, 25.9, 20.9, 18.8, 22.1, 20.0,
     15.0, 16.0, 22.2, 26.4, 26.0, 28.3, 18.7, 21.3,
     22.5, 25.0, 22.0, 26.1, 25.6, 25.7]

# 2018年4月の札幌の最高気温（日別）
y = [8.3, 13.0, 8.4, 7.9, 7.0, 3.7, 6.1, 8.5, 8.6,
     11.9, 12.1, 14.4, 7.0, 10.5, 6.6, 10.6, 16.6,
     19.1, 20.1, 19.8, 24.5, 12.6, 16.4, 13.0, 13.3,
     14.1, 14.4, 17.0, 21.3, 24.5]

mx = sum(x) / length(x)
my = sum(y) / length(y)
sx = sqrt( sum((x .- mx).^2) / length(x) )
sy = sqrt( sum((y .- my).^2) / length(y) )
sxy = sum((x .- mx) .* (y .- my)) / length(x)
println("東京の最高気温の標準偏差:$(@sprintf("%.4f",sx))")
println("札幌の最高気温の標準偏差:$(@sprintf("%.4f",sy))")
println("共分散:$(@sprintf("%.4f",sxy))")
println("相関係数:$(@sprintf("%.4f",sxy / (sx * sy)))")
