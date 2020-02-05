function forceFloor!(
                        p::State,
                        kn::Float64 = 100.0,
                        kt::Float64 = 1.0,
                        μ::Float64 = 0.3,
                        γn::Float64 = 0.5
                    )

    R = 0.5
    N = p.N
    potEnergy = 0.0
    khat = [0.0, 0.0, 1.0]
    p.fnormal = zeroVec(N)
    for i=1:p.N
        if p.active[i] > 0
            dr = p.r[i][3]*khat
            d = abs(p.r[i][3])
            if d < R
                ϵ = R - d # deformation
                fj = kn*ϵ*khat
                p.a[i] = p.a[i] + fj
                p.fnormal[i] = p.fnormal[i] + fj

                potEnergy += 0.5 * kn * ϵ^2
            end
        end
    end
    return potEnergy
end
