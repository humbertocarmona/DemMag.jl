function constrain!(p::State,
                    Ri::Float64 = 300.0)

    yc = 0.5*p.L[2]
    for i = 1:p.N
        if  p.active[i] == 0 && p.r[i][2] >= yc
            p.active[i] = 1
            p.lastactive = i
        end
        if p.active[i] == 0
            θ = 0.0
            if Ri < 201.0
                global θ = getΘ(p.r[i], p.L; Ri=Ri)
            end
            qo = qrotation([0.,0.,1.], θ)
            Ro = rotationmatrix(qo)
            p.v[i] = Ro*p.vinit
            p.m[i] = Ro*p.dipmag
            p.m0[i] = copy(p.m[i])
            p.a[i] = [0.0,0.0,0.0]
            p.a1[i] = [0.0,0.0,0.0]
            p.a2[i] = [0.0,0.0,0.0]
            p.a3[i] = [0.0,0.0,0.0]
            p.τ[i] = [0.0,0.0,0.0]
        end
    end
end


function getΘ(r::Vector{Float64},L::Vector{Float64}; Ri=50.0)
    θ = atan(-0.5*L[2]+r[2],Ri - (0.5*L[1]- r[1]) )
end
