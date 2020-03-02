function forcePlane!(st::State;
                    nhat::Vector{Float64} = [0.0, 0.0, 1.0],
                    pt::Vector{Float64} = [0.,0.,0.])

    N = st.N
    potEnergy = 0.0


    st.fnormal = zeroVec(N)
    for i=1:st.N
        if st.active[i] > 0
            h = dot(st.r[i]-pt, nhat)
            dr = -h*nhat # from particle center to the plane
            d = abs(h)
            if d < st.R
                v = st.v[i] + cross(st.ω[i],dr)
                vn = st.v[i][3]*nhat
                vt = v - vn

                st.ζp[i] += st.δt*vt
                ζ = LinearAlgebra.norm(st.ζp[i])
                ϵ = st.R - d # deformation
                ftn = st.kt*ζ
                fn = st.kn*ϵ
                fμ = st.μ*fn
                if ftn > fμ
                    ftn = fμ
                    st.ζp[i] -= st.δt*vt
                end
                that = LinearAlgebra.normalize(vt)
                ft = -ftn*that

                fj = fn*nhat - st.γn*vn

                τ =  cross(dr, ft)

                st.a[i] = st.a[i] + fj + ft
                st.fnormal[i] = st.fnormal[i] + fj
                st.τ[i] = st.τ[i] + τ

                potEnergy += 0.5 * st.kn * ϵ^2
            end
        end
    end
    return potEnergy
end
