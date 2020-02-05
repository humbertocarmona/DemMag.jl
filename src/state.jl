
mutable struct State
    N::Int64
    r::Vector{Array{Float64}}
    r0::Vector{Array{Float64}}
    v0::Vector{Array{Float64}}
    v::Vector{Array{Float64}}
    a::Vector{Array{Float64}}
    a1::Vector{Array{Float64}}
    a2::Vector{Array{Float64}}
    a3::Vector{Array{Float64}}
    τ::Vector{Array{Float64}} # torque

    w::Vector{Array{Float64}} #angular velocity
    m::Vector{Array{Float64}} # magnetization
    m0::Vector{Array{Float64}} # magnetization

    q::Array{Quaternion{Float64}}
    q0::Array{Quaternion{Float64}}
    qv::Array{Quaternion{Float64}}
    qv0::Array{Quaternion{Float64}}
    qa::Array{Quaternion{Float64}}
    qa1::Array{Quaternion{Float64}}
    qa2::Array{Quaternion{Float64}}
    qa3::Array{Quaternion{Float64}}
    active::Array{Int16}
    lastactive::Int64
    fcontact::Vector{Array{Float64}} # LJ force
    fmag::Vector{Array{Float64}}

    δt::Float64
    diam::Float64
    L::Array{Float64,1}
    vinit::Array{Float64,1}
    dipmag::Array{Float64,1}
    ζc::Array{Array{Float64,1},2}
    ζw::Array{Array{Float64,1},1}
    neighMag::Vector{Tuple{Int64,Int64}}
    neighCon::Vector{Tuple{Int64,Int64}}
    function State(;N::Int=10, δt::Float64=0.001,
                    L::Array{Float64,1}=[100.0, 100.0, 100.0],
                    diam::Float64=1.0,
                    vinit::Array{Float64,1}=[0.0, 0.0, 0.0],
                    dipmag::Array{Float64,1}=[0.0, 0.0, 0.0])
        r = zeroVec(N)
        r0 = zeroVec(N)
        v = zeroVec(N)
        v0 = zeroVec(N)
        a = zeroVec(N)
        a1 = zeroVec(N)
        a2 = zeroVec(N)
        a3 = zeroVec(N)
        τ = zeroVec(N)
        m = zeroVec(N)
        m0 = zeroVec(N)
        w = zeroVec(N)

        q = [qrotation([0.0, 0.0, 1.0], 0.0) for i = 1:N]
        q0 = copy(q)
        qv = zeroQuat(N)
        qv0 = zeroQuat(N)
        qa = zeroQuat(N)
        qa1 = zeroQuat(N)
        qa2 = zeroQuat(N)
        qa3 = zeroQuat(N)

        active = [0 for i=1:N]
        lastactive = 0
        fcontact = zeroVec(N)
        fmag = zeroVec(N)
        ζc = [zeros(3) for i=1:N, j=1:N]
        ζw = [zeros(3) for i=1:N]

        new(N, r, r0, v, v0, a, a1, a2, a3, τ, m, m0, w,
            q, q0, qv, qv0, qa ,qa1, qa2, qa3,
            active, lastactive, fcontact, fmag,
            δt, diam, L, vinit, dipmag, ζc, ζw,[],[])
    end
end
