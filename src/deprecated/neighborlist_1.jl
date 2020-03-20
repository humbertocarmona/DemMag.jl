shiftcell2d = [(0, 0), (0, 1), (1, -1), (1, 0), (1, 1)]


function cellList(st::State,
                    cellw::Vector{Float64},
                    L::Tuple{Float64,Float64,Float64},
                    )
    nx, ny, nz = Int.(floor.(L ./ cellw))
    cellw = L ./ [nx, ny, nz]
    ncells = nx*ny*nz
    llist = LinkList(ncells, st.N)
    count = 0
    for n = 1:st.N
        x,y,z = st.r[n]
        if 0.0 < x <= L[1] &&  0.0 < y  <= L[2]
            j, i, k = Int.( st.r[n] .÷ cellw ) .+ 1
            c = getc(i, j, nx)
            pushleft!(llist, c ,n)
            count+=1
        end
    end
    return llist
end


function neighborList(
                        st::State,
                        cellw::Vector{Float64},
                        L::Tuple{Float64,Float64,Float64},
                        dc::Float64,
                    )
    dc2 = dc^2
    nx, ny, nz = Int.(floor.(L ./ cellw))
    cellw = L ./ [nx, ny, nz]

    nshift = 5

    llist = cellList(p, cellw, L)
    neighborlist = []

    nonEmptyCells = findall(x->x>0, llist.chead)
    for c0 in nonEmptyCells
        l0 = incell(llist, c0)
        i0, j0 = getij(c0, nx)
        for s = 1:nshift
            i1, j1 = i0 + shiftcell2d[s][1], j0 + shiftcell2d[s][2]
            if (0 < i1 ≤ nx) && (0 < j1 ≤ ny)
                c1 = getc(i1, j1, nx)
                l1 = incell(llist,c1)
                cond1 = c1 ≠ c0
                for i in l0
                    for j in l1
                        if cond1 || i > j
                            dr = st.r[j] - st.r[i]
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
    return neighborlist
end
