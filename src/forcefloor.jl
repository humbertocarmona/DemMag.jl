function forceFloor!(st::State;
                    kn = 100.0,
                    kt::Float64 = 1.0,
                    μ::Float64 = 1.0,
                    γn::Float64 = 5.0)

    #TODO -- transform this in force wall plane and define plane normal
    N = st.N
    potEnergy = 0.0
    nhat = [0.0, 0.0, 1.0]
    pt = [0.,0.,0.]

    st.fnormal = zeroVec(N)
    for i=1:st.N
        if st.active[i] > 0
            h = dot(st.r[i]-pt, nhat)
            dr = h*nhat
            d = abs(h)
            if d < st.R
                vt = st.v[i] - st.R*cross(nhat, st.w[i])
                vn = st.v[i][3]*nhat
                st.ζf[i] += st.δt*vt
                ζ = LinearAlgebra.norm(st.ζf[i])
                ϵ = st.R - d # deformation
                ftn = kt*ζ
                fn = kn*ϵ
                fμ = μ*fn
                if ftn > fμ
                    ftn = fμ
                    st.ζf[i] -= st.δt*vt
                end
                that = LinearAlgebra.normalize(vt)
                ft = -ftn*that

                fj = fn*nhat - γn*vn
                st.a[i] = st.a[i] + fj + ft
                st.fnormal[i] = st.fnormal[i] + fj

                potEnergy += 0.5 * kn * ϵ^2
            end
        end
    end
    return potEnergy
end
