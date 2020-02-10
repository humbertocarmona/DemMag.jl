function demStep!(st::State, t::Int64)
    predictor!(st)
    predictorQ!(st)
    N = st.N

    st.a = zeroVec(N)
    st.τ = zeroVec(N)

    Ucontact = forceSpring!(st)
    Ubt = forcePlane!(st; nhat = [0.,0.,1.0], pt = [0.0,0.0,0.0])
    Utp = 0.0 #forcePlane!(st; nhat = [0.,0.,-1.0], pt = [0.,0.,1.0])
    Umag = forceMag!(st)
    Ugrav = forceGrav!(st)
    forceFriction!(st)

    computeQa!(st)
    corrector!(st)
    correctorQ!(st)

    constrain!(st)
    return Ucontact+Umag+Ubt+Utp+Ugrav
end
