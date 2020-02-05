function forceLJ!(p::State,
    N::Int64,
    neigh::Vector{Any};
    rc2::Float64=1.2599210498948732,
    γt::Float64=0.0,
    γn::Float64=0.0)
    """
    [energy] = ε
    [length] = σ
    [mass] = m0
    [time] = sqrt(ε/(m_0 σ))
    """
    R = 0.5612310241546865  # particle radius
    potEnergy = 0.0
    p.fcontact = zeroVec(N)
    for (i,j) in neigh
        if p.active[i] + p.active[j] > 0
            dr = p.r[j] - p.r[i]
            r2 = dot(dr,dr)
            if r2 < rc2
                ir2 = 1.0/r2
                ir6 = ir2^3
                ir12 = ir6^2
                ir14 = ir12*ir2
                ir8 = ir6*ir2
                potEnergy += 4.0*(ir12 - ir6) + 1.0

                dv = p.v[j] - p.v[i]
                rhat = LinearAlgebra.normalize(dr)
                dvn = dot(dv,rhat)*rhat
                vt = dv - dvn - R*cross(p.w[i],rhat) - R*cross(p.w[j],rhat)

                fj = 48.0*(ir14 - 0.5*ir8)*dr - γn*dvn - γn*vt
                τ = R*cross(rhat, vt)

                p.a[j] = p.a[j] + fj
                p.a[i] = p.a[i] - fj

                p.τ[i] = p.τ[i] + γt*τ
                p.τ[j] = p.τ[j] + γt*τ

                p.fcontact[j] = p.fcontact[j] + fj
                p.fcontact[i] = p.fcontact[i] - fj

            end
        end
    end
    return potEnergy
end
