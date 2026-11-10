///|
/// Node state in the computation graph.
pub enum State {
  Valid
  Invalid
}

///|
/// Operation type stored in each graph node.
/// Ported from owl_computation_type.ml op type.
#warnings("-unused_constructor")
pub enum Op {
  Noop
  Var
  Const
  Empty(Array[Int32])
  Zeros(Array[Int32])
  Ones(Array[Int32])
  Create(Array[Int32])
  Sequential(Array[Int32])
  Uniform(Array[Int32])
  Gaussian(Array[Int32])
  Bernoulli(Array[Int32])
  Get(Array[Int32])
  Set(Array[Int32])
  Copy
  Reset
  Reshape(Array[Int32])
  Reverse
  Tile(Array[Int32])
  Repeat(Array[Int32])
  Concatenate(Int32)
  Stack(Int32)
  Split(Int32, Array[Int32])
  Draw(Int32, Int32)
  OneHot(Int32)
  Abs
  Neg
  Floor
  Ceil
  Round
  Sqr
  Sqrt
  Log
  Log2
  Log10
  Exp
  Sin
  Cos
  Tan
  Sinh
  Cosh
  Tanh
  Asin
  Acos
  Atan
  Asinh
  Acosh
  Atanh
  Min(Bool, Int32)
  Max(Bool, Int32)
  Sum(Bool, Int32)
  SumReduce(Array[Int32])
  Signum
  Sigmoid
  Relu
  MinPrime
  MaxPrime
  SumPrime
  LogSumExpPrime
  LogSumExp(Bool, Int32)
  L1normPrime
  L2normPrime
  L2NormSqrPrime
  ClipByValue
  ClipByL2norm
  Pow
  ScalarPow
  PowScalar
  Atan2
  ScalarAtan2
  Atan2Scalar
  Hypot
  Min2
  Max2
  Add
  Sub
  Mul
  Div
  AddScalar
  SubScalar
  MulScalar
  DivScalar
  ScalarAdd
  ScalarSub
  ScalarMul
  ScalarDiv
  FMA
  EltEqual
  EltNotEqual
  EltLess
  EltGreater
  EltLessEqual
  EltGreaterEqual
  EltEqualScalar
  EltNotEqualScalar
  EltLessScalar
  EltGreaterScalar
  EltLessEqualScalar
  EltGreaterEqualScalar
  Conv1d(@core.Padding, Array[Int32])
  Conv2d(@core.Padding, Array[Int32])
  Conv3d(@core.Padding, Array[Int32])
  TransposeConv1d(@core.Padding, Array[Int32])
  TransposeConv2d(@core.Padding, Array[Int32])
  TransposeConv3d(@core.Padding, Array[Int32])
  MaxPool1d(@core.Padding, Array[Int32], Array[Int32])
  MaxPool2d(@core.Padding, Array[Int32], Array[Int32])
  MaxPool3d(@core.Padding, Array[Int32], Array[Int32])
  AvgPool1d(@core.Padding, Array[Int32], Array[Int32])
  AvgPool2d(@core.Padding, Array[Int32], Array[Int32])
  AvgPool3d(@core.Padding, Array[Int32], Array[Int32])
  UpSampling2d(Array[Int32])
  RowNum
  ColNum
  Row
  Rows(Array[Int32])
  CopyRowTo
  CopyColTo
  Dot(Bool, Bool)
  Inv
  Trace
  Transpose(Array[Int32])
  ToRows
  OfRows
  FusedAdagrad(Double, Double)
}

///|
/// Convert an op to a string name.
pub fn op_to_str(op : Op) -> String {
  match op {
    Noop => "Noop"
    Var => "Var"
    Const => "Const"
    Empty(_) => "Empty"
    Zeros(_) => "Zeros"
    Ones(_) => "Ones"
    Create(_) => "Create"
    Sequential(_) => "Sequential"
    Uniform(_) => "Uniform"
    Gaussian(_) => "Gaussian"
    Bernoulli(_) => "Bernoulli"
    Get(_) => "Get"
    Set(_) => "Set"
    Copy => "Copy"
    Reset => "Reset"
    Reshape(_) => "Reshape"
    Reverse => "Reverse"
    Tile(_) => "Tile"
    Repeat(_) => "Repeat"
    Concatenate(_) => "Concatenate"
    Stack(_) => "Stack"
    Split(_, _) => "Split"
    Draw(_, _) => "Draw"
    OneHot(_) => "OneHot"
    Abs => "Abs"
    Neg => "Neg"
    Floor => "Floor"
    Ceil => "Ceil"
    Round => "Round"
    Sqr => "Sqr"
    Sqrt => "Sqrt"
    Log => "Log"
    Log2 => "Log2"
    Log10 => "Log10"
    Exp => "Exp"
    Sin => "Sin"
    Cos => "Cos"
    Tan => "Tan"
    Sinh => "Sinh"
    Cosh => "Cosh"
    Tanh => "Tanh"
    Asin => "Asin"
    Acos => "Acos"
    Atan => "Atan"
    Asinh => "Asinh"
    Acosh => "Acosh"
    Atanh => "Atanh"
    Min(_, _) => "Min"
    Max(_, _) => "Max"
    Sum(_, _) => "Sum"
    SumReduce(_) => "SumReduce"
    Signum => "Signum"
    Sigmoid => "Sigmoid"
    Relu => "Relu"
    MinPrime => "Min'"
    MaxPrime => "Max'"
    SumPrime => "Sum'"
    LogSumExpPrime => "LogSumExp'"
    LogSumExp(_, _) => "LogSumExp"
    L1normPrime => "L1norm'"
    L2normPrime => "L2norm'"
    L2NormSqrPrime => "L2NormSqr'"
    ClipByValue => "ClipByValue"
    ClipByL2norm => "ClipByL2norm"
    Pow => "Pow"
    ScalarPow => "ScalarPow"
    PowScalar => "PowScalar"
    Atan2 => "Atan2"
    ScalarAtan2 => "ScalarAtan2"
    Atan2Scalar => "Atan2Scalar"
    Hypot => "Hypot"
    Min2 => "Min2"
    Max2 => "Max2"
    Add => "Add"
    Sub => "Sub"
    Mul => "Mul"
    Div => "Div"
    AddScalar => "AddScalar"
    SubScalar => "SubScalar"
    MulScalar => "MulScalar"
    DivScalar => "DivScalar"
    ScalarAdd => "ScalarAdd"
    ScalarSub => "ScalarSub"
    ScalarMul => "ScalarMul"
    ScalarDiv => "ScalarDiv"
    FMA => "FMA"
    EltEqual => "EltEqual"
    EltNotEqual => "EltNotEqual"
    EltLess => "EltLess"
    EltGreater => "EltGreater"
    EltLessEqual => "EltLessEqual"
    EltGreaterEqual => "EltGreaterEqual"
    EltEqualScalar => "EltEqualScalar"
    EltNotEqualScalar => "EltNotEqualScalar"
    EltLessScalar => "EltLessScalar"
    EltGreaterScalar => "EltGreaterScalar"
    EltLessEqualScalar => "EltLessEqualScalar"
    EltGreaterEqualScalar => "EltGreaterEqualScalar"
    Conv1d(_, _) => "Conv1d"
    Conv2d(_, _) => "Conv2d"
    Conv3d(_, _) => "Conv3d"
    TransposeConv1d(_, _) => "TransposeConv1d"
    TransposeConv2d(_, _) => "TransposeConv2d"
    TransposeConv3d(_, _) => "TransposeConv3d"
    MaxPool1d(_, _, _) => "MaxPool1d"
    MaxPool2d(_, _, _) => "MaxPool2d"
    MaxPool3d(_, _, _) => "MaxPool3d"
    AvgPool1d(_, _, _) => "AvgPool1d"
    AvgPool2d(_, _, _) => "AvgPool2d"
    AvgPool3d(_, _, _) => "AvgPool3d"
    UpSampling2d(_) => "UpSampling2d"
    RowNum => "RowNum"
    ColNum => "ColNum"
    Row => "Row"
    Rows(_) => "Rows"
    CopyRowTo => "CopyRowTo"
    CopyColTo => "CopyColTo"
    Dot(_, _) => "Dot"
    Inv => "Inv"
    Trace => "Trace"
    Transpose(_) => "Transpose"
    ToRows => "ToRows"
    OfRows => "OfRows"
    FusedAdagrad(_, _) => "Fused_Adagrad"
  }
}

///|
/// Check if an op is a unary element-wise operation.
pub fn is_unary(op : Op) -> Bool {
  match op {
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
    | Copy
    | Reset
    | Reverse
    | RowNum
    | ColNum
    | Row
    | CopyRowTo
    | CopyColTo
    | Inv
    | Trace
    | ToRows
    | OfRows => true
    _ => false
  }
}

///|
/// Check if an op is a binary element-wise operation.
pub fn is_binary(op : Op) -> Bool {
  match op {
    Add
    | Sub
    | Mul
    | Div
    | Pow
    | Atan2
    | Hypot
    | Min2
    | Max2
    | FMA
    | EltEqual
    | EltNotEqual
    | EltLess
    | EltGreater
    | EltLessEqual
    | EltGreaterEqual
    | Dot(_, _) => true
    _ => false
  }
}
