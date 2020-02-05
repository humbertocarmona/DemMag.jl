pr4 = SVector{4}([19.0 / 24,
                  -10.0 / 24,
                  3.0 / 24,
                  0])
pv4 = SVector{4}([27.0 / 24,
                  -22.0 / 24,
                  7.0 / 24,
                  0])
cr4 = SVector{4}([3.0 / 24,
                  10.0 / 24,
                  -1.0 / 24,
                  0])
cv4 = SVector{4}([7.0 / 24,
                  6.0 / 24,
                  -1 / 24,
                  0])

pr = SVector{4}([323.0 / 360.0,
                  -264.0 / 360.0,
                  159.0 / 360.0,
                  -38.0 / 360.0])
pv = SVector{4}([502.0 / 360.0,
                  -621.0 / 360.0,
                  396.0 / 360.0,
                  -97.0 / 360.0])
cr = SVector{4}([38.0 / 360.0,
                  171.0 / 360.0,
                  -36.0 / 360.0,
                  7.0 / 360.0])
cv = SVector{4}([97.0 / 360.0,
                  114.0 / 360.0,
                  -39.0 / 360.0,
                  8.0 / 360.0])

function predictor!(p::State)
      p.r0 = copy(p.r)
      p.v0 = copy(p.v)
      δt = p.δt
      δt2 = δt^2
      for i = 1:p.N
            p.r[i] = p.r[i] + δt * p.v[i] +
                     δt2 * (pr[1] * p.a[i] + pr[2] * p.a1[i] + pr[3] * p.a2[i] +
                      pr[4] * p.a3[i])

            p.v[i] = (p.r[i] - p.r0[i]) / δt +
                     δt * (pv[1] * p.a[i] + pv[2] * p.a1[i] + pv[3] * p.a2[i] +
                      pv[4] * p.a3[i])


      end

      p.a3 = copy(p.a2)
      p.a2 = copy(p.a1)
      p.a1 = copy(p.a)

      return p
end

function corrector!(p::State)
      δt = p.δt
      δt2 = δt^2
      for i = 1:p.N
            p.r[i] = p.r0[i] + δt * p.v0[i] +
                     δt2 * (cr[1] * p.a[i] + cr[2] * p.a1[i] +
                            cr[3] * p.a2[i] + cr[4] * p.a3[i])

            p.v[i] = (p.r[i] - p.r0[i]) / δt +
                     δt * (cv[1] * p.a[i] + cv[2] * p.a1[i] +
                           cv[3] * p.a2[i] +  cv[4] * p.a3[i])

      end

      return p
end

function predictorQ!(p::State)
      p.q0 = copy(p.q)
      p.qv0 = copy(p.qv)
      δt = p.δt
      δt2 = δt^2
      for i = 1:p.N
            p.q[i] = p.q0[i] + δt * p.qv[i] +
                     δt2 * (pr[1] * p.qa[i] +  pr[2] * p.qa1[i] +
                            pr[3] * p.qa2[i] + pr[4] * p.qa3[i])

            p.qv[i] = (p.q[i] - p.q0[i]) / δt +
                     δt * (pv[1] * p.qa[i] + pv[2] * p.qa1[i] +
                           pv[3] * p.qa2[i] + pv[4] * p.qa3[i])

            if !p.q[i].norm
                  p.q[i] = Quaternions.normalize(p.q[i])
            end
            R = rotationmatrix(p.q[i])
            p.m[i] = R*p.m0[i]
            # p.m[i] = rotationQ(p.q[i], p.m0[i])
            p.w[i] = evalW(p.q[i], p.qv[i])
      end
      p.qa3 = copy(p.qa2)
      p.qa2 = copy(p.qa1)
      p.qa1 = copy(p.qa)

      return p
end

function correctorQ!(p::State)
      δt = p.δt
      δt2 = δt^2
      for i = 1:p.N
            p.q[i] = p.q0[i] + δt * p.qv0[i] +
                     δt2 * (cr[1] * p.qa[i] +  cr[2] * p.qa1[i] +
                            cr[3] * p.qa2[i] + cr[4] * p.qa3[i])

            p.qv[i] = (p.q[i] - p.q0[i]) / δt +
                      δt * (cv[1] * p.qa[i] +  cv[2] * p.qa1[i] +
                            cv[3] * p.qa2[i] + cv[4] * p.qa3[i])
            # if !p.q[i].norm
            #       p.q[i] = Quaternions.normalize(p.q[i])
            # end
      end

      return p
end


function computeQa!(p::State)
      for i = 1:p.N
            p.qa[i] = evalQa(p.q[i], p.qv[i], p.τ[i])
      end
end
