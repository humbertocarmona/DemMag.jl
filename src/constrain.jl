function constrain!(st::State)
u = [0.0, 1.0, 0.0]

    for i = 1:st.N
        inside = dot(st.r[i], u) > 0.0
        if  st.active[i] == 0 && inside
            st.active[i] = 1
        end
        if st.active[i] == 0
            st.v[i] = st.vo
            st.a[i] = [0.0,0.0,0.0]
            st.ω[i] = [0.0,0.0,0.0]
            st.q[i] = qrotation(st.ω[i], 0.0)
            st.qv[i] = evalQv(st.q[i], st.ω[i])
            st.qa[i] = evalQa(st.q[i],st.qv[i],st.τ[i])
            st.τ[i] = [0.0,0.0,0.0]

        end
    end
end
