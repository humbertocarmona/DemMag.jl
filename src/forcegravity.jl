function forceGrav!(p::State;g::Vector{Float64} = [0.0, 0.0, -0.01])
    potEnergy = 0.0
    for i = 1:p.N
        if p.active[i]==1
            p.a[i] = p.a[i] + g
            potEnergy += g[3]*(p.r[i][3]-0.5)
        end
    end
    return potEnergy
end
