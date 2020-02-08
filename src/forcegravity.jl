function forceGrav!(st::State;
    g::Vector{Float64} = [0.0, 0.0, -0.001])
    potEnergy = 0.0
    st.fgrav =  zeroVec(st.N)
    for i = 1:st.N
        if st.active[i]==1
            st.a[i] = st.a[i] + g
            potEnergy = potEnergy - g[3]*(st.r[i][3]-0.5)
            st.fgrav[i] = g
        end
    end
    return potEnergy
end
