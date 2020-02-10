function forcePlane!(st::State;
                    nhat::Vector{Float64} = [0.0, 0.0, 1.0],
                    pt::Vector{Float64} = [0.,0.,0.])

    N = st.N
    potEnergy = 0.0


    st.fnormal = zeroVec(N)
    for i=1:st.N
        if st.active[i] > 0
            h = dot(st.r[i]-pt, nhat)
            dr = h*nhat
            d = abs(h)
            if d < st.R
                vt = st.v[i] - st.R*cross(nhat, st.ω[i])
                vn = st.v[i][3]*nhat
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
                st.a[i] = st.a[i] + fj + ft
                st.fnormal[i] = st.fnormal[i] + fj

                potEnergy += 0.5 * st.kn * ϵ^2
            end
        end
    end
    return potEnergy
end
