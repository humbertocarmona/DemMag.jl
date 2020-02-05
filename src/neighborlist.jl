shiftcell2d = [(0, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
shiftcell3d = [
    [0 0 0],
    [1 0 0],
    [-1 1 0],
    [0 1 0],
    [1 1 0],
    [-1 0 1],
    [0 0 1],
    [1 0 1],
    [-1 1 1],
    [0 1 1],
    [1 1 1],
    [-1 -1 1],
    [0 -1 1],
    [1 -1 1],
]

#TODO cell list is a linked list for each cell
function cellList(p::State, cellw::Vector{Float64})
    nx, ny, nz = Int.(floor.(p.L ./ cellw))
    celllists = [MutableLinkedList() for i = 1:nx, j = 1:ny]
    nonemptycells = []
    for n = 1:p.N
        i, j, k = Int.( p.r[n] .÷ cellw ) .+ 1
        if i > 0 && i <= nx
            if j > 0 && j <= ny
                push!(celllists[i, j], n)
                push!(nonemptycells, (i, j))
            end
        end
    end
    return celllists, unique(nonemptycells)
end


function neighborList(p::State, cellw::Vector{Float64}, dc::Float64)
    dc2 = dc^2
    nx, ny, nz = Int.(floor.(p.L ./ cellw))
    nshift = 5
    cellist, nonEmptyCells = cellList(p, cellw)
    neighborlist::Array{Tuple{Int64,Int64},1} = []

    for (i0, j0) in nonEmptyCells
        l0 = cellist[i0, j0]
        for s = 1:nshift
            (i1, j1) = (i0, j0) .+ shiftcell2d[s]
            if (0 < i1 ≤ nx) && (0 < j1 ≤ ny)
                l1 = cellist[i1,j1]
                cond1 = (i1,j1) ≠ (i0,j0)
                for i in l0
                    for j in l1
                        if cond1 || i > j
                            dr = p.r[j] - p.r[i]
                            dr2 = dot(dr, dr)
                            if dr2 < dc2
                                push!(neighborlist, (i,j))
                            end
                        end
                    end
                end
            end
        end
    end
    neighborlist
end
