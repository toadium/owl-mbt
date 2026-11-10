///|
/// 神经网络前向传播示例
/// 构建 MLP: input(2) -> linear(3) -> relu -> linear(1) -> sigmoid
fn main raise {
  // 构建网络
  let x = @neural.input([2])
  let h = @neural.linear(x, 3, init_typ=@neural.init_he_normal())
  let a = @neural.activation(h, @neural.act_relu())
  let o = @neural.linear(a, 1, init_typ=@neural.init_glorot_uniform())
  let _ = @neural.activation(o, @neural.act_sigmoid())

  let nn = @neural.get_network(x)
  @neural.init_network(nn)

  // 输入数据
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 2], [0.5, -0.5]))

  // 前向传播
  let (y, params) = @neural.forward(nn, inp)
  let y_arr = @algodiff.unpack_arr(y)
  println("网络输出:")
  println(@ndarray.to_string(y_arr))
  println("\n参数数量: \{params.length()}")

  // 反向传播
  let (pri, adj) = @neural.backward(nn, y)
  println("前向值数量: \{pri.length()}")
  println("反向梯度数量: \{adj.length()}")
}
