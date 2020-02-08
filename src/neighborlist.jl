shiftcell = [[0, 0, 0],[1, 0, 0],[-1, 1, 0],[0, 1, 0],[1, 1, 0],
    [-1, 0, 1],[0, 0, 1],[1, 0, 1],[-1, 1, 1],[0, 1, 1],[1, 1, 1],
    [-1, -1, 1],[0, -1, 1],[1, -1, 1]]
function cellList(p::State, cellw::Vector{Float64})
    nx, ny, nz = Int.(floor.(p.L ./ cellw))
    celllists = [MutableLinkedList() for i = 1:nx, j = 1:ny, k=1:nz]
    nonemptycells = []
    C = 0.5p.L
    for n = 1:p.N
        r = p.r[n] + C
        i, j, k = Int.(r.÷ cellw ) .+ 1  # the origin is at the C
        if i > 0 && i <= nx
            if j > 0 && j <= ny
                if k > 0 && k <= nz
                    push!(celllists[i, j, k], n)
                    push!(nonemptycells, [i, j, k])
                end
            end
        end
    end
    return celllists, unique(nonemptycells)
end


function neighborList(p::State, cellw::Vector{Float64}, dc::Float64;t=0)
    dc2 = dc^2
    nx, ny, nz = Int.(floor.(p.L ./ cellw))
    nshift = 14
    cellist, nonEmptyCells = cellList(p, cellw)

    neighborlist::Array{Tuple{Int64,Int64},1} = []
    for V0 in nonEmptyCells
        l0 = cellist[V0[1], V0[2], V0[3]]

        for s = 1:nshift
            V1 = V0 + shiftcell[s]
            if (0 < V1[1] ≤ nx) && (0 < V1[2] ≤ ny) && (0 < V1[3] ≤ nz)
                l1 = cellist[V1[1],V1[2], V1[3]]
                cond1 = V1 ≠ V0
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
