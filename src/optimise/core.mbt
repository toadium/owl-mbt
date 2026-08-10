///|
/// Minimise f : x -> y w.r.t. x using gradient descent.
/// Returns (state, optimised_x).
pub fn minimise_fun(
  params : Params,
  f : (@algodiff.T) -> @algodiff.T raise,
  x : @algodiff.T,
) -> (State, @algodiff.T) raise {
  let optz_fun = fn(xi : @algodiff.T) -> @algodiff.T raise {
    @algodiff.add(f(xi), run_regularisation(params.regularisation, xi))
  }
  let state = init_state(1, params.epochs)
  let (loss0, g0) = @algodiff.grad_prime(optz_fun, x)
  state.gs = [[g0]]
  state.ps = [[@algodiff.neg(g0)]]
  state.us = [[@algodiff.pack_flt(0.0)]]
  state.ch = [[[@algodiff.pack_flt(0.0), @algodiff.pack_flt(0.0)]]]
  state.loss[0] = @algodiff.primal(loss0)
  let x_ref = Ref(x)
  while !state.stop {
    let xi = x_ref.val
    let (loss_new, g_new) = @algodiff.grad_prime(optz_fun, xi)
    let loss_flt = @algodiff.unpack_flt(loss_new)
    state.stop = run_stopping(params.stopping, loss_flt)
    if state.current_batch < state.loss.length() {
      state.loss[state.current_batch] = loss_new
    }
    let g_clipped = run_clipping(params.clipping, g_new)
    let p_new = run_gradient(
      params.gradient,
      optz_fun,
      xi,
      state.gs[0][0],
      state.ps[0][0],
      g_clipped,
    )
    state.ch[0][0] = update_ch(params.learning_rate, g_clipped, state.ch[0][0])
    let rate = run_learning_rate(
      params.learning_rate,
      state.current_batch,
      g_clipped,
      state.ch[0][0],
    )
    let u_step = @algodiff.mul(p_new, rate)
    let u_new = run_momentum(params.momentum, state.us[0][0], u_step)
    x_ref.val = @algodiff.primal_(@algodiff.add(xi, u_new))
    match params.momentum {
      None => ()
      _ => state.us[0][0] = u_new
    }
    state.gs[0][0] = g_clipped
    state.ps[0][0] = p_new
    state.current_batch += 1
    if state.current_batch >= state.batches {
      state.stop = true
    }
  }
  (state, x_ref.val)
}
