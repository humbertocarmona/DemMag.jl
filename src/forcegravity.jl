function forceGrav!(st::State;)

    potEnergy = 0.0
    for i = 1:st.N
        if st.active[i]==1
            st.a[i] = st.a[i] + st.g
            potEnergy = potEnergy - st.g[3]*(st.r[i][3]-0.5)
        end
    end
    return potEnergy
end
