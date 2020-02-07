using DemMag
using LinearAlgebra
using Test
using Plots

function main()
    stepInit = 0
    stepEnd = 100000
    stepSaveSnap = 500
    stepDisplay = 500
    stepSaveState = 100000

    N = 100
    diam = 1.0
    cellCont = [1.0diam, 1.0diam, 1.0diam]
    cellMag = [5diam, 5diam, 5diam]
    L = [220.0, 220.0, 20.0]
    vo = [0.0, 0.0, 0.0]
    mag = [0.0, 1.0, 0.0]

    p = initAsWire(diam=diam, mag=mag, vo=vo, L=L, N=N, ro=[0.0, 101.5, 0.5])
    # p = initFromCSV(L, "inputdata.csv")

    # p,dummy = DemMag.initFromJLD("state_100_0100000.jld"; diam=diam)

    neighRadiusCont = 1.0diam
    neighShellWidthCont = 0.1neighRadiusCont
    neighCutCont = neighRadiusCont + neighShellWidthCont
    p.neighCon = neighborList(p, cellCont, neighCutCont)
    maxDisplacementCont = 0.0


    cellMag = [5diam, 5diam, 5diam]
    neighRadiusMag = 5.0diam
    neighShellWidthMag = 0.1neighRadiusMag
    neighCutMag = neighRadiusMag + neighShellWidthMag
    p.neighMag = neighborList(p, cellMag, neighCutMag)
    maxDisplacementMag = 0.0


    p.δt = 0.001




    stp = []
    pot = []
    kin = []
    println()
    println("#------------------- running ---------------------")
    removeFilesMaching(r"snap_.+\.vtu", "./")
    println("#------------------- ------- ---------------------")
    for t = stepInit:stepEnd
        if mod(t, stepSaveSnap) == 0
            writeSnapshot(p, t)
        end
        if t > 0 && mod(t, stepSaveState) == 0
            dumpState(p, t)
        end
        U = demStep!(p, t)
        v2 = [dot(v, v) for v in p.v]
        w2 = [dot(w, w) for w in p.w]
        K = 0.5 * sum(v2) + 0.5 * sum(w2)
        dmax = p.δt * sqrt(maximum(v2))

         maxDisplacementMag += dmax
        if maxDisplacementMag > neighShellWidthMag
            p.neighMag = neighborList(p, cellMag, neighCutMag)
             maxDisplacementMag = 0.0
        end

         maxDisplacementCont += dmax
        if maxDisplacementCont > neighShellWidthCont
            p.neighCon = neighborList(p, cellCont,  neighCutCont; t=t)
             maxDisplacementCont = 0.0
        end


        if mod(t, stepDisplay) == 0
            push!(stp, t)
            push!(pot, U)
            push!(kin, K)
            println("t = $(lpad(t, 7, "0")) fmag = $(p.fmag[5]) fgrav = $(p.fgrav[5])")
        end
    end

    plotly()
    p1 = plot(stp, pot, label = "U", yaxis=([-1.2,-0.8]))
    # plot!(stp, kin, label = "K")
    # plot!(stp, pot .+ kin, label = "T")
end

main()
