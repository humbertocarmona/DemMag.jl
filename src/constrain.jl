function constrain!(p::State)
u = [0.0, 1.0, 0.0]

    for i = 1:p.N
        inside = dot(p.r[i], u) > 0.0
        if  p.active[i] == 0 && inside
            p.active[i] = 1
            p.lastactive = i
        end
        if p.active[i] == 0
            p.v[i] = p.vo
            p.m[i] = p.mag
            p.m0[i] = copy(p.m[i])
            p.a[i] = [0.0,0.0,0.0]
            p.a1[i] = [0.0,0.0,0.0]
            p.a2[i] = [0.0,0.0,0.0]
            p.a3[i] = [0.0,0.0,0.0]
            p.τ[i] = [0.0,0.0,0.0]
        end
    end
end
