function forceFloor!(p::State; kn = 100.0, kt = 0.01, μ = 0.01, R = 0.5)
    N = p.N
    potEnergy = 0.0
    khat = [0.0, 0.0, 1.0]
    p.fnormal = zeroVec(N)
    for i=1:p.N
        if p.active[i] > 0
            dr = p.r[i][3]*khat
            d = abs(p.r[i][3])
            if d < R
                vt = p.v[i] - R*cross(khat, p.w[i])
                p.ζf[i] += p.δt*vt
                ζ = LinearAlgebra.norm(p.ζf[i])
                ϵ = R - d # deformation
                ftn = kt*ζ
                fn = kn*ϵ
                fμ = μ*fn
                if ftn > fμ
                    ftn = fμ
                    p.ζf[i] = zeros(3)
                end
                that = LinearAlgebra.normalize(vt)
                ft = -ftn*that

                fj = fn*khat
                p.a[i] = p.a[i] + fj + ft
                p.fnormal[i] = p.fnormal[i] + fj

                potEnergy += 0.5 * kn * ϵ^2
            end
        end
    end
    return potEnergy
end
