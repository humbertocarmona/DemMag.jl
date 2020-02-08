function forceFriction!(st::State; γn = 0.1, γw = 0.5)
    for i = 1:st.N
        if st.active[i]==1
            st.a[i] = st.a[i] - γn * st.v[i]
            st.τ[i] = st.τ[i] - γw * st.w[i]
        end
    end
end
