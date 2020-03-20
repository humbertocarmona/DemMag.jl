using DemMag
using LinearAlgebra
using ArgParse
using DataFrames
using CSV
using Dates,Logging

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--np"
        arg_type = Int
        default = 100
        "--ti"
        arg_type = Int
        default = 0
        "--tf"
        arg_type = Int
        default = 100_000
        "--ts"
        arg_type = Int
        default = 5000
        "--tst"
        arg_type = Int
        default = 100_000
        "--runid"
        arg_type = String
        default = "000"
        "--g"
        arg_type = Float64
        nargs = 3
        default = [0.0, 0.0, -0.001]
        "--v0"
        arg_type = Float64
        nargs = 3
        default = [0.0, 0.0, 0.0]
        "--mag"
        arg_type = Float64
        nargs = 3
        default = [0.0, 0.3, 0.0]
    end
    return parse_args(s)
end
parsed_args = parse_commandline()



np = parsed_args["np"]

stepInit = parsed_args["ti"]
stepEnd = parsed_args["tf"]
stepSaveSnap = parsed_args["ts"]
stepSaveState = parsed_args["tst"]
runid = parsed_args["runid"]
g = parsed_args["g"]
v0 = parsed_args["v0"]
mag = parsed_args["mag"]

resdir = runid
mkpath(resdir)


diam = 1.0          # diametro da partícula
rc_con = 1.1*diam   # raio de corte para forca de contato
rc_mag = 5.1*diam   # raio de corte para força magnética
cellCont = [rc_con, rc_con, rc_con]  # tamanho das células para forca de contato
cellMag =  [rc_mag, rc_mag, rc_mag]  # tamanho das células para forca magnetica
L = [np*rc_con, 2*np*rc_con, 3*rc_mag] # tamanho da área de simulacao

tinit = Dates.now()
tinits = Dates.format(tinit, "ddmmyy-HHhMM-SS")
io = open("$resdir/$runid-$tinits.log", "w+")
logger = SimpleLogger(io, Logging.Info)
# global_logger(logger)
with_logger(logger) do
    @info("--------------------------
    $(Dates.format(tinit, "yy-mm-dd H:M"))
    np = $np, L = $(round.(L; digits=3)), vo = $(round.(v0; digits=3)),
    mag = $(round.(mag; digits=3))
    --------------------------")
    flush(io)

    # inicializaca como um fio de tamanho N -
    st = initAsWire(N=np,
                    L=L,
                    diam=diam,
                    mag=mag,
                    vo=v0,
                    ro=[0.0, np, 0.5])

    st.g = g
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
    for t = stepInit:stepEnd
        U = demStep!(st, t)
        v2 = [dot(v, v) for v in st.v]
        w2 = [dot(w, w) for w in st.ω]
        K = 0.5 * sum(v2) + 0.5 * sum(w2)
        dmax = st.δt * sqrt(maximum(v2))

        maxDisplacementMag += dmax
        if maxDisplacementMag > neighShellWidthMag
            st.neighMag = neighborList(st, cellMag, neighCutMag)
            maxDisplacementMag = 0.0
        end

        maxDisplacementCont += dmax
        if maxDisplacementCont > neighShellWidthCont
            st.neighCon = neighborList(st, cellCont,  neighCutCont; t=t)
            maxDisplacementCont = 0.0
        end
        if t > 0 && mod(t, stepSaveState) == 0
            dumpState(st, t, folder=resdir)
        end

        if mod(t, stepSaveSnap) == 0
            push!(stp, t)
            push!(pot, U)
            push!(kin, K)
            writeSnapshot(st, t, folder=resdir)
            df = DataFrame(t=stp, u=pot, k=kin)
            CSV.write("$resdir/$runid.csv", df)
            @info("t = $t")
            flush(io)
        end
    end
    tend = Dates.now()
    dur = Dates.canonicalize(Dates.CompoundPeriod(tend - tinit))
    @info("----------- finished -----------------
    $(Dates.format(tend, "yy-mm-dd H:M"))
    took  $dur
    --------------------------------------------")
    flush(io)
end
close(io)
