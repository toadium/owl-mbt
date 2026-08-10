///|
pub fn op_zeros(shape : Array[Int]) -> Op {
  Zeros(shape)
}

///|
pub fn op_ones(shape : Array[Int]) -> Op {
  Ones(shape)
}

///|
pub fn op_add() -> Op {
  Add
}

///|
pub fn op_mul() -> Op {
  Mul
}

///|
pub fn op_var() -> Op {
  Var
}

///|
pub fn op_const() -> Op {
  Const
}

///|
pub fn op_abs() -> Op {
  Abs
}

///|
pub fn op_neg() -> Op {
  Neg
}

///|
pub fn op_exp() -> Op {
  Exp
}

///|
pub fn op_log() -> Op {
  Log
}

///|
pub fn op_sqr() -> Op {
  Sqr
}

///|
pub fn op_reshape(shape : Array[Int]) -> Op {
  Reshape(shape)
}

///|
pub fn op_transpose() -> Op {
  Transpose([])
}

///|
pub fn op_dot() -> Op {
  Dot(false, false)
}

///|
pub fn op_sum() -> Op {
  Sum(false, -1)
}

///|
pub fn op_copy() -> Op {
  Copy
}
