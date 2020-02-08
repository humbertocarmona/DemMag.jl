function initFromCSV(L::Array{Float64,1}, fname::String)
    df = CSV.read(fname)
    N = size(df,1)
    p =  State(N=N, L=L, R = 0.5*df.diam[1])
    for i = 1:N
        st.r[i] = [df.x[i], df.y[i], df.z[i]]
        st.v[i] = [df.vx[i], df.vy[i], df.vz[i]]
        st.w[i] = [df.wx[i], df.wy[i], df.wz[i]]
        st.m[i] = [df.mx[i], df.my[i], df.mz[i]]
        st.τ[i] = [0.,0.,0.]
        st.q[i] = qrotation(st.w[i], 0.0)
        st.m[i] = rotationQ(st.q[i], st.m[i])
        st.qv[i] = evalQv(st.q[i], st.w[i])
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
    return st
end
