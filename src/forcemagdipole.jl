function forceMag!(st::State; rc2::Float64 = 100.0)
    potEnergy = 0.0
    st.fmag = zeroVec(st.N)

    for (i, j) in st.neighMag
        active = (st.active[i] + st.active[j])>0
        # even though force on inactive partices has no effect
        # they still act on the active ones as long as they are on the
        # neighbor list.
        if active
            dr = st.r[j] - st.r[i]
            r2 = dot(dr, dr)
            if r2 <= rc2
                ir2 = 1.0 / r2
                ir = sqrt(ir2)
                ir3 = ir2 * ir
                ir5 = ir3 * ir2

                mir = dot(st.m[i], dr)
                mjr = dot(st.m[j], dr)
                mimj = dot(st.m[i], st.m[j])

                bi = 3 * mir * ir5 * dr - ir3 * st.m[i]
                bj = 3 * mjr * ir5 * dr - ir3 * st.m[j]

                potEnergy = potEnergy - dot(st.m[i], bj)
                fj = mir * st.m[j] + mjr * st.m[i] + mimj * dr - 5.0 * mir * mjr * ir2 * dr
                fj = 3.0 * ir5 * fj

                n = ir*dr
                fn = dot(fj,n)*n
                ft = fj - fn

                τi = cross(st.m[i], bj)
                τj = cross(st.m[j], bi)

                st.a[j] = st.a[j] + fj
                st.a[i] = st.a[i] - fj
                st.τ[j] = st.τ[j] + τj
                st.τ[i] = st.τ[i] + τi

                st.fmag[j] = st.fmag[j] + fj
                st.fmag[i] = st.fmag[i] - fj

            end
        end
    end
    return potEnergy
end
