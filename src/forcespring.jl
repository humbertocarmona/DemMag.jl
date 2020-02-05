function forceSpring!(
                        p::State,
                        kn::Float64 = 100.0,
                        kt::Float64 = 1.0,
                        μ::Float64 = 0.3,
                        γn::Float64 = 0.5
                    )

    R = 0.5
    D = 1.0 # 2*R
    D2 = 1.0 # D^2
    N = p.N
    potEnergy = 0.0
    p.fcontact = zeroVec(N)
    incontact = zeros(N,N)
    for (i, j) in p.neighCon
        if p.active[i] + p.active[j] > 0
            dr = p.r[j] - p.r[i]
            dr2 = dot(dr, dr)
            if dr2 < D2
                incontact[i,j] = incontact[j,i] = 1
                d = sqrt(dr2)
                ϵ = D - d # deformation
                rhat = dr ./ d

                dv = p.v[j] - p.v[i]
                vn = dot(dv, rhat) * rhat
                vt = dv - vn - R * cross(p.w[i], rhat) - R * cross(p.w[j], rhat)
                p.ζc[i, j] += vt * p.δt
                p.ζc[j, i] = p.ζc[i, j]
                ζ = LinearAlgebra.norm(p.ζc[i, j])
                ftn = kt*ζ
                fn = kn*ϵ
                fμ = μ*fn
                if ftn > fμ
                    ftn = fμ
                    p.ζc[j, i] = p.ζc[i, j] = zeros(3)
                end
                that = LinearAlgebra.normalize(vt)

                ft = -ftn*that
                fj = fn * rhat - γn * vn + ft #
                τ = - R * cross(rhat, ft)

                p.a[j] = p.a[j] + fj
                p.a[i] = p.a[i] - fj

                p.τ[i] = p.τ[i] + τ
                p.τ[j] = p.τ[j] + τ

                p.fcontact[j] = p.fcontact[j] + fj
                p.fcontact[i] = p.fcontact[i] - fj

                potEnergy += 0.5 * kn * ϵ^2

            end
        end
    end
    nic = findall(x->x==0, incontact)
    for idx in nic
        p.ζc[idx] = zeros(3)
    end
    return potEnergy
end
