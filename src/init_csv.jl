function initFromCSV(fname::String;
    δt::Float64 = 0.001,
    L::Array{Float64,1} =  [100.0,100.0,15.0],
    N::Int64 = 10,
    u::Array{Float64,1} = [0.0, 1.0, 0.0],
    ro::Array{Float64,1} = [0.0, 10.5, 0.5],
    kn::Float64 = 100.0,
    kt::Float64 = 0.5,
    γn::Float64 = 0.2,
    μ::Float64 = 1.0,
    βn::Float64 = 0.1,
    βω::Float64 = 0.5)

    df = CSV.read(fname)
    N = size(df,1)
    st =  State(N=N)
    for i = 1:N
        st.r[i] = [df.x[i], df.y[i], df.z[i]]
        st.v[i] = [df.vx[i], df.vy[i], df.vz[i]]
        st.ω[i] = [df.wx[i], df.wy[i], df.wz[i]]
        st.m[i] = [df.mx[i], df.my[i], df.mz[i]]
        st.τ[i] = [0.,0.,0.]
        st.q[i] = qrotation(st.ω[i], 0.0)
        st.m[i] = rotationQ(st.q[i], st.m[i])
        st.qv[i] = evalQv(st.q[i], st.ω[i])
        st.qa[i] = evalQa(st.q[i],st.qv[i],st.τ[i])
        st.active[i] = df.on[i]
    end
    st.mag = st.m[1]
    st.r0 = copy(st.r)
    st.m0 = copy(st.m)
    st.v0 = copy(st.v)
    st.qv0 = copy(st.qv)
    st.qa1 = copy(st.qa)
    st.qa2 = copy(st.qa)
    st.qa3 = copy(st.qa)


    st.δt = δt
    st.R = 0.5*df.diam[1]
    st.L = L
    st.kn = kn
    st.kt = kt
    st.γn = γn
    st.μ = μ
    st.βn = βn
    st.βω = βω
    return st
end
