function forceFriction!(st::State)
    for i = 1:st.N
        if st.active[i]==1
            st.a[i] = st.a[i] - st.βn * st.v[i]
            st.τ[i] = st.τ[i] - st.βω * st.ω[i]
        end
    end
end
