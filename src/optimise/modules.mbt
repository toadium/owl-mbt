///|
/// Execute learning rate strategy.
/// Returns: (iteration, gradient, cache) -> learning_rate
fn run_learning_rate(
  typ : LearningRate,
  i : Int,
  g : @algodiff.T,
  c : Array[@algodiff.T],
) -> @algodiff.T raise {
  match typ {
    Adagrad(a) =>
      @algodiff.div(
        @algodiff.pack_flt(a),
        @algodiff.sqrt(@algodiff.add(c[0], @algodiff.pack_flt(1.0e-32))),
      )
    Const(a) => @algodiff.pack_flt(a)
    Decay(a, k) =>
      @algodiff.div(
        @algodiff.pack_flt(a),
        @algodiff.add(
          @algodiff.pack_flt(1.0),
          @algodiff.mul(
            @algodiff.pack_flt(k),
            @algodiff.pack_flt(i.to_double()),
          ),
        ),
      )
    ExpDecay(a, k) =>
      @algodiff.mul(
        @algodiff.pack_flt(a),
        @algodiff.exp(
          @algodiff.mul(
            @algodiff.neg(@algodiff.pack_flt(k)),
            @algodiff.pack_flt(i.to_double()),
          ),
        ),
      )
    RMSprop(a, _) =>
      @algodiff.div(
        @algodiff.pack_flt(a),
        @algodiff.sqrt(@algodiff.add(c[0], @algodiff.pack_flt(1.0e-32))),
      )
    Adam(a, b1, b2) => {
      // Note: the denominator includes an extra (g + 1e-32) factor compared to
      // the standard Adam formula (lr = a * sqrt(1-b2^t)/(1-b1^t) * m / (sqrt(v)+eps)).
      // This is faithfully ported from the OCaml Owl source. The extra factor causes
      // the effective learning rate to scale inversely with the gradient magnitude.
      let bias_corr1 = 1.0 - @math.pow(b1, i.to_double())
      let bias_corr2 = 1.0 - @math.pow(b2, i.to_double())
      @algodiff.div(
        @algodiff.mul(
          @algodiff.mul(
            @algodiff.mul(
              @algodiff.pack_flt(a),
              @algodiff.pack_flt(bias_corr2.sqrt()),
            ),
            @algodiff.div(
              @algodiff.pack_flt(1.0),
              @algodiff.pack_flt(bias_corr1),
            ),
          ),
          c[0],
        ),
        @algodiff.mul(
          @algodiff.add(@algodiff.sqrt(c[1]), @algodiff.pack_flt(1.0e-8)),
          @algodiff.add(g, @algodiff.pack_flt(1.0e-32)),
        ),
      )
    }
    Schedule(a) => @algodiff.pack_flt(a[i % a.length()])
  }
}

///|
/// Update cache for learning rate.
fn update_ch(
  typ : LearningRate,
  g : @algodiff.T,
  ch : Array[@algodiff.T],
) -> Array[@algodiff.T] raise {
  match typ {
    Adagrad(_) => {
      ch[0] = @algodiff.add(ch[0], @algodiff.mul(g, g))
      ch
    }
    RMSprop(_, _) => {
      ch[0] = @algodiff.add(ch[0], @algodiff.mul(g, g))
      ch
    }
    Adam(_, b1, b2) => {
      ch[0] = @algodiff.add(
        @algodiff.mul(@algodiff.pack_flt(b1), ch[0]),
        @algodiff.mul(@algodiff.pack_flt(1.0 - b1), g),
      )
      ch[1] = @algodiff.add(
        @algodiff.mul(@algodiff.pack_flt(b2), ch[1]),
        @algodiff.mul(@algodiff.pack_flt(1.0 - b2), @algodiff.mul(g, g)),
      )
      ch
    }
    _ => ch
  }
}

///|
/// Execute gradient method.
/// Returns: (f, w, g_prev, p_prev, g') -> direction
fn run_gradient(
  typ : GradientMethod,
  _f : (@algodiff.T) -> @algodiff.T raise,
  _w : @algodiff.T,
  g_prev : @algodiff.T,
  p_prev : @algodiff.T,
  g_new : @algodiff.T,
) -> @algodiff.T raise {
  match typ {
    GD => @algodiff.neg(g_new)
    CG => {
      let y = @algodiff.sub(g_new, g_prev)
      let b = @algodiff.div(
        @algodiff.sum_(@algodiff.mul(g_new, y)),
        @algodiff.add(
          @algodiff.sum_(@algodiff.mul(p_prev, y)),
          @algodiff.pack_flt(1.0e-32),
        ),
      )
      @algodiff.add(@algodiff.neg(g_new), @algodiff.mul(b, p_prev))
    }
    CD => {
      let b = @algodiff.div(
        @algodiff.sum_(@algodiff.mul(g_new, g_new)),
        @algodiff.sum_(@algodiff.mul(@algodiff.neg(p_prev), g_prev)),
      )
      @algodiff.add(@algodiff.neg(g_new), @algodiff.mul(b, p_prev))
    }
    NonlinearCG => {
      let b = @algodiff.div(
        @algodiff.sum_(@algodiff.mul(g_new, g_new)),
        @algodiff.sum_(@algodiff.mul(g_prev, g_prev)),
      )
      @algodiff.add(@algodiff.neg(g_new), @algodiff.mul(b, p_prev))
    }
    DaiYuanCG => {
      let y = @algodiff.sub(g_new, g_prev)
      let b = @algodiff.div(
        @algodiff.sum_(@algodiff.mul(g_new, g_new)),
        @algodiff.sum_(@algodiff.mul(p_prev, y)),
      )
      @algodiff.add(@algodiff.neg(g_new), @algodiff.mul(b, p_prev))
    }
    NewtonCG => @algodiff.neg(g_new)
    Newton => @algodiff.neg(g_new)
  }
}

///|
/// Execute momentum strategy.
fn run_momentum(
  typ : Momentum,
  u : @algodiff.T,
  u_new : @algodiff.T,
) -> @algodiff.T raise {
  match typ {
    Standard(m) => @algodiff.add(@algodiff.mul(@algodiff.pack_flt(m), u), u_new)
    Nesterov(m) =>
      @algodiff.add(
        @algodiff.mul(@algodiff.pack_flt(m * m), u),
        @algodiff.mul(@algodiff.pack_flt(m + 1.0), u_new),
      )
    None => u_new
  }
}

///|
/// Execute regularisation.
fn run_regularisation(
  typ : Regularisation,
  x : @algodiff.T,
) -> @algodiff.T raise {
  match typ {
    L1norm(a) =>
      @algodiff.mul(@algodiff.pack_flt(a), @algodiff.sum_(@algodiff.abs(x)))
    L2norm(a) =>
      @algodiff.mul(@algodiff.pack_flt(a), @algodiff.sum_(@algodiff.sqr(x)))
    ElasticNet(a, b) =>
      @algodiff.add(
        @algodiff.mul(@algodiff.pack_flt(a), @algodiff.sum_(@algodiff.abs(x))),
        @algodiff.mul(@algodiff.pack_flt(b), @algodiff.sum_(@algodiff.sqr(x))),
      )
    None => @algodiff.pack_flt(0.0)
  }
}

///|
/// Execute clipping. Note: all clipping types are currently no-op (not implemented).
#warnings("-unused_error_type")
fn run_clipping(typ : Clipping, x : @algodiff.T) -> @algodiff.T raise {
  match typ {
    L2norm(_) => x
    Value(_, _) => x
    None => x
  }
}

///|
/// Execute stopping criterion. Note: Early stopping is not implemented (returns false).
fn run_stopping(typ : Stopping, loss : Double) -> Bool {
  match typ {
    Const(threshold) => loss < threshold
    Early(_, _) => false
    None => false
  }
}
