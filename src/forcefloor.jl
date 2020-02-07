function forceFloor!(p::State;
                    kn = 200.0,
                    kt::Float64 = 10.0,
                    μ::Float64 = 0.8,
                    γn::Float64 = 1.0)
    N = p.N
    potEnergy = 0.0
    khat = [0.0, 0.0, 1.0]
    p.fnormal = zeroVec(N)
    for i=1:p.N
        if p.active[i] > 0
            dr = p.r[i][3]*khat
            d = abs(p.r[i][3])
            if d < p.R
                vt = p.v[i] - p.R*cross(khat, p.w[i])
                vn = p.v[i][3]*khat
                p.ζf[i] += p.δt*vt
                ζ = LinearAlgebra.norm(p.ζf[i])
                ϵ = p.R - d # deformation
                ftn = kt*ζ
                fn = kn*ϵ
                fμ = μ*fn
                if ftn > fμ
                    ftn = fμ
                    p.ζf[i] = zeros(3)
                end
                that = LinearAlgebra.normalize(vt)
                ft = -ftn*that

                fj = fn*khat - γn*vn
                p.a[i] = p.a[i] + fj + ft
                p.fnormal[i] = p.fnormal[i] + fj

                potEnergy += 0.5 * kn * ϵ^2
            end
        end
    end
    return potEnergy
end
