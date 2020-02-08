function constrain!(p::State)
u = [0.0, 1.0, 0.0]

    for i = 1:p.N
        inside = dot(p.r[i], u) > 0.0
        if  p.active[i] == 0 && inside
            p.active[i] = 1
        end
        if p.active[i] == 0
            p.v[i] = p.vo
            p.a[i] = [0.0,0.0,0.0]
            p.w[i] = [0.0,0.0,0.0]
            p.q[i] = qrotation(p.w[i], 0.0)
            p.qv[i] = evalQv(p.q[i], p.w[i])
            p.qa[i] = evalQa(p.q[i],p.qv[i],p.τ[i])
            p.τ[i] = [0.0,0.0,0.0]

        end
    end
end
