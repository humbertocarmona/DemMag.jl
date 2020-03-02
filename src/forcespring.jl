function forceSpring!(st::State)

    R = st.R
    D = 2*R
    D2 = D^2
    N = st.N
    potEnergy = 0.0
    st.fcontact = zeroVec(N)
    incontact = zeros(N,N)
    for (i, j) in st.neighCon
        active = (st.active[i] + st.active[j])>0
        if active
            dr = st.r[j] - st.r[i]
            dr2 = dot(dr, dr)
            if dr2 < D2
                incontact[i,j] = incontact[j,i] = 1
                d = sqrt(dr2)
                ϵ = D - d # deformation
                rhat = dr ./ d

                dv = st.v[j] - st.v[i]
                vn = dot(dv, rhat) * rhat
                vt = dv - vn - R * cross(st.ω[i], rhat) - R * cross(st.ω[j], rhat)
                st.ζc[i, j] += vt * st.δt
                st.ζc[j, i] = st.ζc[i, j]
                ζ = LinearAlgebra.norm(st.ζc[i, j])
                fn = st.kn*ϵ

                fμ = st.μ*fn
                ftn = st.kt*ζ
                if ftn > fμ
                    ftn = fμ
                    st.ζc[i, j] -= vt * st.δt
                    st.ζc[j, i] = st.ζc[i, j]
                end
                that = LinearAlgebra.normalize(vt)

                ft = -ftn*that
                fj = fn * rhat - st.γn * vn
                τ = - R * cross(rhat, ft)

                st.a[j] = st.a[j] + fj + ft
                st.a[i] = st.a[i] - fj - ft

                st.τ[i] = st.τ[i] + τ
                st.τ[j] = st.τ[j] + τ
                st.fcontact[j] = st.fcontact[j] + fj + ft
                st.fcontact[i] = st.fcontact[i] - fj - ft
                potEnergy += 0.5 * st.kn * ϵ^2

            end
        end
    end
    # nic = findall(x->x==0, incontact)
    # for idx in nic
    #     st.ζc[idx] = zeros(3)
    # end
    return potEnergy
end
