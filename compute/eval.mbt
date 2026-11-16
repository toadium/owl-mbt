///|
/// Evaluate a single node given its input values.
/// Returns the output ndarray.
///
/// Scalar-parameter ops take their scalar as an extra input node holding a
/// shape-[1] ndarray (Owl's original design); the scalar is element [0] of
/// that input.
///
/// Ops whose semantics cannot be expressed statelessly in this single-output
/// graph model raise `NotImplemented`:
/// - AD prime variants (MinPrime/MaxPrime/LogSumExpPrime/L1normPrime/
///   L2normPrime/L2NormSqrPrime): backward masks need the forward output.
/// - FusedAdagrad: needs accumulated per-parameter gradient state.
/// - CopyRowTo/CopyColTo: need a row/column index missing from the payload.
/// - ToRows/OfRows: produce/consume a list of row vectors, not one ndarray.
fn eval_node(
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
    Get(idx) =>
      // The fetched element is wrapped as a shape-[1] ndarray.
      @ndarray.from_data([1], [@ndarray.get(inputs[0], idx)])
    Set(idx) => {
      // Returns a modified copy; the original input is left untouched.
      let copy = @ndarray.copy(inputs[0])
      @ndarray.set(copy, idx, @ndarray.get(inputs[1], [0]))
      copy
    }
    Copy => @ndarray.copy(inputs[0])
    Reset => @ndarray.zeros(@ndarray.shape(inputs[0]))
    Reshape(s) => @ndarray.reshape(inputs[0], s)
    Reverse => _reverse(inputs[0])
    Tile(reps) => @ndarray.tile(inputs[0], reps)
    Repeat(reps) => @ndarray.repeat(inputs[0], reps)
    Concatenate(axis) => @ndarray.concatenate(inputs, axis~)
    Stack(axis) => @ndarray.stack(inputs, axis~)
    Split(axis, parts) =>
      // Owl's split is a multi-output op; this single-output graph model
      // cannot expose the individual slices, so the first slice (output 0 in
      // Owl) is returned. The parts-total check from @ndarray.split still
      // applies.
      @ndarray.split(inputs[0], parts, axis~)[0]
    Draw(axis, count) => {
      // @ndarray.draw misuses its drawn index list as a slice range when
      // count > 1 (nondeterministic output shape), so draw one slice at a
      // time (shape [1, ...rest] with a length-1 axis) and concatenate the
      // results along the axis.
      if count < 1 {
        raise @core.OwlError::InvalidArgument("Draw requires a positive count")
      }
      let slices = Array::make(count, inputs[0])
      for i in 0..<count {
        let (drawn, _) = @ndarray.draw(inputs[0], 1, axis~)
        slices[i] = drawn
      }
      @ndarray.concatenate(slices, axis~)
    }
    OneHot(depth) => _one_hot(depth, inputs[0])
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
    // Axis-aware reductions: the payload (keep_dims, axis) is passed straight
    // through to the ndarray reduction.
    Min(keep_dims, axis) => @ndarray.min(inputs[0], axis~, keep_dims~)
    Max(keep_dims, axis) => @ndarray.max(inputs[0], axis~, keep_dims~)
    Sum(keep_dims, axis) => @ndarray.sum(inputs[0], axis~, keep_dims~)
    SumReduce(_) => @ndarray.sum(inputs[0])
    Signum => @ndarray.map_elem(inputs[0], fn(v) { v.signum() })
    Sigmoid => @ndarray.sigmoid(inputs[0])
    Relu =>
      @ndarray.map_elem(inputs[0], fn(v) { if v > 0.0 { v } else { 0.0 } })
    MinPrime =>
      raise @core.OwlError::NotImplemented(
        "MinPrime: backward mask needs the forward output",
      )
    MaxPrime =>
      raise @core.OwlError::NotImplemented(
        "MaxPrime: backward mask needs the forward output",
      )
    SumPrime => @ndarray.ones(@ndarray.shape(inputs[0]))
    LogSumExpPrime =>
      raise @core.OwlError::NotImplemented(
        "LogSumExpPrime: backward needs the forward output",
      )
    LogSumExp(keep_dims, axis) =>
      @ndarray.log_sum_exp(inputs[0], axis~, keep_dims~)
    L1normPrime =>
      raise @core.OwlError::NotImplemented(
        "L1normPrime: backward mask needs the forward output",
      )
    L2normPrime =>
      raise @core.OwlError::NotImplemented(
        "L2normPrime: backward mask needs the forward output",
      )
    L2NormSqrPrime =>
      raise @core.OwlError::NotImplemented(
        "L2NormSqrPrime: backward mask needs the forward output",
      )
    ClipByValue => {
      // inputs: [x, min, max] where min/max are shape-[1] ndarrays.
      let lo = @ndarray.get(inputs[1], [0])
      let hi = @ndarray.get(inputs[2], [0])
      @ndarray.map_elem(inputs[0], fn(v) {
        if v < lo {
          lo
        } else if v > hi {
          hi
        } else {
          v
        }
      })
    }
    ClipByL2norm => {
      // inputs: [x, c]; clip x to L2 norm c when its norm exceeds c.
      let x = inputs[0]
      let c = @ndarray.get(inputs[1], [0])
      let norm = @ndarray.get(@ndarray.sum(@ndarray.mul(x, x)), [0]).sqrt()
      if norm > c {
        let scale = c / norm
        @ndarray.map_elem(x, fn(v) { v * scale })
      } else {
        x
      }
    }
    Pow => @ndarray.pow(inputs[0], inputs[1])
    ScalarPow => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { @math.pow(v, s) })
    }
    PowScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { @math.pow(s, v) })
    }
    Atan2 => @ndarray.atan2(inputs[0], inputs[1])
    ScalarAtan2 => {
      // Owl semantics: the scalar precedes the array, i.e. atan2(s, v).
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { @math.atan2(s, v) })
    }
    Atan2Scalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { @math.atan2(v, s) })
    }
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
    AddScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { v + s })
    }
    SubScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { v - s })
    }
    MulScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { v * s })
    }
    DivScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { v / s })
    }
    ScalarAdd => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { s + v })
    }
    ScalarSub => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { s - v })
    }
    ScalarMul => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { s * v })
    }
    ScalarDiv => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { s / v })
    }
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
    EltEqualScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { if v == s { 1.0 } else { 0.0 } })
    }
    EltNotEqualScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { if v != s { 1.0 } else { 0.0 } })
    }
    EltLessScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { if v < s { 1.0 } else { 0.0 } })
    }
    EltGreaterScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { if v > s { 1.0 } else { 0.0 } })
    }
    EltLessEqualScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { if v <= s { 1.0 } else { 0.0 } })
    }
    EltGreaterEqualScalar => {
      let s = _scalar2(inputs)
      @ndarray.map_elem(inputs[0], fn(v) { if v >= s { 1.0 } else { 0.0 } })
    }
    Conv1d(padding, stride) =>
      @ndarray.conv1d(inputs[0], inputs[1], stride, padding~)
    Conv2d(padding, stride) =>
      @ndarray.conv2d(inputs[0], inputs[1], stride, padding~)
    Conv3d(padding, stride) =>
      @ndarray.conv3d(inputs[0], inputs[1], stride, padding~)
    TransposeConv1d(padding, stride) =>
      @ndarray.transpose_conv1d(inputs[0], inputs[1], stride, padding~)
    TransposeConv2d(padding, stride) =>
      @ndarray.transpose_conv2d(inputs[0], inputs[1], stride, padding~)
    TransposeConv3d(padding, stride) =>
      @ndarray.transpose_conv3d(inputs[0], inputs[1], stride, padding~)
    MaxPool1d(padding, kernel, stride) =>
      @ndarray.max_pool1d(inputs[0], kernel, stride, padding~)
    MaxPool2d(padding, kernel, stride) =>
      @ndarray.max_pool2d(inputs[0], kernel, stride, padding~)
    MaxPool3d(padding, kernel, stride) =>
      @ndarray.max_pool3d(inputs[0], kernel, stride, padding~)
    AvgPool1d(padding, kernel, stride) =>
      @ndarray.avg_pool1d(inputs[0], kernel, stride, padding~)
    AvgPool2d(padding, kernel, stride) =>
      @ndarray.avg_pool2d(inputs[0], kernel, stride, padding~)
    AvgPool3d(padding, kernel, stride) =>
      @ndarray.avg_pool3d(inputs[0], kernel, stride, padding~)
    UpSampling2d(scale) => @ndarray.upsampling2d(inputs[0], scale)
    RowNum => {
      let shape = @ndarray.shape(inputs[0])
      if shape.length() != 2 {
        raise @core.OwlError::InvalidArgument("RowNum requires a 2D input")
      }
      @ndarray.from_data([1], [shape[0].to_double()])
    }
    ColNum => {
      let shape = @ndarray.shape(inputs[0])
      if shape.length() != 2 {
        raise @core.OwlError::InvalidArgument("ColNum requires a 2D input")
      }
      @ndarray.from_data([1], [shape[1].to_double()])
    }
    Row => {
      // A 1D input is treated as a single row; a 2D input yields a
      // [1, cols] sub-matrix containing row 0.
      let shape = @ndarray.shape(inputs[0])
      match shape.length() {
        1 => @ndarray.reshape(inputs[0], [1, shape[0]])
        2 => @ndarray.rows(inputs[0], [0])
        _ =>
          raise @core.OwlError::InvalidArgument("Row requires a 1D or 2D input")
      }
    }
    Rows(idxs) => {
      let shape = @ndarray.shape(inputs[0])
      if shape.length() != 2 {
        raise @core.OwlError::InvalidArgument("Rows requires a 2D input")
      }
      for idx in idxs {
        if idx < 0 || idx >= shape[0] {
          raise @core.OwlError::OutOfRange(index=idx, bound=shape[0])
        }
      }
      @ndarray.rows(inputs[0], idxs)
    }
    CopyRowTo =>
      raise @core.OwlError::NotImplemented(
        "CopyRowTo: needs a row index parameter missing from the op payload",
      )
    CopyColTo =>
      raise @core.OwlError::NotImplemented(
        "CopyColTo: needs a column index parameter missing from the op payload",
      )
    Dot(_, _) => @ndarray.dot(inputs[0], inputs[1])
    Inv => @linalg.inv(inputs[0])
    Trace => @ndarray.from_data([1], [@linalg.trace(inputs[0])])
    Transpose(_) => @ndarray.transpose(inputs[0])
    ToRows =>
      raise @core.OwlError::NotImplemented(
        "ToRows: returns a list of row vectors, not a single ndarray",
      )
    OfRows =>
      raise @core.OwlError::NotImplemented(
        "OfRows: takes a list of row vectors, not a single ndarray",
      )
    FusedAdagrad(_, _) =>
      raise @core.OwlError::NotImplemented(
        "FusedAdagrad: needs accumulated per-parameter gradient state",
      )
  }
}

///|
/// Extract the scalar carried by the second input (a shape-[1] ndarray),
/// following Owl's design where scalar parameters are extra input nodes.
fn _scalar2(inputs : Array[@ndarray.Ndarray]) -> Double raise {
  @ndarray.get(inputs[1], [0])
}

///|
/// One-hot encode a 1D integer-valued array: row i is the one-hot vector of
/// element i. Indices outside [0, depth) raise.
fn _one_hot(depth : Int32, x : @ndarray.Ndarray) -> @ndarray.Ndarray raise {
  if @ndarray.shape(x).length() != 1 {
    raise @core.OwlError::InvalidArgument("OneHot requires a 1D input")
  }
  let bound = depth.to_double()
  let n = @ndarray.numel(x)
  for i in 0..<n {
    let v = @ndarray.get(x, [i])
    if v < 0.0 || v >= bound {
      raise @core.OwlError::InvalidArgument(
        "OneHot index \{v} out of range for depth \{depth}",
      )
    }
  }
  @ndarray.one_hot(depth, x)
}

///|
fn _sequential(shape : Array[Int32]) -> @ndarray.Ndarray {
  let total = _array_prod(shape)
  let data = FixedArray::makei(total, fn(i) { i.to_double() })
  @ndarray.from_data(shape, data)
}

///|
fn _array_prod(arr : Array[Int32]) -> Int32 {
  let mut p = 1
  for v in arr {
    p = p * v
  }
  p
}

///|
/// Reverse the element order of an ndarray.
/// Note: directly accesses `x.data` assuming contiguous row-major layout.
/// This bypasses ndarray's stride/shape abstraction.
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
