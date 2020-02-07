function forceMag!(p::State; rc2::Float64 = 100.0)
    potEnergy = 0.0
    p.fmag = zeroVec(p.N)
    for (i, j) in p.neighMag
        active = (p.active[i] + p.active[j])>0
        # even though force on inactive partices has no effect
        # they still act on the active ones as long as they are on the
        # neighbor list.
        if active
            dr = p.r[j] - p.r[i]
            r2 = dot(dr, dr)
            if r2 <= rc2
                ir2 = 1.0 / r2
                ir = sqrt(ir2)
                ir3 = ir2 * ir
                ir5 = ir3 * ir2

                mir = dot(p.m[i], dr)
                mjr = dot(p.m[j], dr)
                mimj = dot(p.m[i], p.m[j])

                bi = 3 * mir * ir5 * dr - ir3 * p.m[i]
                bj = 3 * mjr * ir5 * dr - ir3 * p.m[j]

                potEnergy = potEnergy - dot(p.m[i], bj)
                fj = mir * p.m[j] + mjr * p.m[i] + mimj * dr -
                     5.0 * mir * mjr * ir2 * dr
                fj = 3.0 * ir5 * fj


                τi = cross(p.m[i], bj)
                τj = cross(p.m[j], bi)

                p.a[j] = p.a[j] + fj
                p.a[i] = p.a[i] - fj
                p.τ[i] = p.τ[i] + τi
                p.τ[j] = p.τ[j] + τj
                p.fmag[j] = p.fmag[j] + fj
                p.fmag[i] = p.fmag[i] - fj
            end
        end
    end
    return potEnergy
end
