using DemMag
using LinearAlgebra
using Test
using Quaternions
using Plots

# function main()
stepInit = 0
stepEnd = 200_000
stepSaveSnap = 2000
stepDisplay = 2000
stepSaveState = 1_000_000

N = 100
diam = 1.0
rc_cont = 1.0*diam
rc_mag = 5*diam
cellCont = [rc_cont, rc_cont, rc_cont]
cellMag = [rc_mag, rc_mag, rc_mag]
L = [2.1*N*rc_cont,2.1*N*rc_cont, 3*rc_mag]
vo = [0.0, 0.1, 0.0]
mag = [0.0, 0.4, 0.0]

# p = initAsWire(diam=diam, mag=mag, vo=vo, L=L, N=N, ro=[0.0, 101.5, 0.5])
# p = initFromCSV(L, "inputdata.csv")

p,dummy = DemMag.initFromJLD("sample_03.jld"; vo = vo, transf=false)

neighShellWidthCont = 0.1*rc_cont
neighCutCont = rc_cont + neighShellWidthCont
p.neighCon = neighborList(p, cellCont, neighCutCont)
maxDisplacementCont = 0.0


neighShellWidthMag = 0.1*rc_mag
neighCutMag = rc_mag + neighShellWidthMag
p.neighMag = neighborList(p, cellMag, neighCutMag)
maxDisplacementMag = 0.0


p.δt = 0.001

stp = []
pot = []
kin = []
println()
println("#-------------------- running ---------------------")
mkpath("snaps")
removeFilesMaching(r"snap_.+\.vtu", "./snaps/")
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
        # (lpad(t, 5, "0"))
        println("t = $t $(p.fmag[1])")
    end
end

# plotly()
# p1 = plot(stp, pot, label = "U")
# plot!(stp, kin, label = "K")
# plot!(stp, pot .+ kin, label = "E")
