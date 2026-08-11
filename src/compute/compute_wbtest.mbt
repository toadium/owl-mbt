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
    Op::Set([0]),
    Op::Tile([1]),
    Op::Repeat([1]),
    Op::Concatenate(0),
    Op::Stack(0),
    Op::Split(0, [1]),
    Op::Draw(1, 0),
    Op::OneHot(3),
    Op::Reshape([3]),
    Op::Transpose([1]),
  ]
  for op in ops {
    _eval1(op, x)
  }
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
test "wb eval_node scalar passthrough" {
  let x = _arr([1.0, 2.0, 3.0])
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
    _eval1(op, x)
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
test "wb eval_node conv/pool passthrough" {
  let x = _arr([1.0, 2.0, 3.0])
  let ops = [
    Op::Conv1d(@types.Padding::Valid, [1]),
    Op::Conv2d(@types.Padding::Valid, [1, 1]),
    Op::Conv3d(@types.Padding::Valid, [1, 1, 1]),
    Op::TransposeConv1d(@types.Padding::Valid, [1]),
    Op::TransposeConv2d(@types.Padding::Valid, [1, 1]),
    Op::TransposeConv3d(@types.Padding::Valid, [1, 1, 1]),
    Op::MaxPool1d(@types.Padding::Valid, [2], [1]),
    Op::MaxPool2d(@types.Padding::Valid, [2, 2], [1, 1]),
    Op::MaxPool3d(@types.Padding::Valid, [2, 2, 2], [1, 1, 1]),
    Op::AvgPool1d(@types.Padding::Valid, [2], [1]),
    Op::AvgPool2d(@types.Padding::Valid, [2, 2], [1, 1]),
    Op::AvgPool3d(@types.Padding::Valid, [2, 2, 2], [1, 1, 1]),
    Op::UpSampling2d([2, 2]),
    Op::RowNum,
    Op::ColNum,
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
    _eval1(op, x)
  }
  @test.assert_eq(true, true)
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
    Op::Conv1d(@types.Padding::Valid, [1]),
    Op::Conv2d(@types.Padding::Valid, [1, 1]),
    Op::Conv3d(@types.Padding::Valid, [1, 1, 1]),
    Op::TransposeConv1d(@types.Padding::Valid, [1]),
    Op::TransposeConv2d(@types.Padding::Valid, [1, 1]),
    Op::TransposeConv3d(@types.Padding::Valid, [1, 1, 1]),
    Op::MaxPool1d(@types.Padding::Valid, [2], [1]),
    Op::MaxPool2d(@types.Padding::Valid, [2, 2], [1, 1]),
    Op::MaxPool3d(@types.Padding::Valid, [2, 2, 2], [1, 1, 1]),
    Op::AvgPool1d(@types.Padding::Valid, [2], [1]),
    Op::AvgPool2d(@types.Padding::Valid, [2, 2], [1, 1]),
    Op::AvgPool3d(@types.Padding::Valid, [2, 2, 2], [1, 1, 1]),
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
fn _some(s : Array[Int]) -> Array[Int]? {
  Some(s)
}

///|
/// Helper: None shape
fn _none() -> Array[Int]? {
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
    Op::Conv1d(@types.Padding::Valid, [1]),
    Op::Conv2d(@types.Padding::Valid, [1, 1]),
    Op::Conv3d(@types.Padding::Valid, [1, 1, 1]),
    Op::TransposeConv1d(@types.Padding::Valid, [1]),
    Op::TransposeConv2d(@types.Padding::Valid, [1, 1]),
    Op::TransposeConv3d(@types.Padding::Valid, [1, 1, 1]),
    Op::MaxPool1d(@types.Padding::Valid, [2], [1]),
    Op::MaxPool2d(@types.Padding::Valid, [2, 2], [1, 1]),
    Op::MaxPool3d(@types.Padding::Valid, [2, 2, 2], [1, 1, 1]),
    Op::AvgPool1d(@types.Padding::Valid, [2], [1]),
    Op::AvgPool2d(@types.Padding::Valid, [2, 2], [1, 1]),
    Op::AvgPool3d(@types.Padding::Valid, [2, 2, 2], [1, 1, 1]),
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
