///|
/// Infer the output shape of an operation given input shapes.
/// Each shape is Array[Option[Array[Int]]] where None means unknown.
pub fn infer_shape(
  op : Op,
  input_shapes : Array[Array[Array[Int]?]],
) -> Array[Array[Int]?] {
  match op {
    Noop => [None]
    Var => _infer_shape_01(input_shapes)
    Const => _infer_shape_01(input_shapes)
    Empty(s) => [Some(s.copy())]
    Zeros(s) => [Some(s.copy())]
    Ones(s) => [Some(s.copy())]
    Create(s) => [Some(s.copy())]
    Sequential(s) => [Some(s.copy())]
    Uniform(s) => [Some(s.copy())]
    Gaussian(s) => [Some(s.copy())]
    Bernoulli(s) => [Some(s.copy())]
    Get(_) => _infer_shape_01(input_shapes)
    Set(_) => _infer_shape_01(input_shapes)
    Copy => _infer_shape_01(input_shapes)
    Reset => _infer_shape_01(input_shapes)
    Reshape(s) => [Some(s.copy())]
    Reverse => _infer_shape_01(input_shapes)
    Tile(_) => _infer_shape_01(input_shapes)
    Repeat(_) => _infer_shape_01(input_shapes)
    Concatenate(_) => _infer_shape_concatenate(input_shapes)
    Stack(_) => _infer_shape_01(input_shapes)
    Split(_, _) => _infer_shape_01(input_shapes)
    Draw(_, _) => _infer_shape_01(input_shapes)
    OneHot(_) => _infer_shape_01(input_shapes)
    Abs
    | Neg
    | Floor
    | Ceil
    | Round
    | Sqr
    | Sqrt
    | Log
    | Log2
    | Log10
    | Exp
    | Sin
    | Cos
    | Tan
    | Sinh
    | Cosh
    | Tanh
    | Asin
    | Acos
    | Atan
    | Asinh
    | Acosh
    | Atanh
    | Signum
    | Sigmoid
    | Relu
    | ClipByValue => _infer_shape_01(input_shapes)
    Min(_, _) | Max(_, _) | Sum(_, _) | LogSumExp(_, _) =>
      _infer_shape_fold(input_shapes)
    SumReduce(_) => _infer_shape_01(input_shapes)
    MinPrime
    | MaxPrime
    | SumPrime
    | LogSumExpPrime
    | L1normPrime
    | L2normPrime
    | L2NormSqrPrime => _infer_shape_01(input_shapes)
    ClipByL2norm => _infer_shape_01(input_shapes)
    Pow | ScalarPow | PowScalar | Atan2 | ScalarAtan2 | Atan2Scalar | Hypot =>
      _infer_shape_broadcast(input_shapes)
    Min2
    | Max2
    | Add
    | Sub
    | Mul
    | Div
    | FMA
    | EltEqual
    | EltNotEqual
    | EltLess
    | EltGreater
    | EltLessEqual
    | EltGreaterEqual => _infer_shape_broadcast(input_shapes)
    AddScalar
    | SubScalar
    | MulScalar
    | DivScalar
    | ScalarAdd
    | ScalarSub
    | ScalarMul
    | ScalarDiv => _infer_shape_01(input_shapes)
    EltEqualScalar
    | EltNotEqualScalar
    | EltLessScalar
    | EltGreaterScalar
    | EltLessEqualScalar
    | EltGreaterEqualScalar => _infer_shape_01(input_shapes)
    Conv1d(_, _) | Conv2d(_, _) | Conv3d(_, _) => _infer_shape_01(input_shapes)
    TransposeConv1d(_, _) | TransposeConv2d(_, _) | TransposeConv3d(_, _) =>
      _infer_shape_01(input_shapes)
    MaxPool1d(_, _, _) | MaxPool2d(_, _, _) | MaxPool3d(_, _, _) =>
      _infer_shape_01(input_shapes)
    AvgPool1d(_, _, _) | AvgPool2d(_, _, _) | AvgPool3d(_, _, _) =>
      _infer_shape_01(input_shapes)
    UpSampling2d(_) => _infer_shape_01(input_shapes)
    RowNum | ColNum => [Some([])]
    Row | Rows(_) | CopyRowTo | CopyColTo => _infer_shape_01(input_shapes)
    Dot(_, _) => _infer_shape_dot(input_shapes)
    Inv | Trace => _infer_shape_01(input_shapes)
    Transpose(_) => _infer_shape_01(input_shapes)
    ToRows | OfRows => _infer_shape_01(input_shapes)
    FusedAdagrad(_, _) => _infer_shape_01(input_shapes)
  }
}

///|
fn _infer_shape_01(
  input_shapes : Array[Array[Array[Int]?]],
) -> Array[Array[Int]?] {
  if input_shapes.length() > 0 && input_shapes[0].length() > 0 {
    match input_shapes[0][0] {
      Some(s) => [Some(s.copy())]
      None => [None]
    }
  } else {
    [None]
  }
}

///|
fn _infer_shape_broadcast(
  input_shapes : Array[Array[Array[Int]?]],
) -> Array[Array[Int]?] {
  if input_shapes.length() < 2 {
    return [None]
  }
  let s0 = if input_shapes[0].length() > 0 { input_shapes[0][0] } else { None }
  let s1 = if input_shapes[1].length() > 0 { input_shapes[1][0] } else { None }
  match (s0, s1) {
    (Some(a), Some(b)) => [Some(_broadcast_shapes(a, b))]
    (Some(a), None) => [Some(a.copy())]
    (None, Some(b)) => [Some(b.copy())]
    (None, None) => [None]
  }
}

///|
fn _infer_shape_fold(
  input_shapes : Array[Array[Array[Int]?]],
) -> Array[Array[Int]?] {
  if input_shapes.length() > 0 && input_shapes[0].length() > 0 {
    match input_shapes[0][0] {
      Some(s) => if s.length() > 0 { [Some([1])] } else { [Some([])] }
      None => [None]
    }
  } else {
    [None]
  }
}

///|
/// Infer output shape of Concatenate op.
/// Note: currently returns the first input's shape unchanged (passthrough),
/// which is incorrect. A proper implementation would sum dimensions along
/// the concatenation axis and keep other dimensions equal across inputs.
fn _infer_shape_concatenate(
  input_shapes : Array[Array[Array[Int]?]],
) -> Array[Array[Int]?] {
  if input_shapes.length() > 0 && input_shapes[0].length() > 0 {
    match input_shapes[0][0] {
      Some(s) => [Some(s.copy())]
      None => [None]
    }
  } else {
    [None]
  }
}

///|
fn _infer_shape_dot(
  input_shapes : Array[Array[Array[Int]?]],
) -> Array[Array[Int]?] {
  if input_shapes.length() < 2 {
    return [None]
  }
  let s0 = if input_shapes[0].length() > 0 { input_shapes[0][0] } else { None }
  let s1 = if input_shapes[1].length() > 0 { input_shapes[1][0] } else { None }
  match (s0, s1) {
    (Some(a), Some(b)) =>
      if a.length() >= 2 && b.length() >= 2 {
        [Some([a[0], b[1]])]
      } else if a.length() == 1 && b.length() == 1 {
        [Some([])]
      } else {
        [None]
      }
    _ => [None]
  }
}

///|
fn _broadcast_shapes(s0 : Array[Int], s1 : Array[Int]) -> Array[Int] {
  let n = if s0.length() > s1.length() { s0.length() } else { s1.length() }
  let result = Array::make(n, 1)
  let offset0 = n - s0.length()
  let offset1 = n - s1.length()
  for i in 0..<n {
    let d0 = if i >= offset0 { s0[i - offset0] } else { 1 }
    let d1 = if i >= offset1 { s1[i - offset1] } else { 1 }
    result[i] = if d0 > d1 { d0 } else { d1 }
  }
  result
}

///|
/// Propagate shapes through the graph in topological order.
pub fn infer_shapes(graph : Graph) -> Unit {
  let topo = topological_sort(graph)
  for n in topo {
    let input_shapes = Array::makei(n.prev.val.length(), fn(i) {
      get_node_shape(n.prev.val[i])
    })
    let output_shape = infer_shape(n.op.val, input_shapes)
    set_node_shape(n, output_shape)
  }
}
