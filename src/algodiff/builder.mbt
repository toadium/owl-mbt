///|
/// Prepend element to array.
fn[T] _prepend(x : T, rest : Array[T]) -> Array[T] {
  let result = [x]
  for item in rest {
    result.push(item)
  }
  result
}

///|
/// Prepend two elements to array.
fn[T] _prepend2(x : T, y : T, rest : Array[T]) -> Array[T] {
  let result = [x, y]
  for item in rest {
    result.push(item)
  }
  result
}

///|
/// SISO dispatch helper: single input, single output operation.
fn siso_op(
  rec_fn : (T) -> T raise,
  a : T,
  label : String,
  ff_f : (Double) -> T,
  ff_arr : (@ndarray.Ndarray) -> T,
  df : (T, T, T) -> T raise,
  dr : (T, T, Ref[T]) -> T raise,
) -> T raise {
  match a {
    F(v) => ff_f(v)
    Arr(v) => ff_arr(v)
    DF(ap, at, ai) => {
      let cp = rec_fn(ap)
      DF(cp, df(cp, ap, at), ai)
    }
    DR(ap, _, _, _, ai, _) => {
      let cp = rec_fn(ap)
      let captured_a = a
      let captured_dr = dr
      let op : Op = {
        adjoint: fn(
          cp_ : T,
          ca : Ref[T],
          t : Array[(T, T)],
        ) -> Array[(T, T)] raise {
          _prepend((captured_dr(primal(captured_a), cp_, ca), captured_a), t)
        },
        register: fn(t : Array[T]) -> Array[T] { _prepend(captured_a, t) },
        label_name: label,
        label_parents: [captured_a],
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}

///|
/// PISO dispatch helper: pair input, single output operation.
fn piso_op(
  rec_fn : (T, T) -> T raise,
  a : T,
  b : T,
  label : String,
  ff_aa : (Double, Double) -> T,
  ff_ab : (Double, @ndarray.Ndarray) -> T,
  ff_ba : (@ndarray.Ndarray, Double) -> T,
  ff_bb : (@ndarray.Ndarray, @ndarray.Ndarray) -> T raise,
  df_da : (T, T, T, T) -> T raise,
  df_db : (T, T, T, T) -> T raise,
  df_dab : (T, T, T, T, T) -> T raise,
  dr_ab : (T, T, T, Ref[T]) -> (T, T) raise,
  dr_a : (T, T, T, Ref[T]) -> T raise,
  dr_b : (T, T, T, Ref[T]) -> T raise,
) -> T raise {
  let cmp_tag = fn(ai : Int, bi : Int) -> Int {
    if ai > bi {
      1
    } else if ai < bi {
      -1
    } else {
      0
    }
  }
  match (a, b) {
    (F(_), DF(bp, bt, bi)) => {
      let cp = rec_fn(a, bp)
      DF(cp, df_db(cp, a, bp, bt), bi)
    }
    (DF(ap, at, ai), F(_)) => {
      let cp = rec_fn(ap, b)
      DF(cp, df_da(cp, ap, at, b), ai)
    }
    (Arr(_), DF(bp, bt, bi)) => {
      let cp = rec_fn(a, bp)
      DF(cp, df_db(cp, a, bp, bt), bi)
    }
    (DF(ap, at, ai), Arr(_)) => {
      let cp = rec_fn(ap, b)
      DF(cp, df_da(cp, ap, at, b), ai)
    }
    (F(_), DR(bp, _, _, _, bi, _)) => {
      let cp = rec_fn(a, bp)
      let op = make_piso_op_c_d(label, a, b, dr_b)
      DR(cp, Ref(zero(cp)), op, Ref(0), bi, Ref(0))
    }
    (DR(ap, _, _, _, ai, _), F(_)) => {
      let cp = rec_fn(ap, b)
      let op = make_piso_op_d_c(label, a, b, dr_a)
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
    (Arr(_), DR(bp, _, _, _, bi, _)) => {
      let cp = rec_fn(a, bp)
      let op = make_piso_op_c_d(label, a, b, dr_b)
      DR(cp, Ref(zero(cp)), op, Ref(0), bi, Ref(0))
    }
    (DR(ap, _, _, _, ai, _), Arr(_)) => {
      let cp = rec_fn(ap, b)
      let op = make_piso_op_d_c(label, a, b, dr_a)
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
    (DF(ap, at, ai), DR(bp, _, _, _, bi, _)) =>
      match cmp_tag(ai, bi) {
        1 => {
          let cp = rec_fn(ap, b)
          DF(cp, df_da(cp, ap, at, b), ai)
        }
        -1 => {
          let cp = rec_fn(a, bp)
          let op = make_piso_op_c_d(label, a, b, dr_b)
          DR(cp, Ref(zero(cp)), op, Ref(0), bi, Ref(0))
        }
        _ =>
          raise @types.OwlError::InvalidArgument(
            "forward and reverse clash at the same level",
          )
      }
    (DR(ap, _, _, _, ai, _), DF(bp, bt, bi)) =>
      match cmp_tag(ai, bi) {
        -1 => {
          let cp = rec_fn(a, bp)
          DF(cp, df_db(cp, a, bp, bt), bi)
        }
        1 => {
          let cp = rec_fn(ap, b)
          let op = make_piso_op_d_c(label, a, b, dr_a)
          DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
        }
        _ =>
          raise @types.OwlError::InvalidArgument(
            "forward and reverse clash at the same level",
          )
      }
    (DF(ap, at, ai), DF(bp, bt, bi)) =>
      match cmp_tag(ai, bi) {
        0 => {
          let cp = rec_fn(ap, bp)
          DF(cp, df_dab(cp, ap, at, bp, bt), ai)
        }
        1 => {
          let cp = rec_fn(ap, b)
          DF(cp, df_da(cp, ap, at, b), ai)
        }
        _ => {
          let cp = rec_fn(a, bp)
          DF(cp, df_db(cp, a, bp, bt), bi)
        }
      }
    (DR(ap, _, _, _, ai, _), DR(bp, _, _, _, bi, _)) =>
      match cmp_tag(ai, bi) {
        0 => {
          let cp = rec_fn(ap, bp)
          let op = make_piso_op_d_d(label, a, b, dr_ab)
          DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
        }
        1 => {
          let cp = rec_fn(ap, b)
          let op = make_piso_op_d_c(label, a, b, dr_a)
          DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
        }
        _ => {
          let cp = rec_fn(a, bp)
          let op = make_piso_op_c_d(label, a, b, dr_b)
          DR(cp, Ref(zero(cp)), op, Ref(0), bi, Ref(0))
        }
      }
    (F(av), F(bv)) => ff_aa(av, bv)
    (F(av), Arr(bv)) => ff_ab(av, bv)
    (Arr(av), F(bv)) => ff_ba(av, bv)
    (Arr(av), Arr(bv)) => ff_bb(av, bv)
  }
}

///|
fn make_piso_op_d_d(
  label : String,
  a : T,
  b : T,
  dr_ab : (T, T, T, Ref[T]) -> (T, T) raise,
) -> Op {
  let captured_a = a
  let captured_b = b
  let captured_dr_ab = dr_ab
  {
    adjoint: fn(cp : T, ca : Ref[T], t : Array[(T, T)]) -> Array[(T, T)] raise {
      let (abar, bbar) = captured_dr_ab(
        primal(captured_a),
        primal(captured_b),
        cp,
        ca,
      )
      _prepend2((abar, captured_a), (bbar, captured_b), t)
    },
    register: fn(t : Array[T]) -> Array[T] {
      _prepend2(captured_a, captured_b, t)
    },
    label_name: label + "_d_d",
    label_parents: [captured_a, captured_b],
  }
}

///|
fn make_piso_op_d_c(
  label : String,
  a : T,
  b : T,
  dr_a : (T, T, T, Ref[T]) -> T raise,
) -> Op {
  let captured_a = a
  let captured_b = b
  let captured_dr_a = dr_a
  {
    adjoint: fn(cp : T, ca : Ref[T], t : Array[(T, T)]) -> Array[(T, T)] raise {
      _prepend(
        (captured_dr_a(primal(captured_a), captured_b, cp, ca), captured_a),
        t,
      )
    },
    register: fn(t : Array[T]) -> Array[T] { _prepend(captured_a, t) },
    label_name: label + "_d_c",
    label_parents: [captured_a, captured_b],
  }
}

///|
fn make_piso_op_c_d(
  label : String,
  a : T,
  b : T,
  dr_b : (T, T, T, Ref[T]) -> T raise,
) -> Op {
  let captured_a = a
  let captured_b = b
  let captured_dr_b = dr_b
  {
    adjoint: fn(cp : T, ca : Ref[T], t : Array[(T, T)]) -> Array[(T, T)] raise {
      _prepend(
        (captured_dr_b(captured_a, primal(captured_b), cp, ca), captured_b),
        t,
      )
    },
    register: fn(t : Array[T]) -> Array[T] { _prepend(captured_b, t) },
    label_name: label + "_c_d",
    label_parents: [captured_a, captured_b],
  }
}
