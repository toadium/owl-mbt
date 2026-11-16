///|
/// White-box tests for compute package: directly construct Op variants
/// to cover eval_node, op_to_str, is_unary, is_binary, infer_shape branches.

///|
fn _arr(d : Array[Double]) -> @ndarray.Ndarray {
  @ndarray.of_array(d, [d.length()])
}

///|
/// Evaluate an op with a single input, ignoring the result (covers the branch).
fn _eval1(op : Op, x : @ndarray.Ndarray) -> Unit raise {
  let _ = eval_node(op, [x])
}

///|
/// Evaluate an op with two inputs.
fn _eval2(op : Op, x : @ndarray.Ndarray, y : @ndarray.Ndarray) -> Unit raise {
  let _ = eval_node(op, [x, y])
}

///|
/// Evaluate an op with three inputs.
fn _eval3(
  op : Op,
  x : @ndarray.Ndarray,
  y : @ndarray.Ndarray,
  z : @ndarray.Ndarray,
) -> Unit raise {
  let _ = eval_node(op, [x, y, z])
}

///|
test "wb eval_node shape ops" {
  let ops = [
    Op::Empty([3]),
    Op::Zeros([2, 2]),
    Op::Ones([3]),
    Op::Create([2]),
    Op::Sequential([4]),
    Op::Uniform([3]),
    Op::Gaussian([3]),
    Op::Bernoulli([3]),
  ]
  for op in ops {
    let _ = eval_node(op, [])
  }
  @test.assert_eq(true, true)
}

///|
test "wb eval_node passthrough unary" {
  let x = _arr([1.0, 2.0, 3.0])
  let ops = [
    Op::Noop,
    Op::Var,
    Op::Const,
    Op::Copy,
    Op::Reset,
    Op::Reverse,
    Op::Get([0]),
    Op::Tile([1]),
    Op::Repeat([1]),
    Op::Concatenate(0),
    Op::Stack(0),
    Op::Split(0, [1, 2]),
    Op::Draw(0, 1),
    Op::Reshape([3]),
    Op::Transpose([1]),
  ]
  for op in ops {
    _eval1(op, x)
  }
  // OneHot(3) rejects out-of-range indices, so feed in-bound values here.
  _eval1(Op::OneHot(3), _arr([0.0, 1.0, 2.0]))
  _eval2(Op::Set([0]), x, _arr([9.0]))
  @test.assert_eq(true, true)
}

///|
test "wb eval_node math unary" {
  let x = _arr([0.5, 1.0, 2.0])
  let ops = [
    Op::Abs,
    Op::Neg,
    Op::Floor,
    Op::Ceil,
    Op::Round,
    Op::Sqr,
    Op::Sqrt,
    Op::Log,
    Op::Log2,
    Op::Log10,
    Op::Exp,
    Op::Sin,
    Op::Cos,
    Op::Tan,
    Op::Sinh,
    Op::Cosh,
    Op::Tanh,
    Op::Asin,
    Op::Acos,
    Op::Atan,
    Op::Asinh,
    Op::Acosh,
    Op::Atanh,
    Op::Signum,
    Op::Sigmoid,
    Op::Relu,
  ]
  for op in ops {
    _eval1(op, x)
  }
  @test.assert_eq(true, true)
}

///|
test "wb eval_node reduce ops" {
  let x = _arr([1.0, 2.0, 3.0])
  let ops = [
    Op::Min(true, 0),
    Op::Max(true, 0),
    Op::Sum(true, 0),
    Op::SumReduce([0]),
    Op::SumPrime,
    Op::LogSumExp(true, 0),
  ]
  for op in ops {
    _eval1(op, x)
  }
  @test.assert_eq(true, true)
}

///|
test "wb eval_node binary ops" {
  let x = _arr([1.0, 2.0, 3.0])
  let y = _arr([2.0, 3.0, 4.0])
  let ops = [
    Op::Add,
    Op::Sub,
    Op::Mul,
    Op::Div,
    Op::Pow,
    Op::Atan2,
    Op::Hypot,
    Op::Min2,
    Op::Max2,
    Op::EltEqual,
    Op::EltNotEqual,
    Op::EltLess,
    Op::EltGreater,
    Op::EltLessEqual,
    Op::EltGreaterEqual,
    Op::Dot(true, true),
  ]
  for op in ops {
    _eval2(op, x, y)
  }
  @test.assert_eq(true, true)
}

///|
test "wb eval_node scalar ops" {
  let x = _arr([1.0, 2.0, 3.0])
  let s = _arr([2.0])
  let ops = [
    Op::ScalarPow,
    Op::PowScalar,
    Op::ScalarAtan2,
    Op::Atan2Scalar,
    Op::AddScalar,
    Op::SubScalar,
    Op::MulScalar,
    Op::DivScalar,
    Op::ScalarAdd,
    Op::ScalarSub,
    Op::ScalarMul,
    Op::ScalarDiv,
    Op::EltEqualScalar,
    Op::EltNotEqualScalar,
    Op::EltLessScalar,
    Op::EltGreaterScalar,
    Op::EltLessEqualScalar,
    Op::EltGreaterEqualScalar,
  ]
  for op in ops {
    _eval2(op, x, s)
  }
  @test.assert_eq(true, true)
}

///|
test "wb eval_node FMA" {
  let x = _arr([1.0, 2.0, 3.0])
  _eval3(Op::FMA, x, x, x)
  @test.assert_eq(true, true)
}

///|
test "wb eval_node conv/pool 1d" {
  // input [batch=1, col=4, in_ch=2]; kernel [k_col=2, in_ch=2, out_ch=3]
  let input = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0], [
    1, 4, 2,
  ])
  let kernel = @ndarray.of_array(
    [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0],
    [2, 2, 3],
  )
  _eval2(Op::Conv1d(@core.Padding::Valid, [1]), input, kernel)
  _eval2(Op::TransposeConv1d(@core.Padding::Valid, [1]), input, kernel)
  _eval1(Op::MaxPool1d(@core.Padding::Valid, [2], [1]), input)
  _eval1(Op::AvgPool1d(@core.Padding::Valid, [2], [1]), input)
  @test.assert_eq(true, true)
}

///|
test "wb eval_node conv/pool 2d" {
  // input [batch=1, col=3, row=3, in_ch=1]; kernel [2, 2, 1, 1]
  let input = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0], [
    1, 3, 3, 1,
  ])
  let kernel = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2, 1, 1])
  _eval2(Op::Conv2d(@core.Padding::Valid, [1, 1]), input, kernel)
  _eval2(Op::TransposeConv2d(@core.Padding::Valid, [1, 1]), input, kernel)
  _eval1(Op::MaxPool2d(@core.Padding::Valid, [2, 2], [1, 1]), input)
  _eval1(Op::AvgPool2d(@core.Padding::Valid, [2, 2], [1, 1]), input)
  _eval1(Op::UpSampling2d([2, 2]), input)
  @test.assert_eq(true, true)
}

///|
test "wb eval_node conv/pool 3d" {
  // input [batch=1, col=3, row=3, dpt=3, in_ch=1]; kernel [2, 2, 2, 1, 1]
  let data = Array::make(27, 1.0)
  for i in 0..<27 {
    data[i] = i.to_double()
  }
  let input = @ndarray.of_array(data, [1, 3, 3, 3, 1])
  let kernel = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0], [
    2, 2, 2, 1, 1,
  ])
  _eval2(Op::Conv3d(@core.Padding::Valid, [1, 1, 1]), input, kernel)
  _eval2(Op::TransposeConv3d(@core.Padding::Valid, [1, 1, 1]), input, kernel)
  _eval1(Op::MaxPool3d(@core.Padding::Valid, [2, 2, 2], [1, 1, 1]), input)
  _eval1(Op::AvgPool3d(@core.Padding::Valid, [2, 2, 2], [1, 1, 1]), input)
  @test.assert_eq(true, true)
}

///|
test "wb eval_node row ops" {
  let x = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  _eval1(Op::RowNum, x)
  _eval1(Op::ColNum, x)
  _eval1(Op::Row, x)
  _eval1(Op::Rows([0]), x)
  _eval1(Op::Rows([0, 1]), x)
}

///|
test "wb eval_node linalg ops" {
  let x = @ndarray.of_array([2.0, 0.0, 0.0, 2.0], [2, 2])
  _eval1(Op::Inv, x)
  _eval1(Op::Trace, x)
}

///|
test "wb op_to_str coverage" {
  let ops : Array[Op] = [
    Op::Noop,
    Op::Var,
    Op::Const,
    Op::Empty([1]),
    Op::Zeros([1]),
    Op::Ones([1]),
    Op::Create([1]),
    Op::Sequential([1]),
    Op::Uniform([1]),
    Op::Gaussian([1]),
    Op::Bernoulli([1]),
    Op::Get([0]),
    Op::Set([0]),
    Op::Copy,
    Op::Reset,
    Op::Reshape([1]),
    Op::Reverse,
    Op::Tile([1]),
    Op::Repeat([1]),
    Op::Concatenate(0),
    Op::Stack(0),
    Op::Split(0, [1]),
    Op::Draw(1, 0),
    Op::OneHot(1),
    Op::Abs,
    Op::Neg,
    Op::Floor,
    Op::Ceil,
    Op::Round,
    Op::Sqr,
    Op::Sqrt,
    Op::Log,
    Op::Log2,
    Op::Log10,
    Op::Exp,
    Op::Sin,
    Op::Cos,
    Op::Tan,
    Op::Sinh,
    Op::Cosh,
    Op::Tanh,
    Op::Asin,
    Op::Acos,
    Op::Atan,
    Op::Asinh,
    Op::Acosh,
    Op::Atanh,
    Op::Min(true, 0),
    Op::Max(true, 0),
    Op::Sum(true, 0),
    Op::SumReduce([0]),
    Op::Signum,
    Op::Sigmoid,
    Op::Relu,
    Op::MinPrime,
    Op::MaxPrime,
    Op::SumPrime,
    Op::LogSumExpPrime,
    Op::LogSumExp(true, 0),
    Op::L1normPrime,
    Op::L2normPrime,
    Op::L2NormSqrPrime,
    Op::ClipByValue,
    Op::ClipByL2norm,
    Op::Pow,
    Op::ScalarPow,
    Op::PowScalar,
    Op::Atan2,
    Op::ScalarAtan2,
    Op::Atan2Scalar,
    Op::Hypot,
    Op::Min2,
    Op::Max2,
    Op::Add,
    Op::Sub,
    Op::Mul,
    Op::Div,
    Op::AddScalar,
    Op::SubScalar,
    Op::MulScalar,
    Op::DivScalar,
    Op::ScalarAdd,
    Op::ScalarSub,
    Op::ScalarMul,
    Op::ScalarDiv,
    Op::FMA,
    Op::EltEqual,
    Op::EltNotEqual,
    Op::EltLess,
    Op::EltGreater,
    Op::EltLessEqual,
    Op::EltGreaterEqual,
    Op::EltEqualScalar,
    Op::EltNotEqualScalar,
    Op::EltLessScalar,
    Op::EltGreaterScalar,
    Op::EltLessEqualScalar,
    Op::EltGreaterEqualScalar,
    Op::Conv1d(@core.Padding::Valid, [1]),
    Op::Conv2d(@core.Padding::Valid, [1, 1]),
    Op::Conv3d(@core.Padding::Valid, [1, 1, 1]),
    Op::TransposeConv1d(@core.Padding::Valid, [1]),
    Op::TransposeConv2d(@core.Padding::Valid, [1, 1]),
    Op::TransposeConv3d(@core.Padding::Valid, [1, 1, 1]),
    Op::MaxPool1d(@core.Padding::Valid, [2], [1]),
    Op::MaxPool2d(@core.Padding::Valid, [2, 2], [1, 1]),
    Op::MaxPool3d(@core.Padding::Valid, [2, 2, 2], [1, 1, 1]),
    Op::AvgPool1d(@core.Padding::Valid, [2], [1]),
    Op::AvgPool2d(@core.Padding::Valid, [2, 2], [1, 1]),
    Op::AvgPool3d(@core.Padding::Valid, [2, 2, 2], [1, 1, 1]),
    Op::UpSampling2d([2, 2]),
    Op::RowNum,
    Op::ColNum,
    Op::Row,
    Op::Rows([0]),
    Op::CopyRowTo,
    Op::CopyColTo,
    Op::Dot(true, true),
    Op::Inv,
    Op::Trace,
    Op::Transpose([1]),
    Op::ToRows,
    Op::OfRows,
    Op::FusedAdagrad(0.01, 1.0e-8),
  ]
  let mut count = 0
  for op in ops {
    let _ = op_to_str(op)
    let _ = is_unary(op)
    let _ = is_binary(op)
    count += 1
  }
  @test.assert_eq(true, count > 100)
}

///|
test "wb eval_graph and eval_outputs" {
  let g = make_graph("wb")
  let x = make_node(g, op_var(), "x")
  let y = make_node(g, op_neg(), "y")
  connect(x, y)
  set_inputs(g, [x])
  set_outputs(g, [y])
  set_node_value(x, _arr([1.0, 2.0, 3.0]))
  let outs = eval_outputs(g)
  @test.assert_eq(1, outs.length())
  @test.assert_eq(-1.0, @ndarray.get(outs[0], [0]))
}

///|
test "wb graph helpers" {
  let g = make_graph("helpers")
  let x = make_node(g, op_var(), "x")
  let y = make_node(g, op_abs(), "y")
  connect(x, y)
  set_inputs(g, [x])
  set_outputs(g, [y])
  @test.assert_eq(1, get_inputs(g).length())
  @test.assert_eq(1, get_outputs(g).length())
  @test.assert_eq(2, get_nodes(g).length())
  @test.assert_eq(false, is_assigned(x))
  set_node_value(x, _arr([1.0]))
  @test.assert_eq(true, is_assigned(x))
  set_node_shape(x, [Some([3])])
  match get_node_shape(x)[0] {
    Some(s) => @test.assert_eq([3], s)
    None => @test.assert_eq(true, false)
  }
  let ancestors = collect_ancestors([y], 2)
  @test.assert_eq(true, ancestors.length() >= 1)
  @test.assert_eq(0, node_id(x))
  @test.assert_eq("x", node_name(x))
  let _ = node_op(x)
  @test.assert_eq(true, true)
}

///|
/// Helper: wrap a shape as Some
fn _some(s : Array[Int32]) -> Array[Int32]? {
  Some(s)
}

///|
/// Helper: None shape
fn _none() -> Array[Int32]? {
  None
}

///|
test "wb infer_shape direct shape ops" {
  // Ops that return their embedded shape directly
  let ops = [
    Op::Empty([3]),
    Op::Zeros([2, 2]),
    Op::Ones([3]),
    Op::Create([2]),
    Op::Sequential([4]),
    Op::Uniform([3]),
    Op::Gaussian([3]),
    Op::Bernoulli([3]),
    Op::Reshape([3]),
  ]
  for op in ops {
    let result = infer_shape(op, [])
    @test.assert_eq(1, result.length())
  }
}

///|
test "wb infer_shape_01 passthrough" {
  // Ops that use _infer_shape_01 (pass through first input shape)
  let input = [[_some([2, 3])]]
  let ops = [
    Op::Noop,
    Op::Var,
    Op::Const,
    Op::Get([0]),
    Op::Set([0]),
    Op::Copy,
    Op::Reset,
    Op::Reverse,
    Op::Tile([1]),
    Op::Repeat([1]),
    Op::Stack(0),
    Op::Split(0, [1]),
    Op::Draw(1, 0),
    Op::OneHot(3),
    Op::Transpose([1]),
    Op::Abs,
    Op::Neg,
    Op::Floor,
    Op::Ceil,
    Op::Round,
    Op::Sqr,
    Op::Sqrt,
    Op::Log,
    Op::Log2,
    Op::Log10,
    Op::Exp,
    Op::Sin,
    Op::Cos,
    Op::Tan,
    Op::Sinh,
    Op::Cosh,
    Op::Tanh,
    Op::Asin,
    Op::Acos,
    Op::Atan,
    Op::Asinh,
    Op::Acosh,
    Op::Atanh,
    Op::Signum,
    Op::Sigmoid,
    Op::Relu,
    Op::ClipByValue,
    Op::SumReduce([0]),
    Op::MinPrime,
    Op::MaxPrime,
    Op::SumPrime,
    Op::LogSumExpPrime,
    Op::L1normPrime,
    Op::L2normPrime,
    Op::L2NormSqrPrime,
    Op::ClipByL2norm,
    Op::AddScalar,
    Op::SubScalar,
    Op::MulScalar,
    Op::DivScalar,
    Op::ScalarAdd,
    Op::ScalarSub,
    Op::ScalarMul,
    Op::ScalarDiv,
    Op::EltEqualScalar,
    Op::EltNotEqualScalar,
    Op::EltLessScalar,
    Op::EltGreaterScalar,
    Op::EltLessEqualScalar,
    Op::EltGreaterEqualScalar,
    Op::Conv1d(@core.Padding::Valid, [1]),
    Op::Conv2d(@core.Padding::Valid, [1, 1]),
    Op::Conv3d(@core.Padding::Valid, [1, 1, 1]),
    Op::TransposeConv1d(@core.Padding::Valid, [1]),
    Op::TransposeConv2d(@core.Padding::Valid, [1, 1]),
    Op::TransposeConv3d(@core.Padding::Valid, [1, 1, 1]),
    Op::MaxPool1d(@core.Padding::Valid, [2], [1]),
    Op::MaxPool2d(@core.Padding::Valid, [2, 2], [1, 1]),
    Op::MaxPool3d(@core.Padding::Valid, [2, 2, 2], [1, 1, 1]),
    Op::AvgPool1d(@core.Padding::Valid, [2], [1]),
    Op::AvgPool2d(@core.Padding::Valid, [2, 2], [1, 1]),
    Op::AvgPool3d(@core.Padding::Valid, [2, 2, 2], [1, 1, 1]),
    Op::UpSampling2d([2, 2]),
    Op::Row,
    Op::Rows([0]),
    Op::CopyRowTo,
    Op::CopyColTo,
    Op::Inv,
    Op::Trace,
    Op::ToRows,
    Op::OfRows,
    Op::FusedAdagrad(0.01, 1.0e-8),
  ]
  for op in ops {
    let result = infer_shape(op, input)
    @test.assert_eq(1, result.length())
  }
  // Test with None input shape
  let none_input = [[_none()]]
  for op in ops {
    let result = infer_shape(op, none_input)
    @test.assert_eq(1, result.length())
  }
  // Test with empty input
  for op in ops {
    let result = infer_shape(op, [])
    @test.assert_eq(1, result.length())
  }
}

///|
test "wb infer_shape RowNum ColNum" {
  let result1 = infer_shape(Op::RowNum, [[_some([3, 4])]])
  @test.assert_eq(1, result1.length())
  match result1[0] {
    Some(s) => @test.assert_eq(0, s.length())
    None => @test.assert_eq(true, false)
  }
  let result2 = infer_shape(Op::ColNum, [[_some([3, 4])]])
  @test.assert_eq(1, result2.length())
  match result2[0] {
    Some(s) => @test.assert_eq(0, s.length())
    None => @test.assert_eq(true, false)
  }
}

///|
test "wb infer_shape_fold" {
  // Min, Max, Sum, LogSumExp use _infer_shape_fold
  let input = [[_some([2, 3])]]
  let ops = [
    Op::Min(true, 0),
    Op::Max(true, 0),
    Op::Sum(true, 0),
    Op::LogSumExp(true, 0),
  ]
  for op in ops {
    let result = infer_shape(op, input)
    @test.assert_eq(1, result.length())
    match result[0] {
      Some(s) => @test.assert_eq([1], s)
      None => @test.assert_eq(true, false)
    }
  }
  // With None
  let none_input = [[_none()]]
  for op in ops {
    let result = infer_shape(op, none_input)
    @test.assert_eq(1, result.length())
    @test.assert_eq(true, result[0] is None)
  }
  // With empty shape
  let empty_input = [[_some([])]]
  for op in ops {
    let result = infer_shape(op, empty_input)
    @test.assert_eq(1, result.length())
    match result[0] {
      Some(s) => @test.assert_eq(0, s.length())
      None => @test.assert_eq(true, false)
    }
  }
  // With no input
  for op in ops {
    let result = infer_shape(op, [])
    @test.assert_eq(1, result.length())
  }
}

///|
test "wb infer_shape_broadcast" {
  // Binary ops use _infer_shape_broadcast
  let input = [[_some([2, 3])], [_some([3, 3])]]
  let ops = [
    Op::Pow,
    Op::ScalarPow,
    Op::PowScalar,
    Op::Atan2,
    Op::ScalarAtan2,
    Op::Atan2Scalar,
    Op::Hypot,
    Op::Min2,
    Op::Max2,
    Op::Add,
    Op::Sub,
    Op::Mul,
    Op::Div,
    Op::FMA,
    Op::EltEqual,
    Op::EltNotEqual,
    Op::EltLess,
    Op::EltGreater,
    Op::EltLessEqual,
    Op::EltGreaterEqual,
  ]
  for op in ops {
    let result = infer_shape(op, input)
    @test.assert_eq(1, result.length())
  }
  // With one None
  let mixed_input = [[_none()], [_some([3, 3])]]
  for op in ops {
    let result = infer_shape(op, mixed_input)
    @test.assert_eq(1, result.length())
  }
  let mixed_input2 = [[_some([2, 3])], [_none()]]
  for op in ops {
    let result = infer_shape(op, mixed_input2)
    @test.assert_eq(1, result.length())
  }
  // With both None
  let none_input = [[_none()], [_none()]]
  for op in ops {
    let result = infer_shape(op, none_input)
    @test.assert_eq(1, result.length())
  }
  // With insufficient inputs
  for op in ops {
    let result = infer_shape(op, [])
    @test.assert_eq(1, result.length())
  }
}

///|
test "wb infer_shape_concatenate" {
  let input = [[_some([2, 3])]]
  let result = infer_shape(Op::Concatenate(0), input)
  @test.assert_eq(1, result.length())
  match result[0] {
    Some(s) => @test.assert_eq([2, 3], s)
    None => @test.assert_eq(true, false)
  }
  // With None
  let result2 = infer_shape(Op::Concatenate(0), [[_none()]])
  @test.assert_eq(1, result2.length())
  // With empty
  let result3 = infer_shape(Op::Concatenate(0), [])
  @test.assert_eq(1, result3.length())
}

///|
test "wb infer_shape_dot" {
  // 2D x 2D
  let input2d = [[_some([2, 3])], [_some([3, 4])]]
  let result = infer_shape(Op::Dot(true, true), input2d)
  @test.assert_eq(1, result.length())
  match result[0] {
    Some(s) => @test.assert_eq([2, 4], s)
    None => @test.assert_eq(true, false)
  }
  // 1D x 1D
  let input1d = [[_some([3])], [_some([3])]]
  let result2 = infer_shape(Op::Dot(true, true), input1d)
  @test.assert_eq(1, result2.length())
  match result2[0] {
    Some(s) => @test.assert_eq(0, s.length())
    None => @test.assert_eq(true, false)
  }
  // Mismatched dims
  let input_mix = [[_some([2])], [_some([3, 4])]]
  let result3 = infer_shape(Op::Dot(true, true), input_mix)
  @test.assert_eq(1, result3.length())
  // With None
  let none_input = [[_none()], [_some([3, 4])]]
  let result4 = infer_shape(Op::Dot(true, true), none_input)
  @test.assert_eq(1, result4.length())
  // Insufficient inputs
  let result5 = infer_shape(Op::Dot(true, true), [])
  @test.assert_eq(1, result5.length())
}

///|
test "wb infer_shapes graph" {
  let g = make_graph("shape_infer")
  // Use Zeros op which has a fixed shape [3]
  let x = make_node(g, Op::Zeros([3]), "x")
  let y = make_node(g, op_neg(), "y")
  connect(x, y)
  set_inputs(g, [x])
  set_outputs(g, [y])
  infer_shapes(g)
  // x should have shape [3] from Zeros([3])
  match get_node_shape(x)[0] {
    Some(s) => @test.assert_eq([3], s)
    None => @test.assert_eq(true, false)
  }
  // y = neg(x) should also have shape [3] via _infer_shape_01
  match get_node_shape(y)[0] {
    Some(s) => @test.assert_eq([3], s)
    None => @test.assert_eq(true, false)
  }
}

///|
test "wb _broadcast_shapes different lengths" {
  // Test broadcast with different length shapes via infer_shape
  // [3] broadcast [2, 1] => [2, 3]
  let input = [[_some([3])], [_some([2, 1])]]
  let result = infer_shape(Op::Add, input)
  @test.assert_eq(1, result.length())
  match result[0] {
    Some(s) => @test.assert_eq([2, 3], s)
    None => @test.assert_eq(true, false)
  }
  // [2, 3] broadcast [1] => [2, 3]
  let input2 = [[_some([2, 3])], [_some([1])]]
  let result2 = infer_shape(Op::Mul, input2)
  @test.assert_eq(1, result2.length())
  match result2[0] {
    Some(s) => @test.assert_eq([2, 3], s)
    None => @test.assert_eq(true, false)
  }
}

///|
/// Value-verification tests for key eval_node ops (replacing empty assertions).
test "wb eval_node values: Zeros and Ones" {
  let z = eval_node(Op::Zeros([3]), [])
  @test.assert_eq(3, z.data.length())
  @test.assert_eq(0.0, z.data[0])
  @test.assert_eq(0.0, z.data[2])
  let o = eval_node(Op::Ones([2, 2]), [])
  @test.assert_eq(4, o.data.length())
  @test.assert_eq(1.0, o.data[0])
  @test.assert_eq(1.0, o.data[3])
}

///|
test "wb eval_node values: Abs Neg Sqr Sqrt" {
  let x = _arr([-2.0, 3.0])
  let r_abs = eval_node(Op::Abs, [x])
  @test.assert_eq(2.0, r_abs.data[0])
  @test.assert_eq(3.0, r_abs.data[1])
  let r_neg = eval_node(Op::Neg, [x])
  @test.assert_eq(2.0, r_neg.data[0])
  @test.assert_eq(-3.0, r_neg.data[1])
  let y = _arr([3.0, 4.0])
  let r_sqr = eval_node(Op::Sqr, [y])
  @test.assert_eq(9.0, r_sqr.data[0])
  @test.assert_eq(16.0, r_sqr.data[1])
  let r_sqrt = eval_node(Op::Sqrt, [y])
  @test.assert_eq(true, (r_sqrt.data[0] - 1.7320508).abs() < 1.0e-6)
  @test.assert_eq(2.0, r_sqrt.data[1])
}

///|
test "wb eval_node values: Add Mul Sub Div" {
  let x = _arr([1.0, 2.0, 3.0])
  let y = _arr([4.0, 5.0, 6.0])
  let r_add = eval_node(Op::Add, [x, y])
  @test.assert_eq(5.0, r_add.data[0])
  @test.assert_eq(7.0, r_add.data[1])
  @test.assert_eq(9.0, r_add.data[2])
  let r_mul = eval_node(Op::Mul, [x, y])
  @test.assert_eq(4.0, r_mul.data[0])
  @test.assert_eq(10.0, r_mul.data[1])
  @test.assert_eq(18.0, r_mul.data[2])
  let r_sub = eval_node(Op::Sub, [x, y])
  @test.assert_eq(-3.0, r_sub.data[0])
  @test.assert_eq(-3.0, r_sub.data[1])
  let r_div = eval_node(Op::Div, [x, y])
  @test.assert_eq(0.25, r_div.data[0])
  @test.assert_eq(0.4, r_div.data[1])
}

///|
test "wb eval_node values: Exp Sin Cos" {
  let x = _arr([0.0, 1.0])
  let r_exp = eval_node(Op::Exp, [x])
  @test.assert_eq(1.0, r_exp.data[0])
  @test.assert_eq(true, (r_exp.data[1] - 2.7182818).abs() < 1.0e-6)
  let r_sin = eval_node(Op::Sin, [x])
  @test.assert_eq(0.0, r_sin.data[0])
  @test.assert_eq(true, (r_sin.data[1] - 0.8414709).abs() < 1.0e-6)
  let r_cos = eval_node(Op::Cos, [x])
  @test.assert_eq(1.0, r_cos.data[0])
  @test.assert_eq(true, (r_cos.data[1] - 0.5403023).abs() < 1.0e-6)
}

///|
test "wb eval_node values: Sum Min Max" {
  let x = _arr([1.0, 2.0, 3.0])
  let r_sum = eval_node(Op::Sum(true, 0), [x])
  @test.assert_eq(6.0, r_sum.data[0])
  let r_min = eval_node(Op::Min(true, 0), [x])
  @test.assert_eq(1.0, r_min.data[0])
  let r_max = eval_node(Op::Max(true, 0), [x])
  @test.assert_eq(3.0, r_max.data[0])
}

///|
test "wb eval_node values: Sigmoid Relu" {
  let x = _arr([0.0, -1.0, 2.0])
  let r_sig = eval_node(Op::Sigmoid, [x])
  @test.assert_eq(0.5, r_sig.data[0])
  @test.assert_eq(true, (r_sig.data[1] - 0.2689414).abs() < 1.0e-6)
  @test.assert_eq(true, (r_sig.data[2] - 0.8807970).abs() < 1.0e-6)
  let r_relu = eval_node(Op::Relu, [x])
  @test.assert_eq(0.0, r_relu.data[0])
  @test.assert_eq(0.0, r_relu.data[1])
  @test.assert_eq(2.0, r_relu.data[2])
}

///|
/// Numeric value tests for the newly implemented passthrough op families.

///|
test "wb eval values: Tile Repeat Concatenate Stack Split Draw" {
  let x = _arr([1.0, 2.0, 3.0])
  // Tile repeats whole blocks along each dimension.
  let t = eval_node(Op::Tile([2]), [x])
  @test.assert_eq([6], @ndarray.shape(t))
  @test.assert_eq(1.0, t.data[0])
  @test.assert_eq(3.0, t.data[2])
  @test.assert_eq(1.0, t.data[3])
  @test.assert_eq(3.0, t.data[5])
  // Repeat repeats each element in place.
  let r = eval_node(Op::Repeat([2]), [x])
  @test.assert_eq([6], @ndarray.shape(r))
  @test.assert_eq(1.0, r.data[0])
  @test.assert_eq(1.0, r.data[1])
  @test.assert_eq(2.0, r.data[2])
  @test.assert_eq(3.0, r.data[5])
  // Concatenate joins all inputs along the axis.
  let c = eval_node(Op::Concatenate(0), [x, _arr([4.0])])
  @test.assert_eq([4], @ndarray.shape(c))
  @test.assert_eq(4.0, c.data[3])
  // Stack joins inputs along a new axis.
  let st = eval_node(Op::Stack(0), [x, _arr([4.0, 5.0, 6.0])])
  @test.assert_eq([2, 3], @ndarray.shape(st))
  @test.assert_eq(4.0, st.data[3])
  // Split returns the first validated slice (output 0 in Owl's multi-output
  // design); parts-total validation still applies.
  let sp = eval_node(Op::Split(0, [1, 2]), [x])
  @test.assert_eq([1], @ndarray.shape(sp))
  @test.assert_eq(1.0, sp.data[0])
  // Draw picks random slices along the axis; count single draws are stacked,
  // so the shape is [count, ...rest].
  let d = eval_node(Op::Draw(0, 2), [x])
  @test.assert_eq([2], @ndarray.shape(d))
  @test.assert_eq(
    true,
    (d.data[0] == 1.0 || d.data[0] == 2.0 || d.data[0] == 3.0) &&
    (d.data[1] == 1.0 || d.data[1] == 2.0 || d.data[1] == 3.0),
  )
  // UpSampling2d scales [batch, col, row, ch] by [col_scale, row_scale].
  let img = @ndarray.of_array([5.0, 7.0], [1, 2, 1, 1])
  let up = eval_node(Op::UpSampling2d([2, 2]), [img])
  @test.assert_eq([1, 4, 2, 1], @ndarray.shape(up))
  @test.assert_eq(5.0, up.data[0])
  @test.assert_eq(7.0, up.data[4])
}

///|
test "wb eval values: OneHot" {
  let oh = eval_node(Op::OneHot(3), [_arr([0.0, 2.0, 1.0])])
  @test.assert_eq([3, 3], @ndarray.shape(oh))
  @test.assert_eq(1.0, oh.data[0])
  @test.assert_eq(0.0, oh.data[1])
  @test.assert_eq(1.0, oh.data[5])
  @test.assert_eq(1.0, oh.data[7])
  try eval_node(Op::OneHot(3), [_arr([3.0])]) catch {
    @core.OwlError::InvalidArgument(_) =>
      inspect("one-hot out of range", content="one-hot out of range")
    _ => fail("expected InvalidArgument for out-of-range index")
  } noraise {
    _ => fail("expected raise for out-of-range index")
  }
  try eval_node(Op::OneHot(3), [_arr([-1.0])]) catch {
    @core.OwlError::InvalidArgument(_) =>
      inspect("one-hot negative", content="one-hot negative")
    _ => fail("expected InvalidArgument for negative index")
  } noraise {
    _ => fail("expected raise for negative index")
  }
  try eval_node(Op::OneHot(3), [@ndarray.of_array([1.0, 2.0], [2, 1])]) catch {
    @core.OwlError::InvalidArgument(_) =>
      inspect("one-hot non-1d", content="one-hot non-1d")
    _ => fail("expected InvalidArgument for non-1d input")
  } noraise {
    _ => fail("expected raise for non-1d input")
  }
}

///|
test "wb eval values: scalar arithmetic" {
  let x = _arr([1.0, 2.0, 3.0])
  let s = _arr([2.0])
  let add = eval_node(Op::AddScalar, [x, s])
  @test.assert_eq(3.0, add.data[0])
  @test.assert_eq(5.0, add.data[2])
  let sub = eval_node(Op::SubScalar, [x, s])
  @test.assert_eq(-1.0, sub.data[0])
  @test.assert_eq(1.0, sub.data[2])
  let mul = eval_node(Op::MulScalar, [x, s])
  @test.assert_eq(2.0, mul.data[0])
  @test.assert_eq(6.0, mul.data[2])
  let div = eval_node(Op::DivScalar, [x, s])
  @test.assert_eq(0.5, div.data[0])
  @test.assert_eq(1.5, div.data[2])
  let sadd = eval_node(Op::ScalarAdd, [x, s])
  @test.assert_eq(3.0, sadd.data[0])
  let ssub = eval_node(Op::ScalarSub, [x, s])
  @test.assert_eq(1.0, ssub.data[0])
  @test.assert_eq(-1.0, ssub.data[2])
  let smul = eval_node(Op::ScalarMul, [x, s])
  @test.assert_eq(6.0, smul.data[2])
  let sdiv = eval_node(Op::ScalarDiv, [x, s])
  @test.assert_eq(2.0, sdiv.data[0])
  let spow = eval_node(Op::ScalarPow, [x, s])
  @test.assert_eq(1.0, spow.data[0])
  @test.assert_eq(9.0, spow.data[2])
  let ppow = eval_node(Op::PowScalar, [x, s])
  @test.assert_eq(2.0, ppow.data[0])
  @test.assert_eq(8.0, ppow.data[2])
  let sa2 = eval_node(Op::ScalarAtan2, [x, s])
  @test.assert_eq(true, (sa2.data[0] - 1.1071487).abs() < 1.0e-6)
  let a2s = eval_node(Op::Atan2Scalar, [x, s])
  @test.assert_eq(true, (a2s.data[0] - 0.4636476).abs() < 1.0e-6)
}

///|
test "wb eval values: Elt scalar comparisons" {
  let x = _arr([1.0, 2.0, 3.0])
  let s = _arr([2.0])
  let eq = eval_node(Op::EltEqualScalar, [x, s])
  @test.assert_eq(0.0, eq.data[0])
  @test.assert_eq(1.0, eq.data[1])
  @test.assert_eq(0.0, eq.data[2])
  let ne = eval_node(Op::EltNotEqualScalar, [x, s])
  @test.assert_eq(1.0, ne.data[0])
  @test.assert_eq(0.0, ne.data[1])
  @test.assert_eq(1.0, ne.data[2])
  let lt = eval_node(Op::EltLessScalar, [x, s])
  @test.assert_eq(1.0, lt.data[0])
  @test.assert_eq(0.0, lt.data[1])
  @test.assert_eq(0.0, lt.data[2])
  let gt = eval_node(Op::EltGreaterScalar, [x, s])
  @test.assert_eq(0.0, gt.data[0])
  @test.assert_eq(0.0, gt.data[1])
  @test.assert_eq(1.0, gt.data[2])
  let le = eval_node(Op::EltLessEqualScalar, [x, s])
  @test.assert_eq(1.0, le.data[0])
  @test.assert_eq(1.0, le.data[1])
  @test.assert_eq(0.0, le.data[2])
  let ge = eval_node(Op::EltGreaterEqualScalar, [x, s])
  @test.assert_eq(0.0, ge.data[0])
  @test.assert_eq(1.0, ge.data[1])
  @test.assert_eq(1.0, ge.data[2])
}

///|
test "wb eval values: ClipByValue ClipByL2norm" {
  let x = _arr([0.0, 1.0, 2.0, 3.0])
  let clipped = eval_node(Op::ClipByValue, [x, _arr([1.0]), _arr([2.0])])
  @test.assert_eq(1.0, clipped.data[0])
  @test.assert_eq(1.0, clipped.data[1])
  @test.assert_eq(2.0, clipped.data[2])
  @test.assert_eq(2.0, clipped.data[3])
  let v = _arr([3.0, 4.0])
  // L2 norm = 5 == c: no clipping.
  let keep = eval_node(Op::ClipByL2norm, [v, _arr([5.0])])
  @test.assert_eq(3.0, keep.data[0])
  @test.assert_eq(4.0, keep.data[1])
  // L2 norm = 5 > c = 2.5: scale by c/norm = 0.5.
  let scaled = eval_node(Op::ClipByL2norm, [v, _arr([2.5])])
  @test.assert_eq(1.5, scaled.data[0])
  @test.assert_eq(2.0, scaled.data[1])
}

///|
test "wb eval values: Get Set RowNum ColNum" {
  let x = _arr([10.0, 20.0, 30.0])
  let g = eval_node(Op::Get([1]), [x])
  @test.assert_eq([1], @ndarray.shape(g))
  @test.assert_eq(20.0, g.data[0])
  let orig = _arr([10.0, 20.0, 30.0])
  let set = eval_node(Op::Set([1]), [orig, _arr([99.0])])
  @test.assert_eq(99.0, set.data[1])
  @test.assert_eq(10.0, set.data[0])
  // The original input must stay untouched.
  @test.assert_eq(20.0, orig.data[1])
  let m = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let rn = eval_node(Op::RowNum, [m])
  @test.assert_eq([1], @ndarray.shape(rn))
  @test.assert_eq(2.0, rn.data[0])
  let cn = eval_node(Op::ColNum, [m])
  @test.assert_eq(3.0, cn.data[0])
  try eval_node(Op::RowNum, [x]) catch {
    @core.OwlError::InvalidArgument(_) =>
      inspect("rownum non-2d", content="rownum non-2d")
    _ => fail("expected InvalidArgument for 1D RowNum")
  } noraise {
    _ => fail("expected raise for 1D RowNum")
  }
}

///|
test "wb eval values: Row Rows" {
  let m = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let row = eval_node(Op::Row, [m])
  @test.assert_eq([1, 3], @ndarray.shape(row))
  @test.assert_eq(1.0, row.data[0])
  @test.assert_eq(3.0, row.data[2])
  let rows = eval_node(Op::Rows([1]), [m])
  @test.assert_eq([1, 3], @ndarray.shape(rows))
  @test.assert_eq(4.0, rows.data[0])
  let both = eval_node(Op::Rows([0, 1]), [m])
  @test.assert_eq([2, 3], @ndarray.shape(both))
  @test.assert_eq(6.0, both.data[5])
  // A 1D input is treated as a single row.
  let r1 = eval_node(Op::Row, [_arr([7.0, 8.0])])
  @test.assert_eq([1, 2], @ndarray.shape(r1))
  @test.assert_eq(8.0, r1.data[1])
  try eval_node(Op::Rows([2]), [m]) catch {
    @core.OwlError::OutOfRange(..) =>
      inspect("rows out of range", content="rows out of range")
    _ => fail("expected OutOfRange for row index 2")
  } noraise {
    _ => fail("expected raise for row index 2")
  }
}

///|
test "wb eval values: Inv Trace" {
  let m = @ndarray.of_array([4.0, 0.0, 0.0, 2.0], [2, 2])
  let inv = eval_node(Op::Inv, [m])
  @test.assert_eq([2, 2], @ndarray.shape(inv))
  @test.assert_eq(0.25, inv.data[0])
  @test.assert_eq(0.5, inv.data[3])
  let t = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let tr = eval_node(Op::Trace, [t])
  @test.assert_eq([1], @ndarray.shape(tr))
  @test.assert_eq(5.0, tr.data[0])
}

///|
test "wb eval values: Conv2d pools" {
  let input = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0], [
    1, 3, 3, 1,
  ])
  let kernel = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [2, 2, 1, 1])
  let conv = eval_node(Op::Conv2d(@core.Padding::Valid, [1, 1]), [input, kernel])
  @test.assert_eq([1, 2, 2, 1], @ndarray.shape(conv))
  // Each output element sums a 2x2 patch: 1+2+4+5=12, 2+3+5+6=16, 4+5+7+8=24, 5+6+8+9=28.
  @test.assert_eq(12.0, conv.data[0])
  @test.assert_eq(16.0, conv.data[1])
  @test.assert_eq(24.0, conv.data[2])
  @test.assert_eq(28.0, conv.data[3])
  let pooled = eval_node(Op::MaxPool2d(@core.Padding::Valid, [2, 2], [1, 1]), [
    input,
  ])
  @test.assert_eq([1, 2, 2, 1], @ndarray.shape(pooled))
  // Max of 2x2 patches: 5, 6, 8, 9.
  @test.assert_eq(5.0, pooled.data[0])
  @test.assert_eq(9.0, pooled.data[3])
  let avg = eval_node(Op::AvgPool2d(@core.Padding::Valid, [2, 2], [1, 1]), [
    input,
  ])
  // Average of 2x2 patches: 3, 4, 6, 7.
  @test.assert_eq(3.0, avg.data[0])
  @test.assert_eq(7.0, avg.data[3])
}

///|
test "wb eval values: axis reductions" {
  let m = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let s = eval_node(Op::Sum(true, 0), [m])
  @test.assert_eq([1, 3], @ndarray.shape(s))
  @test.assert_eq(5.0, s.data[0])
  @test.assert_eq(7.0, s.data[1])
  @test.assert_eq(9.0, s.data[2])
  let s2 = eval_node(Op::Sum(false, 1), [m])
  @test.assert_eq([2], @ndarray.shape(s2))
  @test.assert_eq(6.0, s2.data[0])
  @test.assert_eq(15.0, s2.data[1])
  let mx = eval_node(Op::Max(true, 0), [m])
  @test.assert_eq(4.0, mx.data[0])
  let mn = eval_node(Op::Min(false, 0), [m])
  @test.assert_eq([3], @ndarray.shape(mn))
  @test.assert_eq(1.0, mn.data[0])
  let lse = eval_node(Op::LogSumExp(false, 0), [m])
  @test.assert_eq([3], @ndarray.shape(lse))
  // log(e^1 + e^4) = 4.0485874...
  @test.assert_eq(true, (lse.data[0] - 4.0485874).abs() < 1.0e-6)
}

///|
test "wb eval raises: unimplementable ops" {
  let x = _arr([1.0, 2.0, 3.0])
  let ops : Array[Op] = [
    Op::MinPrime,
    Op::MaxPrime,
    Op::LogSumExpPrime,
    Op::L1normPrime,
    Op::L2normPrime,
    Op::L2NormSqrPrime,
    Op::CopyRowTo,
    Op::CopyColTo,
    Op::ToRows,
    Op::OfRows,
    Op::FusedAdagrad(0.01, 1.0e-8),
  ]
  for op in ops {
    let name = op_to_str(op)
    try eval_node(op, [x]) catch {
      @core.OwlError::NotImplemented(_) =>
        inspect("\{name} raises", content="\{name} raises")
      _ => fail("expected NotImplemented for \{name}")
    } noraise {
      _ => fail("expected raise for \{name}")
    }
  }
}

///|
test "wb eval raises: Split parts mismatch" {
  try eval_node(Op::Split(0, [1, 1]), [_arr([1.0, 2.0, 3.0])]) catch {
    @core.OwlError::InvalidArgument(_) =>
      inspect("split mismatch", content="split mismatch")
    _ => fail("expected InvalidArgument for parts mismatch")
  } noraise {
    _ => fail("expected raise for parts mismatch")
  }
}
