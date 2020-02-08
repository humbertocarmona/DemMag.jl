function forceSpring!(
                        p::State,
                        kn::Float64 = 100.0,
                        kt::Float64 = 1.0,
                        μ::Float64 = 0.5,
                        γn::Float64 = 1.0
                    )

    R = p.R
    D = 2*R
    D2 = D^2
    N = p.N
    potEnergy = 0.0
    p.fcontact = zeroVec(N)
    incontact = zeros(N,N)
    for (i, j) in p.neighCon
        active = (p.active[i] + p.active[j])>0
        if active
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
                fn = kn*ϵ

                fμ = μ*fn
                ftn = kt*ζ
                if ftn > fμ
                    ftn = fμ
                    p.ζc[i, j] -= vt * p.δt
                    p.ζc[j, i] = p.ζc[i, j]
                end
                that = LinearAlgebra.normalize(vt)

                ft = -ftn*that
                fj = fn * rhat - γn * vn
                τ = - R * cross(rhat, ft)

                p.a[j] = p.a[j] + fj + ft
                p.a[i] = p.a[i] - fj - ft

                p.τ[i] = p.τ[i] + τ
                p.τ[j] = p.τ[j] + τ
                p.fcontact[j] = p.fcontact[j] + fj + ft
                p.fcontact[i] = p.fcontact[i] - fj - ft
                potEnergy += 0.5 * kn * ϵ^2

            end
        end
    end
    # nic = findall(x->x==0, incontact)
    # for idx in nic
    #     p.ζc[idx] = zeros(3)
    # end
    return potEnergy
end
