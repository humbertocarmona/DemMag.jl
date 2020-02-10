function initAsWire(;
                    δt::Float64 = 0.001,
                    diam::Float64 = 1.0,
                    mag::Array{Float64,1} = [0.0,0.0,0.0],
                    vo::Array{Float64,1} = [0.0,0.0,0.0],
                    L::Array{Float64,1} =  [100.0,100.0,15.0],
                    N::Int64 = 10,
                    u::Array{Float64,1} = [0.0, 1.0, 0.0],
                    ro::Array{Float64,1} = [0.0, 10.5, 0.5],
                    kn::Float64 = 100.0,
                    kt::Float64 = 0.5,
                    γn::Float64 = 0.2,
                    μ::Float64 = 1.0,
                    βn::Float64 = 0.1,
                    βw::Float64 = 0.5)
    st =  State(N=N)
    st.δt = δt
    st.R = 0.5*diam
    st.L = L
    st.vo = vo
    st.mag = mag
    st.kn = kn
    st.kt = kt
    st.γn = γn
    st.μ = μ
    st.βn = βn
    st.βω = βw

    for i = 1:N
        (x,y,z) = ro -i*diam*u
        st.r[i] = [x, y, z]
        st.v[i] = vo
        st.a[i] = [0.0, 0.0, 0.0]
        st.ω[i] = [0.0, 0.0, 0.0]
        st.m[i] = mag
        st.τ[i] = [0.,0.,0.]
        st.q[i] = qrotation([0.0,0.0,1.0], 0.0)
        R = rotationmatrix(st.q[i])
        st.m[i] = R*st.m[i]
        st.qv[i] = evalQv(st.q[i], st.ω[i])
        st.qa[i] = evalQa(st.q[i],st.qv[i],st.τ[i])
        st.active[i] = 0
    end
    st.active[1] = 1
    st.r0 = copy(st.r)
    st.m0 = copy(st.m)
    st.v0 = copy(st.v)
    st.qv0 = copy(st.qv)
    st.qa1 = copy(st.qa)
    st.qa2 = copy(st.qa)
    st.qa3 = copy(st.qa)
    return st
end
