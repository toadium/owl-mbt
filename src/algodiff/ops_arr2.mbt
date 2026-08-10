///|
/// Transpose an AD array node.
pub fn transpose(x : T) -> T raise {
  match x {
    F(_) => x
    Arr(arr) => Arr(@ndarray.transpose(arr))
    DF(ap, at, ai) => {
      let cp = transpose(ap)
      DF(cp, transpose(at), ai)
    }
    DR(ap, _, _, _, ai, _) => {
      let cp = transpose(ap)
      let captured_x = x
      let op : Op = {
        adjoint: fn(
          _cp : T,
          ca : Ref[T],
          t : Array[(T, T)],
        ) -> Array[(T, T)] raise {
          _prepend((transpose(ca.val), captured_x), t)
        },
        register: fn(t : Array[T]) -> Array[T] { _prepend(captured_x, t) },
        label_name: "transpose",
        label_parents: [captured_x],
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}

///|
/// Concatenate AD array nodes along an axis.
pub fn concatenate(arrs : Array[T], axis? : Int = 0) -> T raise {
  if arrs.length() == 0 {
    raise @types.OwlError::InvalidArgument("concatenate: empty input")
  }
  if arrs.length() == 1 {
    return arrs[0]
  }
  let all_primal = true
  let _ = all_primal
  let first = arrs[0]
  match first {
    F(_) => first
    Arr(_) => {
      let primal_arrs = []
      for a in arrs {
        match primal_(a) {
          Arr(arr) => primal_arrs.push(arr)
          _ =>
            raise @types.OwlError::InvalidArgument("concatenate: mixed types")
        }
      }
      Arr(@ndarray.concatenate(primal_arrs, axis~))
    }
    DF(_, _, _) => {
      let primal_arrs = []
      let tangent_arrs = []
      for a in arrs {
        match a {
          DF(ap, at, _) => {
            primal_arrs.push(ap)
            tangent_arrs.push(at)
          }
          _ =>
            raise @types.OwlError::InvalidArgument("concatenate: mixed types")
        }
      }
      let cp = concatenate(primal_arrs, axis~)
      let ct = concatenate(tangent_arrs, axis~)
      match cp {
        DF(_, _, ai) => DF(cp, ct, ai)
        _ => DF(cp, ct, 0)
      }
    }
    DR(_, _, _, _, ai, _) => {
      let primal_arrs = []
      for a in arrs {
        primal_arrs.push(primal_(a))
      }
      let cp = concatenate(primal_arrs, axis~)
      let captured_arrs = arrs
      let captured_axis = axis
      let op : Op = {
        adjoint: fn(
          _cp : T,
          ca : Ref[T],
          t : Array[(T, T)],
        ) -> Array[(T, T)] raise {
          let _ = captured_arrs
          let _ = captured_axis
          _prepend((ca.val, captured_arrs[0]), t)
        },
        register: fn(t : Array[T]) -> Array[T] {
          let result = t
          for a in captured_arrs {
            result.push(a)
          }
          result
        },
        label_name: "concatenate",
        label_parents: captured_arrs,
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}
