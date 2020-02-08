function initFromJLD(fname::String; vo::Vector{Float64},
    nin::Int64=5,
    θ::Float64 = π/2,
    ax::Vector{Float64} = [0.0,1.0, 0.0],
    transf::Bool=false)
    tinit = 0
    fstr = split(fname, ".")
    fstr = split(fstr[1], "_")
    try
        tinit = parse(Int64, fstr[end])+1
    catch
        println("$fname")
    end


    st = load(fname, "p")
    if transf
        println("transforming ...")
        di = [st.r[i][2] - st.r[i+1][2] for i=1:st.N-1]
        diam = mean(di)
        dr = [0.,0.5*diam, 0.5*diam]
        q = qrotation(ax,θ)
        RT = rotationmatrix(q)
        rin = st.r[nin]
        for i = 1:st.N
            st.r[i] = st.r[i] - rin
            st.r[i] = RT*st.r[i]
            st.r[i] = st.r[i] + dr
            st.r0[i] = st.r[i]
            st.m[i] = RT*st.m[i]
            st.m0[i] = RT*st.m0[i]
            st.v[i] = RT*st.v[i] + vo
            st.v0[i] = RT*st.v0[i]
            st.vo = vo

            # st.a[i] = [0.0,0.0,0.0]
            st.a[i] = RT*st.a[i]
            st.w[i] = RT*st.w[i]
            st.q[i] = qrotation(st.w[i], 0.0)
            st.qv[i] = evalQv(st.q[i], st.w[i])
            st.qa[i] = evalQa(st.q[i],st.qv[i],st.τ[i])
            st.τ[i] = [0.0,0.0,0.0]
            if i > nin
                st.active[i] = 0
            end
        end
    else
        for i = 1:st.N
            st.v[i] = st.v[i] + vo
            st.v0[i] = st.v0[i]
            st.vo = vo
        end
    end

return st, tinit
end
