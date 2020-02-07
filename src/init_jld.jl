function initFromJLD(fname::String; diam::Float64=1.0, nin::Int64=5)
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
    if nin>0
        println("shifting to origin")
        dr = -p.r[nin]
        dr = dr + [0.,0.5*diam,2.]
        for i = 1:p.N
            p.r[i] = p.r[i] + dr
            if i > nin
                p.active[i] = 0
            end
        end
    else
        scal = 3.0
        for i=1:p.N
            p.m[i] = scal*p.m[i]
            p.m0[i] = scal*p.m0[i]
        end
        p.mag = s*p.mag
    end
    return p, tinit
end
