function initAsWire(
    diam::Float64,
    dipmag::Vector{Float64},
    vinit::Vector{Float64},
    L::Vector{Float64},
    N::Int,
    Ri::Float64 = 300.0)

    p =  State(N=N,
               L=L,
               diam=diam,
               vinit=vinit,
               dipmag=dipmag)

    θo =  0.0
    rc = 0.5*L - Ri*[1.0, 0.0, 0.0]
    xo =  rc[1] + Ri*cos(θo)
    yo =  rc[2] + Ri*sin(θo)
    zo =  rc[3]
    (x,y,z,θ) = (xo,yo,zo,θo)

    for i = 1:N
        if i>1
            x, y, θ = getXYΘ(x, y, θ, diam; Ri=Ri)
        end
        qo = qrotation([0.,0.,1.], θ)
        Ro = rotationmatrix(qo)
        p.r[i] = [x, y, 0.5]
        p.v[i] = Ro*vinit
        p.a[i] = [0.0, 0.0, 0.0]
        p.w[i] = [0.0, 0.0, 0.0]
        p.m[i] = Ro*dipmag
        p.τ[i] = [0.,0.,0.]
        p.q[i] = qrotation([0.0,0.0,1.0], 0.0)
        R = rotationmatrix(p.q[i])
        p.m[i] = R*p.m[i]
        p.qv[i] = evalQv(p.q[i], p.w[i])
        p.qa[i] = evalQa(p.q[i],p.qv[i],p.τ[i])
        if p.r[i][2]>=0.5*L[2]
            p.active[i] = 1
            p.lastactive = i
        end
    end
    p.active[1] = 1
    p.r0 = copy(p.r)
    p.m0 = copy(p.m)
    p.v0 = copy(p.v)
    p.qv0 = copy(p.qv)
    p.qa1 = copy(p.qa)
    p.qa2 = copy(p.qa)
    p.qa3 = copy(p.qa)
    return p
end

function initFromCSV(L::Array{Float64,1}, fname::String)
    df = CSV.read(fname)
    N = size(df,1)
    p =  State(N=N,
               L=L)
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
        p.active[i] = 1
    end
    p.lastactive=1
    p.r0 = copy(p.r)
    p.m0 = copy(p.m)
    p.v0 = copy(p.v)
    p.qv0 = copy(p.qv)
    p.qa1 = copy(p.qa)
    p.qa2 = copy(p.qa)
    p.qa3 = copy(p.qa)
    return p
end

function getXYΘ(xo, yo, θo, diam; Ri::Float64=50.0)
    x = xo
    y = yo - diam
    θ = 0.0
    if Ri < 201.0
        θ  = θo - diam/Ri
        x = xo + Ri*(cos(θ) - cos(θo))
        y = yo + Ri*(sin(θ) - sin(θo))
    end
    return x,y,θ
end
