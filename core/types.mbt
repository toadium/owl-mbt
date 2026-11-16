///|
/// 元素精度类型（移植自 owl_types_common.ml:number）
#derive(Debug, Eq)
pub(all) enum Number {
  F32
  F64
  C32
  C64
}

///|
/// 切片索引类型（移植自 owl_types_common.ml:index）
/// I(idx) — single index; L(list) — list of indices; R(range) — range of indices.
#derive(Debug, Eq)
pub(all) enum Index {
  I(Int32)
  L(Array[Int32])
  R(Array[Int32])
}

///|
/// 卷积/池化填充模式（移植自 owl_types_common.ml:padding）
#derive(Debug, Eq)
pub(all) enum Padding {
  Same
  Valid
}

///|
/// 计算设备类型（移植自 owl_types_common.ml:device_type）
/// Note: OpenCl and Cuda are not supported in pure MoonBit backend.
#derive(Debug, Eq)
pub(all) enum DeviceType {
  Cpu
  OpenCl
  Cuda
}

///|
/// Owl 项目错误类型。移植自 owl_exception.ml 中的各异常，
/// 统一为 checked error（migration skill 要求：不复制 unchecked 异常流）。
#derive(Debug)
pub(all) suberror OwlError {
  InvalidArgument(String)
  NotFound
  NotImplemented(String)
  ShapeMismatch(expected~ : Array[Int32], actual~ : Array[Int32])
  OutOfRange(index~ : Int32, bound~ : Int32)
}
