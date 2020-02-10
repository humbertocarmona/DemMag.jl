function forceRandom!(
    st::State;
    μ::Float64 = 0.0,
    σ::Float64 = 0.2,
    t::Int64 = 0
)
    if t < 800000
        r = rand()
        if r > 0.95
            idx = findall(x -> x == 1, st.active)
            i = rand(idx)
            fx = rand(Normal(μ, σ))
            st.a[i] = st.a[i] + [fx, 0.0, 0.0]
        end
    end
end
