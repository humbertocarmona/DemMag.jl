function initFromCSV(L::Array{Float64,1}, fname::String)
    df = CSV.read(fname)
    N = size(df,1)
    p =  State(N=N, L=L, R = 0.5*df.diam[1])
    for i = 1:N
        p.r[i] = [df.x[i], df.y[i], df.z[i]]
        p.v[i] = [df.vx[i], df.vy[i], df.vz[i]]
        p.w[i] = [df.wx[i], df.wy[i], df.wz[i]]
        p.m[i] = [df.mx[i], df.my[i], df.mz[i]]
        p.τ[i] = [0.,0.,0.]
        p.q[i] = qrotation(p.w[i], 0.0)
        p.m[i] = rotationQ(p.q[i], p.m[i])
        p.qv[i] = evalQv(p.q[i], p.w[i])
        p.qa[i] = evalQa(p.q[i],p.qv[i],p.τ[i])
        p.active[i] = df.on[i]
    end
    p.mag = p.m[1]
    p.r0 = copy(p.r)
    p.m0 = copy(p.m)
    p.v0 = copy(p.v)
    p.qv0 = copy(p.qv)
    p.qa1 = copy(p.qa)
    p.qa2 = copy(p.qa)
    p.qa3 = copy(p.qa)
    return p
end
