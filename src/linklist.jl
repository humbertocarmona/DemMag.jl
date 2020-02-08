
mutable struct LinkList
    nx::Int16
    chead::Array{Int16}
    cnext::Array{Int16}
    function LinkList(nx::Int64, nst::Int64)
        chead = zeros(nx^2)
        cnext =  zeros(np)
        new(nx, chead, cnext)
    end
end

function getc(i::Int64, j::Int64, nx::Int64)
    j + (i-1)*nx  # j+((i-1)+(k-1)*ny)*nx em 3d
end

function getij(c, nx)
    i = c÷nx + 1
    j = c - (i-1)*nx
    return i,j
end

function pushleft!(l::LinkList, c::Int64, n::Int64)
    l.cnext[n] = l.chead[c]
    l.chead[c] = n
end

function incell(l::LinkList, c)
    p = []
    n = l.chead[c]
    while n > 0
        push!(p, n)
        n = l.cnext[n]
    end
    return st
end
