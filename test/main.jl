using DemMag
using LinearAlgebra
using Test
using Quaternions
using JLD

using Plots
plotly()

stepInit = 0
stepEnd = 2501
stepSaveSnap = 50
stepDisplay = 50
stepSaveState = 1_000_000

N = 20
diam = 1.0
v0 = [0.0, 0.2, 0.005]
L = [101.0, 101.0, 15.0]
Ri = 10.0
mag = [0.0, 0.3, 0.0]
γn = 0.05

# p = initAsWire(diam, mag, v0, L, N, Ri)
p = initFromCSV(L, "inputdata.csv")

cellCont = [1.0diam, 1.0diam, 1.0diam]
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
    U = demStep!(p, t, Ri)
    v2 = [dot(v, v) for v in p.v]
    w2 = [dot(w, w) for w in p.w]
    K = 0.5 * sum(v2) + 0.5 * sum(w2)
    dmax = p.δt * sqrt(maximum(v2))

    global maxDisplacementMag += dmax
    if maxDisplacementMag > neighShellWidthMag
        p.neighMag = neighborList(p, cellMag, neighCutMag)
        global maxDisplacementMag = 0.0
    end

    global maxDisplacementCont += dmax
    if maxDisplacementCont > neighShellWidthCont
        p.neighCon = neighborList(p, cellCont,  neighCutCont; t=t)
        global maxDisplacementCont = 0.0
    end


    if mod(t, stepDisplay) == 0
        push!(stp, t)
        push!(pot, U)
        push!(kin, K)
        println(lpad(t, 7, "0"))
    end
end

# p1 = plot(stp, pot, label = "U")
# plot!(stp, kin, label = "K")
# plot!(stp, pot .+ kin, label = "T")
