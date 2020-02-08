function initFromJLD(fname::String; vo::Vector{Float64}, diam::Float64=1.0, nin::Int64=5)
    tinit = 0
    st = split(fname, ".")
    st = split(st[1], "_")
    try
        tinit = parse(Int64, st[end])+1
    catch
        println("$fname")
    end


    p = load(fname, "p")

    di = [p.r[i][2] - p.r[i+1][2] for i=1:p.N-1]
    diam = mean(di)
    ax = [0.0,1.0, 0.0]
    q = qrotation(ax,90)
    RT = rotationmatrix(q)
    println("shifting to origin")
    dr = [0.,0.5*diam, 0.5*diam]
    rin = p.r[nin]
    for i = 1:p.N
        p.r[i] = p.r[i] - rin
        p.r[i] = RT*p.r[i]
        p.r[i] = p.r[i] + dr
        p.r0[i] = p.r[i]
        p.m[i] = RT*p.m[i]
        p.m0[i] = RT*p.m0[i]
        p.v[i] = RT*p.v[i] + vo
        p.v0[i] = RT*p.v0[i]
        p.vo = vo

        # p.a[i] = [0.0,0.0,0.0]
        p.a[i] = RT*p.a[i]
        p.w[i] = RT*p.w[i]
        p.q[i] = qrotation(p.w[i], 0.0)
        p.qv[i] = evalQv(p.q[i], p.w[i])
        p.qa[i] = evalQa(p.q[i],p.qv[i],p.τ[i])
        p.τ[i] = [0.0,0.0,0.0]


        if i > nin
            p.active[i] = 0
        end
    end

return p, tinit
end
