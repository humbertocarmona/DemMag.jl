function forceLJ!(st::State,
    N::Int64,
    neigh::Vector{Any};
    rc2::Float64=1.2599210498948732,
    γt::Float64=0.0,
    γn::Float64=0.0)
    """
    [energy] = ε
    [length] = σ
    [mass] = m0
    [time] = sqrt(ε/(m_0 σ))
    """
    R = 0.5612310241546865  # particle radius
    potEnergy = 0.0
    st.fcontact = zeroVec(N)
    for (i,j) in neigh
        if st.active[i] + st.active[j] > 0
            dr = st.r[j] - st.r[i]
            r2 = dot(dr,dr)
            if r2 < rc2
                ir2 = 1.0/r2
                ir6 = ir2^3
                ir12 = ir6^2
                ir14 = ir12*ir2
                ir8 = ir6*ir2
                potEnergy += 4.0*(ir12 - ir6) + 1.0

                dv = st.v[j] - st.v[i]
                rhat = LinearAlgebra.normalize(dr)
                dvn = dot(dv,rhat)*rhat
                vt = dv - dvn - R*cross(st.w[i],rhat) - R*cross(st.w[j],rhat)

                fj = 48.0*(ir14 - 0.5*ir8)*dr - γn*dvn - γn*vt
                τ = R*cross(rhat, vt)

                st.a[j] = st.a[j] + fj
                st.a[i] = st.a[i] - fj

                st.τ[i] = st.τ[i] + γt*τ
                st.τ[j] = st.τ[j] + γt*τ

                st.fcontact[j] = st.fcontact[j] + fj
                st.fcontact[i] = st.fcontact[i] - fj

            end
        end
    end
    return stotEnergy
end
