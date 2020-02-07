function writeSnapshot(p::State, t::Int64)
    N = p.N
    step = lpad(t, 7, "0")
    fname = "snap_$step.vtu"
    x = [p.r[i][1] for i = 1:N]
    y = [p.r[i][2] for i = 1:N]
    z = [p.r[i][3] for i = 1:N]

    cells = [MeshCell(VTKCellTypes.VTK_LINE, [i, i + 1]) for i = 1:N-1]
    vtkfile = vtk_grid(fname, x, y, z, cells)
    vtkfile["active"] = [p.active[i] for i = 1:N]

    vtkfile["fcontact"] = (
        [p.fcontact[i][1] for i = 1:N],
        [p.fcontact[i][2] for i = 1:N],
        [p.fcontact[i][3] for i = 1:N],
    )

    vtkfile["fmag"] = (
        [p.fmag[i][1] for i = 1:N],
        [p.fmag[i][2] for i = 1:N],
        [p.fmag[i][3] for i = 1:N],
    )

    vtkfile["ftot"] = (
        [p.a[i][1] for i = 1:N],
        [p.a[i][2] for i = 1:N],
        [p.a[i][3] for i = 1:N],
    )



    vtkfile["idx"] = [i for i = 1:N]

    vtkfile["mag"] = (
        [p.m[i][1] for i = 1:N],
        [p.m[i][2] for i = 1:N],
        [p.m[i][3] for i = 1:N],
    )

    vtkfile["vel"] = (
        [p.v[i][1] for i = 1:N],
        [p.v[i][2] for i = 1:N],
        [p.v[i][3] for i = 1:N],
    )

    vtkfile["angvel"] = (
        [p.w[i][1] for i = 1:N],
        [p.w[i][2] for i = 1:N],
        [p.w[i][3] for i = 1:N],
    )

    outfile = vtk_save(vtkfile)
end


function dumpState(p::State, t::Int64)
    step = lpad(t, 7, "0")
    sn = lpad(p.N,3,"0")
    fname = "state_$(sn)_$step.jld"
    save(fname,"p",p)
end
