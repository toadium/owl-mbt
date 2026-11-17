///|
/// 创建全 0 张量节点。
pub fn op_zeros(shape : Array[Int32]) -> Op {
  Zeros(shape)
}

///|
/// 创建全 1 张量节点。
pub fn op_ones(shape : Array[Int32]) -> Op {
  Ones(shape)
}

///|
/// 创建逐元素加法节点。
pub fn op_add() -> Op {
  Add
}

///|
/// 创建逐元素乘法节点。
pub fn op_mul() -> Op {
  Mul
}

///|
/// 创建变量节点。
pub fn op_var() -> Op {
  Var
}

///|
/// 创建常量节点。
pub fn op_const() -> Op {
  Const
}

///|
/// 创建逐元素绝对值节点。
pub fn op_abs() -> Op {
  Abs
}

///|
/// 创建逐元素取负节点。
pub fn op_neg() -> Op {
  Neg
}

///|
/// 创建逐元素指数节点。
pub fn op_exp() -> Op {
  Exp
}

///|
/// 创建逐元素自然对数节点。
pub fn op_log() -> Op {
  Log
}

///|
/// 创建逐元素平方节点。
pub fn op_sqr() -> Op {
  Sqr
}

///|
/// 创建形状重塑节点。
pub fn op_reshape(shape : Array[Int32]) -> Op {
  Reshape(shape)
}

///|
/// 创建转置节点。
pub fn op_transpose() -> Op {
  Transpose([])
}

///|
/// 创建矩阵乘法节点。
pub fn op_dot() -> Op {
  Dot(false, false)
}

///|
/// 创建求和归约节点。
pub fn op_sum() -> Op {
  Sum(false, -1)
}

///|
/// 创建复制节点。
pub fn op_copy() -> Op {
  Copy
}
