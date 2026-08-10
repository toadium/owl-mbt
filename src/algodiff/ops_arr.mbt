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
            Arr(arr) => Arr(@ndarray.ones(arr.shape))
            _ => F(1.0)
          }
          let _ = captured_axis
          let _ = captured_keep_dims
          _prepend((mul(ca.val, grad), captured_x), t)
        },
        register: fn(t : Array[T]) -> Array[T] { _prepend(captured_x, t) },
        label_name: "sum",
        label_parents: [captured_x],
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}
