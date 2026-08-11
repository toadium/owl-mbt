///|
/// Automatic differentiation type.
/// F: scalar primal value
/// Arr: array primal value
/// DF: forward mode node (primal, tangent, tag)
/// DR: reverse mode node (primal, adjoint ref, op, fanout ref, tag, tracker ref)
pub enum T {
  F(Double)
  Arr(@ndarray.Ndarray)
  DF(T, T, Int)
  DR(T, Ref[T], Op, Ref[Int], Int, Ref[Int])
}

///|
/// Operation descriptor for reverse mode AD.
pub struct Op {
  adjoint : (T, Ref[T], Array[(T, T)]) -> Array[(T, T)] raise
  register : (Array[T]) -> Array[T]
  label_name : String
  label_parents : Array[T]
}

///|
/// Global tag counter for AD nodes.
let _global_tag : Ref[Int] = Ref(0)

///|
/// Generate a new unique tag.
pub fn tag() -> Int {
  _global_tag.val += 1
  _global_tag.val
}

///|
/// Reset the global tag counter.
pub fn reset_tag() -> Unit {
  _global_tag.val = 0
}

///|
/// Get the primal value of an AD node (one level).
pub fn primal(x : T) -> T {
  match x {
    DF(ap, _, _) => ap
    DR(ap, _, _, _, _, _) => ap
    _ => x
  }
}

///|
/// Recursively get the primal value of an AD node.
pub fn primal_(x : T) -> T {
  match x {
    DF(ap, _, _) => primal_(ap)
    DR(ap, _, _, _, _, _) => primal_(ap)
    _ => x
  }
}

///|
/// Create a zero of the same type as the input.
pub fn zero(x : T) -> T {
  match x {
    F(_) => F(0.0)
    Arr(ap) => Arr(@ndarray.zeros(ap.shape))
    DF(ap, _, _) => zero(primal_(ap))
    DR(ap, _, _, _, _, _) => zero(primal_(ap))
  }
}

///|
/// Reset a node to zero.
pub fn reset_zero(x : T) -> T raise {
  match x {
    F(_) => F(0.0)
    Arr(ap) => {
      @ndarray.reset(ap)
      Arr(ap)
    }
    _ => raise @types.OwlError::InvalidArgument("reset_zero: not a primal node")
  }
}

///|
/// Get the tangent of a forward-mode node.
pub fn tangent(x : T) -> T raise {
  match x {
    DF(_, at, _) => at
    DR(_) =>
      raise @types.OwlError::InvalidArgument("tangent: no tangent for DR")
    _ => zero(x)
  }
}

///|
/// Get the adjoint reference of a reverse-mode node.
pub fn adjref(x : T) -> Ref[T] raise {
  match x {
    DF(_) => raise @types.OwlError::InvalidArgument("adjref: no adjref for DF")
    DR(_, at, _, _, _, _) => at
    _ => Ref(zero(x))
  }
}

///|
/// Get the adjoint value of a reverse-mode node.
pub fn adjval(x : T) -> T raise {
  match x {
    DF(_) => raise @types.OwlError::InvalidArgument("adjval: no adjval for DF")
    DR(_, at, _, _, _, _) => at.val
    _ => zero(x)
  }
}

///|
/// Get the shape of an AD node.
pub fn shape(x : T) -> Array[Int] raise {
  match primal_(x) {
    F(_) => []
    Arr(ap) => ap.shape
    _ => raise @types.OwlError::InvalidArgument("shape: not a valid node")
  }
}

///|
/// Check if an AD node is a float (scalar).
pub fn is_float(x : T) -> Bool {
  match x {
    Arr(_) => false
    F(_) => true
    DF(_) => is_float(primal_(x))
    DR(_) => is_float(primal_(x))
  }
}

///|
/// Check if an AD node is an array.
/// Note: OCaml source has is_arr with swapped logic (F->true, Arr->false).
/// Faithfully ported as-is.
pub fn is_arr(x : T) -> Bool {
  match x {
    Arr(_) => false
    F(_) => true
    DF(_) => is_arr(primal_(x))
    DR(_) => is_arr(primal_(x))
  }
}

///|
/// Pack a double into an AD scalar.
pub fn pack_flt(x : Double) -> T {
  F(x)
}

///|
/// Unpack an AD scalar to a double.
pub fn unpack_flt(x : T) -> Double raise {
  match primal(x) {
    F(v) => v
    _ => raise @types.OwlError::InvalidArgument("unpack_flt: not a scalar")
  }
}

///|
/// Pack an ndarray into an AD array.
pub fn pack_arr(x : @ndarray.Ndarray) -> T {
  Arr(x)
}

///|
/// Unpack an AD array to an ndarray.
pub fn unpack_arr(x : T) -> @ndarray.Ndarray raise {
  match primal(x) {
    Arr(v) => v
    _ => raise @types.OwlError::InvalidArgument("unpack_arr: not an array")
  }
}

///|
/// Create a forward-mode node.
pub fn make_forward(p : T, t : T, i : Int) -> T {
  DF(p, t, i)
}

///|
/// Create a reverse-mode node.
pub fn make_reverse(p : T, i : Int) -> T {
  let op : Op = {
    adjoint: fn(_cp : T, _ca : Ref[T], t : Array[(T, T)]) -> Array[(T, T)] { t },
    register: fn(t : Array[T]) -> Array[T] { t },
    label_name: "Noop",
    label_parents: [],
  }
  DR(p, Ref(zero(p)), op, Ref(0), i, Ref(0))
}
