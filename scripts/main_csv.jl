using DemMag
using LinearAlgebra
using Quaternions
using Plots

println("#------------------- ------- ---------------------")
mkpath("snaps")
removeFilesMaching(r"snap_.+\.vtu", "./snaps/")
println("#------------------- ------- ---------------------")


st = initFromCSV("test/inputdata.csv")
N = st.N
diam = 2*st.R
rc_con = 1.1*diam   # raio de corte para forca de contato
rc_mag = 5.1*diam   # raio de corte para força magnética
cellCont = [rc_con, rc_con, rc_con]  # tamanho das células para forca de contato
cellMag =  [rc_mag, rc_mag, rc_mag]  # tamanho das células para forca magnetica
L = [5*rc_con, 100*rc_con, 3*rc_mag] # tamanho da área de simulacao
st.L = L
println("L = $L")

stepInit = 0
stepEnd = 100_000
stepSaveSnap = 1000
stepDisplay = 5000
stepSaveState = 500_000

st.g = [0.000, 0.000, -0.001]

st.βn = 0.001  # atrito viscoso global
st.γn = 0.1  # atrito normal aos planos
st.kt = 0.1  # atrito tangencial aos planos
st.μ = 0.5   # coulomb static friction particle-planes...

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
for t = stepInit:stepEnd
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

# plotly()
# p1 = plot(stp, pot, label = "U")
# # plot!(stp, kin, label = "K")
# plot!(stp, pot .+ kin, label = "E")
