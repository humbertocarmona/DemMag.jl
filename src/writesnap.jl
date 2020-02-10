function writeSnapshot(st::State, t::Int64)
    N = st.N
    step = lpad(t, 7, "0")
    fname = "./snaps/snap_$step.vtu"
    x = [st.r[i][1] for i = 1:N]
    y = [st.r[i][2] for i = 1:N]
    z = [st.r[i][3] for i = 1:N]

    cells = [MeshCell(VTKCellTypes.VTK_LINE, [i, i + 1]) for i = 1:N-1]
    vtkfile = vtk_grid(fname, x, y, z, cells)
    vtkfile["active"] = [st.active[i] for i = 1:N]

    vtkfile["fcontact"] = (
        [st.fcontact[i][1] for i = 1:N],
        [st.fcontact[i][2] for i = 1:N],
        [st.fcontact[i][3] for i = 1:N],
    )

    vtkfile["fmag"] = (
        [st.fmag[i][1] for i = 1:N],
        [st.fmag[i][2] for i = 1:N],
        [st.fmag[i][3] for i = 1:N],
    )

    vtkfile["ftot"] = (
        [st.a[i][1] for i = 1:N],
        [st.a[i][2] for i = 1:N],
        [st.a[i][3] for i = 1:N],
    )

    vtkfile["idx"] = [i for i = 1:N]

    vtkfile["mag"] = (
        [st.m[i][1] for i = 1:N],
        [st.m[i][2] for i = 1:N],
        [st.m[i][3] for i = 1:N],
    )

    vtkfile["vel"] = (
        [st.v[i][1] for i = 1:N],
        [st.v[i][2] for i = 1:N],
        [st.v[i][3] for i = 1:N],
    )
    vtkfile["r"] = (x,y,z)

    vtkfile["angvel"] = (
        [st.ω[i][1] for i = 1:N],
        [st.ω[i][2] for i = 1:N],
        [st.ω[i][3] for i = 1:N],
    )

    outfile = vtk_save(vtkfile)
end


function dumpState(st::State, t::Int64)
    step = lpad(t, 7, "0")
    sn = lpad(st.N,3,"0")
    fname = "state_$(sn)_$step.jld"
    save(fname,"p",st)
end
