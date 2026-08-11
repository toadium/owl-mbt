///|
/// 元素精度类型（移植自 owl_types_common.ml:number）
pub(all) enum Number {
  F32
  F64
  C32
  C64
} derive(Debug, Eq)

///|
/// 切片索引类型（移植自 owl_types_common.ml:index）
pub(all) enum Index {
  I(Int)
  L(Array[Int])
  R(Array[Int])
} derive(Debug)

///|
/// 卷积/池化填充模式（移植自 owl_types_common.ml:padding）
pub(all) enum Padding {
  Same
  Valid
} derive(Debug, Eq)

///|
/// 计算设备类型（移植自 owl_types_common.ml:device_type）
pub(all) enum DeviceType {
  Cpu
  OpenCl
  Cuda
} derive(Debug, Eq)

///|
/// Owl 项目错误类型。移植自 owl_exception.ml 中的各异常，
/// 统一为 checked error（migration skill 要求：不复制 unchecked 异常流）。
pub(all) suberror OwlError {
  InvalidArgument(String)
  NotFound
  NotImplemented(String)
  ShapeMismatch(expected~ : Array[Int], actual~ : Array[Int])
  OutOfRange(index~ : Int, bound~ : Int)
} derive(Debug)
