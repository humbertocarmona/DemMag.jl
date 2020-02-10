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

    ω::Vector{Array{Float64}} #angular velocity
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
    fcontact::Vector{Array{Float64}} # LJ force
    fmag::Vector{Array{Float64}}
    fnormal::Vector{Array{Float64}} # normal

    δt::Float64
    R::Float64
    L::Array{Float64,1}
    vo::Array{Float64,1}
    mag::Array{Float64,1}

    kn::Float64 # normal stiffness - particle-particle, particle-plane
    kt::Float64 # tangencial stiffness - particle-particle, particle-plane
    γn::Float64 # normal dumping -  particle-particle, particle-plane
    μ::Float64  # static friction coefficient - - particle-particle, particle-plane
    βn::Float64  # viscous dumping
    βω::Float64  # viscous damping angular velocity
    g::Vector{Float64} #gravity

    ζc::Array{Array{Float64,1},2} # integrate contact friction
    ζp::Array{Array{Float64,1},1} # integrate plane friction
    neighMag::Vector{Tuple{Int64,Int64}}
    neighCon::Vector{Tuple{Int64,Int64}}

    function State(;N::Int=10)
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
        ω = zeroVec(N)

        q = [qrotation([0.0, 0.0, 1.0], 0.0) for i = 1:N]
        q0 = copy(q)
        qv = zeroQuat(N)
        qv0 = zeroQuat(N)
        qa = zeroQuat(N)
        qa1 = zeroQuat(N)
        qa2 = zeroQuat(N)
        qa3 = zeroQuat(N)

        active = [0 for i=1:N]
        fcontact = zeroVec(N)
        fmag = zeroVec(N)
        fnormal = zeroVec(N)

        ζc = [zeros(3) for i=1:N, j=1:N]
        ζp = [zeros(3) for i=1:N]

        δt = 0.001
        R = 0.5
        L = [100.0,100.0,15.0]
        vo = [0.,0.,0.]
        mag = [0.,0.,0.]
        kn = 100.0
        kt = 0.5
        γn = 0.2
        μ = 1.0
        βn = 0.1
        βω = 0.5
        g = [0.0, 0.0, -0.001]

        new(N, r, r0, v, v0, a, a1, a2, a3, τ, m, m0, ω,
            q, q0, qv, qv0, qa, qa1, qa2, qa3,
            active, fcontact, fmag, fnormal,
            δt, R, L, vo, mag, kn, kt, γn, μ, βn, βω, g,
            ζc, ζp, [], [])
    end
end
