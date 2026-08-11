///|
/// Evaluate a single node given its input values.
/// Returns the output ndarray.
pub fn eval_node(
  op : Op,
  inputs : Array[@ndarray.Ndarray],
) -> @ndarray.Ndarray raise {
  match op {
    Noop => inputs[0]
    Var => inputs[0]
    Const => inputs[0]
    Empty(s) => @ndarray.zeros(s)
    Zeros(s) => @ndarray.zeros(s)
    Ones(s) => @ndarray.ones(s)
    Create(s) => @ndarray.zeros(s)
    Sequential(s) => _sequential(s)
    Uniform(s) => @ndarray.uniform(s, a=0.0, b=1.0)
    Gaussian(s) => @ndarray.gaussian(s, mu=0.0, sigma=1.0)
    Bernoulli(s) => @ndarray.bernoulli(s, p=0.5)
    Get(_) => inputs[0]
    Set(_) => inputs[0]
    Copy => @ndarray.copy(inputs[0])
    Reset => @ndarray.zeros(@ndarray.shape(inputs[0]))
    Reshape(s) => @ndarray.reshape(inputs[0], s)
    Reverse => _reverse(inputs[0])
    Tile(_) => inputs[0]
    Repeat(_) => inputs[0]
    Concatenate(_) => inputs[0]
    Stack(_) => inputs[0]
    Split(_, _) => inputs[0]
    Draw(_, _) => inputs[0]
    OneHot(_) => inputs[0]
    Abs => @ndarray.abs(inputs[0])
    Neg => @ndarray.neg(inputs[0])
    Floor => @ndarray.map_elem(inputs[0], fn(v) { v.floor() })
    Ceil => @ndarray.map_elem(inputs[0], fn(v) { v.ceil() })
    Round => @ndarray.map_elem(inputs[0], fn(v) { v.round() })
    Sqr => @ndarray.mul(inputs[0], inputs[0])
    Sqrt => @ndarray.sqrt(inputs[0])
    Log => @ndarray.log(inputs[0])
    Log2 => @ndarray.map_elem(inputs[0], fn(v) { @math.log2(v) })
    Log10 => @ndarray.map_elem(inputs[0], fn(v) { @math.log10(v) })
    Exp => @ndarray.exp(inputs[0])
    Sin => @ndarray.sin(inputs[0])
    Cos => @ndarray.cos(inputs[0])
    Tan => @ndarray.tan(inputs[0])
    Sinh => @ndarray.sinh(inputs[0])
    Cosh => @ndarray.cosh(inputs[0])
    Tanh => @ndarray.tanh(inputs[0])
    Asin => @ndarray.asin(inputs[0])
    Acos => @ndarray.acos(inputs[0])
    Atan => @ndarray.atan(inputs[0])
    Asinh => @ndarray.asinh(inputs[0])
    Acosh => @ndarray.acosh(inputs[0])
    Atanh => @ndarray.atanh(inputs[0])
    Min(_, _) => @ndarray.min(inputs[0])
    Max(_, _) => @ndarray.max(inputs[0])
    Sum(_, _) => @ndarray.sum(inputs[0])
    SumReduce(_) => @ndarray.sum(inputs[0])
    Signum => @ndarray.map_elem(inputs[0], fn(v) { v.signum() })
    Sigmoid => @ndarray.sigmoid(inputs[0])
    Relu =>
      @ndarray.map_elem(inputs[0], fn(v) { if v > 0.0 { v } else { 0.0 } })
    MinPrime => inputs[0]
    MaxPrime => inputs[0]
    SumPrime => @ndarray.ones(@ndarray.shape(inputs[0]))
    LogSumExpPrime => inputs[0]
    LogSumExp(_, _) => @ndarray.log_sum_exp(inputs[0])
    L1normPrime => inputs[0]
    L2normPrime => inputs[0]
    L2NormSqrPrime => inputs[0]
    ClipByValue => inputs[0]
    ClipByL2norm => inputs[0]
    Pow => @ndarray.pow(inputs[0], inputs[1])
    ScalarPow => inputs[0]
    PowScalar => inputs[0]
    Atan2 => @ndarray.atan2(inputs[0], inputs[1])
    ScalarAtan2 => inputs[0]
    Atan2Scalar => inputs[0]
    Hypot =>
      @ndarray.map_elem2(inputs[0], inputs[1], fn(a, b) { @math.hypot(a, b) })
    Min2 =>
      @ndarray.map_elem2(inputs[0], inputs[1], fn(a, b) {
        if a < b {
          a
        } else {
          b
        }
      })
    Max2 =>
      @ndarray.map_elem2(inputs[0], inputs[1], fn(a, b) {
        if a > b {
          a
        } else {
          b
        }
      })
    Add => @ndarray.add(inputs[0], inputs[1])
    Sub => @ndarray.sub(inputs[0], inputs[1])
    Mul => @ndarray.mul(inputs[0], inputs[1])
    Div => @ndarray.div(inputs[0], inputs[1])
    AddScalar => inputs[0]
    SubScalar => inputs[0]
    MulScalar => inputs[0]
    DivScalar => inputs[0]
    ScalarAdd => inputs[0]
    ScalarSub => inputs[0]
    ScalarMul => inputs[0]
    ScalarDiv => inputs[0]
    FMA => @ndarray.add(@ndarray.mul(inputs[0], inputs[1]), inputs[2])
    EltEqual => @ndarray.elt_equal(inputs[0], inputs[1])
    EltNotEqual =>
      @ndarray.map_elem2(
        @ndarray.elt_equal(inputs[0], inputs[1]),
        @ndarray.ones(@ndarray.shape(inputs[0])),
        fn(a, b) { b - a },
      )
    EltLess => @ndarray.elt_less(inputs[0], inputs[1])
    EltGreater => @ndarray.elt_greater(inputs[0], inputs[1])
    EltLessEqual => @ndarray.elt_less_equal(inputs[0], inputs[1])
    EltGreaterEqual => @ndarray.elt_greater_equal(inputs[0], inputs[1])
    EltEqualScalar => inputs[0]
    EltNotEqualScalar => inputs[0]
    EltLessScalar => inputs[0]
    EltGreaterScalar => inputs[0]
    EltLessEqualScalar => inputs[0]
    EltGreaterEqualScalar => inputs[0]
    Conv1d(_, _) => inputs[0]
    Conv2d(_, _) => inputs[0]
    Conv3d(_, _) => inputs[0]
    TransposeConv1d(_, _) => inputs[0]
    TransposeConv2d(_, _) => inputs[0]
    TransposeConv3d(_, _) => inputs[0]
    MaxPool1d(_, _, _) => inputs[0]
    MaxPool2d(_, _, _) => inputs[0]
    MaxPool3d(_, _, _) => inputs[0]
    AvgPool1d(_, _, _) => inputs[0]
    AvgPool2d(_, _, _) => inputs[0]
    AvgPool3d(_, _, _) => inputs[0]
    UpSampling2d(_) => inputs[0]
    RowNum => inputs[0]
    ColNum => inputs[0]
    Row => inputs[0]
    Rows(_) => inputs[0]
    CopyRowTo => inputs[0]
    CopyColTo => inputs[0]
    Dot(_, _) => @ndarray.dot(inputs[0], inputs[1])
    Inv => inputs[0]
    Trace => inputs[0]
    Transpose(_) => @ndarray.transpose(inputs[0])
    ToRows => inputs[0]
    OfRows => inputs[0]
    FusedAdagrad(_, _) => inputs[0]
  }
}

///|
fn _sequential(shape : Array[Int]) -> @ndarray.Ndarray {
  let total = _array_prod(shape)
  let data = FixedArray::makei(total, fn(i) { i.to_double() })
  @ndarray.from_data(shape, data)
}

///|
fn _array_prod(arr : Array[Int]) -> Int {
  let mut p = 1
  for v in arr {
    p = p * v
  }
  p
}

///|
fn _reverse(x : @ndarray.Ndarray) -> @ndarray.Ndarray {
  let shape = @ndarray.shape(x)
  let n = @ndarray.numel(x)
  let data = FixedArray::makei(n, fn(i) { x.data[n - 1 - i] })
  @ndarray.from_data(shape, data)
}

///|
/// Evaluate the entire graph in topological order.
/// Input nodes must have their values set before calling this.
pub fn eval_graph(graph : Graph) -> Unit raise {
  let topo = topological_sort(graph)
  for n in topo {
    if !is_assigned(n) {
      let inputs = Array::makei(n.prev.val.length(), fn(i) raise {
        get_node_value(n.prev.val[i])
      })
      let result = eval_node(n.op.val, inputs)
      set_node_value(n, result)
    }
  }
}

///|
/// Evaluate the graph and return the output values.
pub fn eval_outputs(graph : Graph) -> Array[@ndarray.Ndarray] raise {
  eval_graph(graph)
  Array::makei(graph.output.val.length(), fn(i) raise {
    get_node_value(graph.output.val[i])
  })
}
