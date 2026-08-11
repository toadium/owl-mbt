///|
/// Reshape: change the shape of the array
pub fn reshape(x : T, new_shape : Array[Int]) -> T raise {
  match x {
    F(_) => x
    Arr(arr) => Arr(@ndarray.reshape(arr, new_shape))
    DF(ap, at, ai) => DF(reshape(ap, new_shape), reshape(at, new_shape), ai)
    DR(ap, _, _, _, ai, _) => {
      let cp = reshape(ap, new_shape)
      let captured_x = x
      let op : Op = {
        adjoint: fn(
          _cp : T,
          ca : Ref[T],
          t : Array[(T, T)],
        ) -> Array[(T, T)] raise {
          let orig_shape = shape(primal(captured_x))
          _prepend((reshape(ca.val, orig_shape), captured_x), t)
        },
        register: fn(t : Array[T]) -> Array[T] { _prepend(captured_x, t) },
        label_name: "reshape",
        label_parents: [captured_x],
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}

///|
/// Flatten: reshape to 1D (keeping batch dim)
pub fn flatten(x : T) -> T raise {
  match x {
    F(_) => x
    Arr(arr) => Arr(@ndarray.flatten(arr))
    DF(ap, at, ai) => DF(flatten(ap), flatten(at), ai)
    DR(ap, _, _, _, ai, _) => {
      let cp = flatten(ap)
      let captured_x = x
      let op : Op = {
        adjoint: fn(
          _cp : T,
          ca : Ref[T],
          t : Array[(T, T)],
        ) -> Array[(T, T)] raise {
          let orig_shape = shape(primal(captured_x))
          _prepend((reshape(ca.val, orig_shape), captured_x), t)
        },
        register: fn(t : Array[T]) -> Array[T] { _prepend(captured_x, t) },
        label_name: "flatten",
        label_parents: [captured_x],
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}

///|
/// Get a slice of the array
pub fn get_slice(index_list : Array[Array[Int]], x : T) -> T raise {
  match x {
    F(_) => x
    Arr(arr) => Arr(@ndarray.get_slice(index_list, arr))
    DF(ap, at, ai) =>
      DF(get_slice(index_list, ap), get_slice(index_list, at), ai)
    DR(ap, _, _, _, ai, _) => {
      let cp = get_slice(index_list, ap)
      let captured_x = x
      let op : Op = {
        adjoint: fn(
          _cp : T,
          ca : Ref[T],
          t : Array[(T, T)],
        ) -> Array[(T, T)] raise {
          let orig_shape = shape(primal(captured_x))
          let full_slice = Array::make(orig_shape.length(), [])
          _prepend(
            (set_slice(full_slice, index_list, ca.val, orig_shape), captured_x),
            t,
          )
        },
        register: fn(t : Array[T]) -> Array[T] { _prepend(captured_x, t) },
        label_name: "get_slice",
        label_parents: [captured_x],
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}

///|
/// Set a slice of the array (helper for get_slice backward)
fn set_slice(
  _full_slice : Array[Array[Int]],
  index_list : Array[Array[Int]],
  val : T,
  orig_shape : Array[Int],
) -> T raise {
  match val {
    F(_) => val
    Arr(arr) => {
      let result = @ndarray.zeros(orig_shape)
      Arr(@ndarray.set_slice(index_list, result, arr))
    }
    _ => val
  }
}

///|
/// Softmax along specified axis
pub fn softmax(x : T, axis? : Int = -1) -> T raise {
  match x {
    F(_) => F(1.0)
    Arr(arr) => Arr(@ndarray.softmax(arr, axis~))
    DF(ap, at, ai) => {
      let cp = softmax(ap, axis~)
      let sum_at = sum(mul(at, cp), axis~, keep_dims=true)
      DF(cp, sub(mul(at, cp), mul(cp, sum_at)), ai)
    }
    DR(ap, _, _, _, ai, _) => {
      let cp = softmax(ap, axis~)
      let captured_x = x
      let op : Op = {
        adjoint: fn(
          _cp : T,
          ca : Ref[T],
          t : Array[(T, T)],
        ) -> Array[(T, T)] raise {
          let s = sum(mul(ca.val, cp), axis~, keep_dims=true)
          _prepend((sub(mul(ca.val, cp), mul(cp, s)), captured_x), t)
        },
        register: fn(t : Array[T]) -> Array[T] { _prepend(captured_x, t) },
        label_name: "softmax",
        label_parents: [captured_x],
      }
      DR(cp, Ref(zero(cp)), op, Ref(0), ai, Ref(0))
    }
  }
}
