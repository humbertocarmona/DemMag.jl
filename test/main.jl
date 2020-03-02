using DemMag
using LinearAlgebra
using Test
using Quaternions
using Plots

println("#------------------- ------- ---------------------")
mkpath("snaps")
# removeFilesMaching(r"snap_.+\.vtu", "./snaps/")
println("#------------------- ------- ---------------------")


N = 100
diam = 1.0
rc_con = 1.1*diam
rc_mag = 5.1*diam
cellCont = [rc_con, rc_con, rc_con]
cellMag =  [rc_mag, rc_mag, rc_mag]
L = [N*rc_con, 2*N*rc_con, 3*rc_mag]
println("L = $L")
mag = [0.0, 0.3, 0.0]
vo = [0.0,0.0,0.0]
# st = initAsWire(N=N,
#                 L=L,
#                 diam=diam,
#                 mag=mag,
#                 vo=vo,
#                 ro=[0.0, 102.5, 0.5])
# st = initFromCSV("inputdata.csv", L=L)

st,t0 = DemMag.initFromJLD("st1.jld"; nin = 6, vo = vo, transf=true)

stepInit = 0
stepEnd = 1_000_000
stepSaveSnap = 5_000
stepDisplay = 5_000
stepSaveState = 200_000

st.g = [0.003, 0.0, -0.001]
st.L = L
st.βn = 0.1
st.γn = 0.5


neighShellWidthCont = 0.1*rc_con
neighCutCont = rc_con + neighShellWidthCont
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
