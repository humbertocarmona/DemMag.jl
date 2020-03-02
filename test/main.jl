using DemMag
using LinearAlgebra
using Quaternions
using Plots

println("#------------------- ------- ---------------------")
mkpath("snaps")
removeFilesMaching(r"snap_.+\.vtu", "./snaps/")
println("#------------------- ------- ---------------------")


N = 100             # número de partículas
diam = 1.0          # diametro da partícula
rc_con = 1.1*diam   # raio de corte para forca de contato
rc_mag = 5.1*diam   # raio de corte para força magnética
cellCont = [rc_con, rc_con, rc_con]  # tamanho das células para forca de contato
cellMag =  [rc_mag, rc_mag, rc_mag]  # tamanho das células para forca magnetica
L = [N*rc_con, 2*N*rc_con, 3*rc_mag] # tamanho da área de simulacao
println("L = $L")
mag = [0.0, 0.3, 0.0]  # momento magnético de cada bolinha
vo = [0.0,0.0,0.0]     # velocidade inicial

# inicializaca como um fio de tamanho N
st = initAsWire(N=N,
                L=L,
                diam=diam,
                mag=mag,
                vo=vo,
                ro=[0.0, 100.5, 0.5])

# st = initFromCSV("test/inputdata.csv", L=L)

# st,t0 = DemMag.initFromJLD("s1.jld";
#                             nin = 6, # 6 bolinhas dentro da caixa
#                             vo = vo,
#                             transf=true  # transforma posicao das bolinhas apropriadamente
#                             )

stepInit = 0
stepEnd = 100_000
stepSaveSnap = 5000
stepDisplay = 5000
stepSaveState = 500_000

st.g = [0.000, 0.000, -0.001]
st.L = L

st.βn = 0.1  # atrito viscoso global
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
