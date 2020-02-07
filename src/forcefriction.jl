function forceFriction!(p::State; γn = 1.5, γw = 0.05)
    for i = 1:p.N
        if p.active[i]==1
            p.a[i] = p.a[i] - γn * p.v[i]
            p.τ[i] = p.τ[i] - γw * p.w[i]
        end
    end
end
