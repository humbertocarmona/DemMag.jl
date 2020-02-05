function demStep!(p::State,
                  t::Int64,
                  Ri::Float64=100.0)
    predictor!(p)
    predictorQ!(p)
    N = p.N

    p.a = zeroVec(N)
    p.τ = zeroVec(N)

    Ucontact = forceSpring!(p)
    Umag = forceMag!(p)
    forceFriction!(p)

    computeQa!(p)
    corrector!(p)
    correctorQ!(p)

    constrain!(p, Ri)
    return Ucontact+Umag
end
