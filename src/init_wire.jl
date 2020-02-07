function initAsWire(;diam::Float64 = 1.0,
                    mag::Array{Float64,1} = [0.0,0.0,0.0],
                    vo::Array{Float64,1} = [0.0,0.0,0.0],
                    L::Array{Float64,1} =  [100.0,100.0,20.0],
                    N::Int64 = 10,
                    u::Array{Float64,1} = [0.0, 1.0, 0.0],
                    ro::Array{Float64,1} = [0.0, 10.5, 0.5])
    println("N=$N, L=$L, R=$(0.5*diam), v0=$vo, mag=$mag")
    p =  State(N=N, L=L, R=0.5*diam, vo=vo, mag=mag)

    for i = 1:N
        (x,y,z) = ro -i*diam*u
        p.r[i] = [x, y, z]
        p.v[i] = vo
        p.a[i] = [0.0, 0.0, 0.0]
        p.w[i] = [0.0, 0.0, 0.0]
        p.m[i] = mag
        p.τ[i] = [0.,0.,0.]
        p.q[i] = qrotation([0.0,0.0,1.0], 0.0)
        R = rotationmatrix(p.q[i])
        p.m[i] = R*p.m[i]
        p.qv[i] = evalQv(p.q[i], p.w[i])
        p.qa[i] = evalQa(p.q[i],p.qv[i],p.τ[i])
        p.active[i] = 0
    end
    p.active[1] = 1
    p.lastactive = 1
    p.r0 = copy(p.r)
    p.m0 = copy(p.m)
    p.v0 = copy(p.v)
    p.qv0 = copy(p.qv)
    p.qa1 = copy(p.qa)
    p.qa2 = copy(p.qa)
    p.qa3 = copy(p.qa)
    return p
end
