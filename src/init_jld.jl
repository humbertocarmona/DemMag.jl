function initFromJLD(fname::String; vo::Vector{Float64}=[0.,0.,0.],
                    nin::Int64=5, transf::Bool=false)

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
        diam = mean([st.r[i][2] - st.r[i+1][2] for i=1:st.N-1])
        dr = [0.,0.5*diam, 0.5*diam]
        rin = st.r[nin]
        for i = 1:st.N
            st.r[i] = st.r[i] - rin + dr
            st.r0[i] = st.r[i]
            st.v[i] = st.v[i] + vo
            st.ex0[i] = st.ex[i]
            st.ey0[i] = st.ey[i]
            st.ez0[i] = st.ez[i]
            st.vo = vo
            if i > nin
                st.active[i] = 0
            end
        end
    else
        v0 = norm(vo)
        m0 = norm(st.m[1])
        fac = v0/m0
        for i = 1:st.N
            st.v[i] = fac*st.m[i]
            st.ex0[i] = st.ex[i]
            st.ey0[i] = st.ey[i]
            st.ez0[i] = st.ez[i] 
        end
    end
    st.vo = vo

return st, tinit
end
