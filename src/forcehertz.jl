function forceHertz!(st::State,
                    N::Int64,
                    neigh::Vector{Any};
                    R::Float64=0.5,
                    γt::Float64=0.0,
                    γn::Float64=0.0)


    D2 = 1.0                # (2R)^2 particle diameter squared
    RSq = 0.25              # sqrt(1/(1/R) + 1/(1/R))
    E = 500.0                 # Young modulus
    ffac = 4.0*RSq*E/3.0    # factor multiplying force
    ufac = 2.0*ffac/5.0     # factor multiplying potential energy

    potEnergy = 0.0
    st.fcontact = zeroVec(N)
    for (i,j) in neigh
        if st.active[i] + st.active[j] > 0
            dr = st.r[j] - st.r[i]
            r2 = dot(dr,dr)
            if r2 < D2
                r = sqrt(r2)
                ϵ = D2 - r # deformation
                ϵ32 = ϵ*sqrt(ϵ)
                rhat = dr./r
                potEnergy += ufac*ϵ

                dv = st.v[j] - st.v[i]
                dvn = dot(dv,rhat)*rhat
                vt = dv - dvn - R*cross(st.w[i],rhat) - R*cross(st.w[j],rhat)

                fj = ffac*ϵ32*rhat - γn*dvn - γn*vt
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
