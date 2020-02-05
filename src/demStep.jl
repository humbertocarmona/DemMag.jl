function demStep!(p::State,
                  t::Int64,
                  Ri::Float64=100.0)
    predictor!(p)
    predictorQ!(p)
    N = p.N

    p.a = zeroVec(N)
    p.τ = zeroVec(N)

    Ucontact = forceSpring!(p)
    Ufloor = forceFloor!(p)
    Umag = forceMag!(p)
    Ugrav = forceGrav!(p)
    forceFriction!(p)

    computeQa!(p)
    corrector!(p)
    correctorQ!(p)

    constrain!(p, Ri)
    return Ucontact+Umag+Ufloor+Ugrav
end
