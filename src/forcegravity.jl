function forceGrav!(p::State;g::Vector{Float64} = [0.0, 0.0, -0.005])
    potEnergy = 0.0
    p.fgrav =  zeroVec(p.N)
    for i = 1:p.N
        if p.active[i]==1
            p.a[i] = p.a[i] + g
            potEnergy = potEnergy - g[3]*(p.r[i][3]-0.5)
            p.fgrav[i] = g
        end
    end
    return potEnergy
end
