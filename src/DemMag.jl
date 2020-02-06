module DemMag
    using Quaternions
    using StaticArrays
    using WriteVTK
    using LinearAlgebra
    using CSV
    using DataFrames
    using Distributions
    using JLD
    using DataStructures

    include("state.jl")
    include("integrate.jl")
    include("init_wire.jl")
    include("init_csv.jl")
    include("linklist.jl")
    include("neighborlist.jl")
    include("writesnap.jl")
    include("forcelennardjones.jl")
    include("forcehertz.jl")
    include("forcespring.jl")
    include("forcemagdipole.jl")
    include("forcefriction.jl")
    include("forcerandom.jl")
    include("forcefloor.jl")
    include("forcegravity.jl")
    include("demStep.jl")
    include("constrain.jl")
    include("utils.jl")
    zeroVec(N::Int) = [[0.0, 0.0, 0.0] for i = 1:N]
    zeroQuat(N::Int) = [quat(0.0, 0.0, 0.0, 0.0) for i = 1:N]
    function evalQv(q::Quaternion{Float64}, ω::Vector{Float64})
        u = quat(0.0, 0.5ω)
        qv = q*u
    end

    function evalW(q::Quaternion{Float64}, qv::Quaternion{Float64})
        u = 2*qv*Quaternions.conj(q)
        ω = Quaternions.imag(u)
    end

    function evalQa(q::Quaternion{Float64}, qv::Quaternion{Float64}, α::Vector{Float64})
        # qa = q*(0.5α - qv.conj()*qv)
        qα = quat(0.0, 0.5α)
        qa = q*(qα - abs2(qv) )
    end

    function rotationQ(q::Quaternion{Float64}, r::Vector{Float64})
        qr = quat(0.0, r)
        rr = Quaternions.imag(q*qr*conj(q))
    end



    export State,
           initAsWire,
           initFromCSV,
           zeroVec,
           neighborList,
           demStep!,
           writeSnapshot,
           removeFilesMaching,
           dumpState

end # module
