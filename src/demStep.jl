function demStep!(st::State,
                  t::Int64)
    predictor!(st)
    predictorQ!(st)
    N = st.N

    st.a = zeroVec(N)
    st.τ = zeroVec(N)

    Ucontact = forceSpring!(st)
    Ufloor = forceFloor!(st)
    Umag = forceMag!(st)
    Ugrav = forceGrav!(st)
    forceFriction!(st)

    computeQa!(st)
    corrector!(st)
    correctorQ!(st)

    constrain!(st)
    return Ucontact+Umag+Ufloor+Ugrav
end
