///|
/// Ndarray 基本操作示例
/// 演示 Owl-MBT 的核心 n 维数组功能
fn main raise {
  // 创建数组
  let a = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  println("数组 a (2x3):")
  println(@ndarray.to_string(a))

  // 数组运算
  let b = @ndarray.of_array([0.1, 0.2, 0.3, 0.4, 0.5, 0.6], [2, 3])
  let c = @ndarray.add(a, b)
  println("\na + b:")
  println(@ndarray.to_string(c))

  // 矩阵转置
  let at = @ndarray.transpose(a)
  println("\na 转置 (3x2):")
  println(@ndarray.to_string(at))

  // 矩阵乘法
  let d = @ndarray.of_array([1.0, 0.0, 0.0, 1.0], [2, 2])
  let e = @ndarray.dot(d, a)
  println("\n单位矩阵 * a = a:")
  println(@ndarray.to_string(e))

  // 元素求和
  let s = @ndarray.sum(a)
  println("\nsum(a) = \{s.data[0]}")

  // 数学函数
  let x = @ndarray.of_array([0.0, 1.0, 2.0], [3])
  let sx = @ndarray.map_elem(x, fn(v) { @math.sin(v) })
  println("\nsin([0, 1, 2]):")
  println(@ndarray.to_string(sx))
}
