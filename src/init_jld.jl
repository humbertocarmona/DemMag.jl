function initFromJLD(fname::String; diam::Float64=1.0, nin::Int64=5)
    tinit = 0
    s = split(fname, ".")
    s = split(s[1], "_")

    try
        tinit = parse(Int64, s[end])+1
    catch
        println("$fname")
    end
    p = load(fname, "p")
    println(p.r[1])
    if nin>0
        println("shifting to origin")
        y = [p.r[i][2] for i=1:p.N]
        y = maximum(y)
        dy = (nin-1)*diam + 0.5*diam
        for i = 1:p.N
            p.r[i] = p.r[i] - [0.0, y-dy, 0.0]
            if i > nin
                p.active[i] = 0
            end
        end
        println(p.r[1])

    else
        s = 3.0
        for i=1:p.N
            p.m[i] = s*p.m[i]
            p.m0[i] = s*p.m0[i]
        end
        p.mag = s*p.mag
    end
    return p, tinit
end
