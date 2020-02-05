function forceHertz!(p::State,
                    N::Int64,
                    neigh::Vector{Any};
                    R::Float64=0.5,
                    γt::Float64=0.0,
                    γn::Float64=0.0)


    D2 = 1.0                # (2R)^2 particle diameter squared
    RSq = 0.25              # sqrt(1/(1/R) + 1/(1/R))
    E = 500.0                 # Young modulus
    ffac = 4.0*RSq*E/3.0    # factor multiplying force
    ufac = 2.0*ffac/5.0     # factor multiplying potential energy

    potEnergy = 0.0
    p.fcontact = zeroVec(N)
    for (i,j) in neigh
        if p.active[i] + p.active[j] > 0
            dr = p.r[j] - p.r[i]
            r2 = dot(dr,dr)
            if r2 < D2
                r = sqrt(r2)
                ϵ = D2 - r # deformation
                ϵ32 = ϵ*sqrt(ϵ)
                rhat = dr./r
                potEnergy += ufac*ϵ

                dv = p.v[j] - p.v[i]
                dvn = dot(dv,rhat)*rhat
                vt = dv - dvn - R*cross(p.w[i],rhat) - R*cross(p.w[j],rhat)

                fj = ffac*ϵ32*rhat - γn*dvn - γn*vt
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
