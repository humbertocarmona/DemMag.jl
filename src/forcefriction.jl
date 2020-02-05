function forceFriction!(
                        p::State;
                        kt::Float64 = 0.01,
                        μ::Float64 = 0.01,
                        γn::Float64 = 0.0,
                        γw::Float64 = 0.05,
                        R::Float64 = 0.5
                    )
    khat = [0.0, 0.0, 1.0]
    fn = 1.0
    for i = 1:p.N
        if p.active[i]==1
            vt = p.v[i] - R*cross(khat, p.w[i])
            p.ζw[i] += p.δt*vt
            ζ = LinearAlgebra.norm(p.ζw[i])
            ftn = kt*ζ
            fμ = μ*fn
            if ftn > fμ
                ftn = fμ
                p.ζw[i] = zeros(3)
            end
            that = LinearAlgebra.normalize(vt)
            ft = -ftn*that
            p.a[i] = p.a[i] - γn * vt + ft
            p.τ[i] = p.τ[i] - γw * p.w[i]
        end
    end
end
