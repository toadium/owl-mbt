///|
/// Sum of all elements, returns scalar AD node.
pub fn sum_(x : T) -> T raise {
  match x {
    F(_) => x
    Arr(arr) => F(@ndarray.sum_(arr))
    DF(ap, at, ai) => {
      let cp = sum_(ap)
      DF(cp, sum_(at), ai)
    }
    DR(ap, _, _, _, ai, _) => {
      let cp = sum_(ap)
      let captured_x = x
      let op : Op = {
        adjoint: fn(
          _cp : T,
          ca : Ref[T],
          t : Array[(T, T)],
        ) -> Array[(T, T)] raise {
          let ones = match primal_(captured_x) {
            F(_) => F(1.0)
            Arr(arr) => Arr(@ndarray.ones(arr.shape))
            _ => F(1.0)
          }
          _prepend((mul(ca.val, ones), captured_x), t)
        },
        register: fn(t : Array[T]) -> Array[T] { _prepend(captured_x, t) },
        label_name: "sum_",
        label_parents: [captured_x],
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}

///|
/// Sum along an axis, returns array AD node.
pub fn sum(x : T, axis? : Int = -1, keep_dims? : Bool = true) -> T raise {
  match x {
    F(_) => x
    Arr(arr) => Arr(@ndarray.sum(arr, axis~, keep_dims~))
    DF(ap, at, ai) => {
      let cp = sum(ap, axis~, keep_dims~)
      DF(cp, sum(at, axis~, keep_dims~), ai)
    }
    DR(ap, _, _, _, ai, _) => {
      let cp = sum(ap, axis~, keep_dims~)
      let captured_x = x
      let captured_axis = axis
      let captured_keep_dims = keep_dims
      let op : Op = {
        adjoint: fn(
          _cp : T,
          ca : Ref[T],
          t : Array[(T, T)],
        ) -> Array[(T, T)] raise {
          let grad = match primal_(captured_x) {
            Arr(arr) => {
              let orig_shape = arr.shape
              if captured_axis < 0 {
                Arr(@ndarray.ones(orig_shape))
              } else {
                let ca_arr = match primal_(ca.val) {
                  Arr(a) => a
                  _ =>
                    raise @types.OwlError::InvalidArgument(
                      "sum: adjoint expects array",
                    )
                }
                let ca_shape = ca_arr.shape
                if captured_keep_dims {
                  let reps = Array::make(orig_shape.length(), 1)
                  reps[captured_axis] = orig_shape[captured_axis]
                  Arr(@ndarray.repeat(ca_arr, reps))
                } else {
                  let expanded_shape = []
                  let mut ca_idx = 0
                  for i in 0..<orig_shape.length() {
                    if i == captured_axis {
                      expanded_shape.push(1)
                    } else {
                      expanded_shape.push(ca_shape[ca_idx])
                      ca_idx += 1
                    }
                  }
                  let expanded = @ndarray.reshape(ca_arr, expanded_shape)
                  let reps = Array::make(orig_shape.length(), 1)
                  reps[captured_axis] = orig_shape[captured_axis]
                  Arr(@ndarray.repeat(expanded, reps))
                }
              }
            }
            _ => F(1.0)
          }
          if captured_axis < 0 {
            _prepend((mul(ca.val, grad), captured_x), t)
          } else {
            _prepend((grad, captured_x), t)
          }
        },
        register: fn(t : Array[T]) -> Array[T] { _prepend(captured_x, t) },
        label_name: "sum",
        label_parents: [captured_x],
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}
