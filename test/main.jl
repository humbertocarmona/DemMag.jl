using DemMag
using LinearAlgebra
using Test
using Quaternions
using Plots

println("#------------------- ------- ---------------------")
mkpath("snaps")
removeFilesMaching(r"snap_.+\.vtu", "./snaps/")
println("#------------------- ------- ---------------------")



N = 10
diam = 1.0
rc_cont = 1.0*diam
rc_mag = 5*diam
cellCont = [rc_cont, rc_cont, rc_cont]
cellMag = [rc_mag, rc_mag, rc_mag]
L = [100.0, 50.0, 15.0]
vo = [0.0, 0.1, 0.0]
mag = [0.0, 0.4, 0.0]

st = initAsWire(diam=diam, mag=mag, vo=vo, L=L, N=N, ro=[0.0, 6.5, 0.5])
# st = initFromCSV("inputdata.csv", L=L)

# st,t0 = DemMag.initFromJLD("state_100_0260000.jld"; vo = vo, transf=false)

stepInit = 0
stepEnd = 50_000
stepSaveSnap = 200
stepDisplay = 200
stepSaveState = 264440000


neighShellWidthCont = 0.1*rc_cont
neighCutCont = rc_cont + neighShellWidthCont
st.neighCon = neighborList(st, cellCont, neighCutCont)
maxDisplacementCont = 0.0


neighShellWidthMag = 0.1*rc_mag
neighCutMag = rc_mag + neighShellWidthMag
st.neighMag = neighborList(st, cellMag, neighCutMag)
maxDisplacementMag = 0.0

stp = []
pot = []
kin = []
println()
println("#-------------------- running ---------------------")
st.βn = 0.1
st.γn = 0.5

writeSnapshot(st, stepInit)
for t = stepInit+1:stepEnd

    U = demStep!(st, t)
    v2 = [dot(v, v) for v in st.v]
    w2 = [dot(w, w) for w in st.ω]
    K = 0.5 * sum(v2) + 0.5 * sum(w2)
    dmax = st.δt * sqrt(maximum(v2))

    global maxDisplacementMag += dmax
    if maxDisplacementMag > neighShellWidthMag
        st.neighMag = neighborList(st, cellMag, neighCutMag)
        global maxDisplacementMag = 0.0
    end

    global maxDisplacementCont += dmax
    if maxDisplacementCont > neighShellWidthCont
        st.neighCon = neighborList(st, cellCont,  neighCutCont; t=t)
        global maxDisplacementCont = 0.0
    end
    if mod(t, stepSaveSnap) == 0
        writeSnapshot(st, t)
    end
    if t > 0 && mod(t, stepSaveState) == 0
        dumpState(st, t)
    end

    if mod(t, stepDisplay) == 0
        push!(stp, t)
        push!(pot, U)
        push!(kin, K)
        # (lpad(t, 5, "0"))
        println("t = $t")
    end
end

plotly()
p1 = plot(stp, pot, label = "U")
# plot!(stp, kin, label = "K")
plot!(stp, pot .+ kin, label = "E")
