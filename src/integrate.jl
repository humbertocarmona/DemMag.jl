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

function predictor!(st::State)
      st.r0 = copy(st.r)
      st.v0 = copy(st.v)
      δt = st.δt
      δt2 = δt^2
      for i = 1:st.N
            st.r[i] = st.r[i] + δt * st.v[i] +
                     δt2 * (pr[1] * st.a[i] + pr[2] * st.a1[i] + pr[3] * st.a2[i] +
                      pr[4] * st.a3[i])

            st.v[i] = (st.r[i] - st.r0[i]) / δt +
                     δt * (pv[1] * st.a[i] + pv[2] * st.a1[i] + pv[3] * st.a2[i] +
                      pv[4] * st.a3[i])
      end

      st.a3 = copy(st.a2)
      st.a2 = copy(st.a1)
      st.a1 = copy(st.a)

      return st
end

function corrector!(st::State)
      δt = st.δt
      δt2 = δt^2
      for i = 1:st.N
            st.r[i] = st.r0[i] + δt * st.v0[i] +
                     δt2 * (cr[1] * st.a[i] + cr[2] * st.a1[i] +
                            cr[3] * st.a2[i] + cr[4] * st.a3[i])

            st.v[i] = (st.r[i] - st.r0[i]) / δt +
                     δt * (cv[1] * st.a[i] + cv[2] * st.a1[i] +
                           cv[3] * st.a2[i] +  cv[4] * st.a3[i])
      end

      return st
end

function predictorQ!(st::State)
      st.q0 = copy(st.q)
      st.qv0 = copy(st.qv)
      δt = st.δt
      δt2 = δt^2
      for i = 1:st.N
            st.q[i] = st.q0[i] + δt * st.qv[i] +
                     δt2 * (pr[1] * st.qa[i] +  pr[2] * st.qa1[i] +
                            pr[3] * st.qa2[i] + pr[4] * st.qa3[i])

            st.qv[i] = (st.q[i] - st.q0[i]) / δt +
                     δt * (pv[1] * st.qa[i] + pv[2] * st.qa1[i] +
                           pv[3] * st.qa2[i] + pv[4] * st.qa3[i])

            if !st.q[i].norm
                  st.q[i] = Quaternions.normalize(st.q[i])
            end
            R = rotationmatrix(st.q[i])
            st.m[i] = R*st.m0[i]
            # st.m[i] = rotationQ(st.q[i], st.m0[i])
            st.ω[i] = evalW(st.q[i], st.qv[i])
      end
      st.qa3 = copy(st.qa2)
      st.qa2 = copy(st.qa1)
      st.qa1 = copy(st.qa)

      return st
end

function correctorQ!(st::State)
      δt = st.δt
      δt2 = δt^2
      for i = 1:st.N
            st.q[i] = st.q0[i] + δt * st.qv0[i] +
                     δt2 * (cr[1] * st.qa[i] +  cr[2] * st.qa1[i] +
                            cr[3] * st.qa2[i] + cr[4] * st.qa3[i])

            st.qv[i] = (st.q[i] - st.q0[i]) / δt +
                      δt * (cv[1] * st.qa[i] +  cv[2] * st.qa1[i] +
                            cv[3] * st.qa2[i] + cv[4] * st.qa3[i])
            # if !st.q[i].norm
            #       st.q[i] = Quaternions.normalize(st.q[i])
            # end
      end

      return st
end


function computeQa!(st::State)
      for i = 1:st.N
            st.qa[i] = evalQa(st.q[i], st.qv[i], st.τ[i])
      end
end
