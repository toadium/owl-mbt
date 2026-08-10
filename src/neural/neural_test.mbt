///|
test "neural_input_create" {
  let n = input([3])
  let nn = get_network(n)
  @test.assert_eq(1, nn.topo.val.length())
}

///|
test "neural_linear_layer" {
  let x = input([2])
  let _ = linear(x, 3, init_typ=init_standard())
  let nn = get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_linear_nobias_layer" {
  let x = input([2])
  let _ = linear_nobias(x, 3, init_typ=init_standard())
  let nn = get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_activation_layer" {
  let x = input([3])
  let _ = activation(x, act_relu())
  let nn = get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_flatten_layer" {
  let x = input([2, 3])
  let _ = flatten(x)
  let nn = get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_reshape_layer" {
  let x = input([6])
  let _ = reshape(x, [2, 3])
  let nn = get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_forward_pass" {
  let x = input([2])
  let h = linear(x, 3, init_typ=init_standard())
  let _ = activation(h, act_relu())
  let nn = get_network(x)
  init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 2], [1.0, 2.0]))
  let (y, _params) = forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([3], shape)
}

///|
test "neural_forward_backward" {
  let x = input([2])
  let h = linear(x, 1, init_typ=init_standard())
  let _ = activation(h, act_sigmoid())
  let nn = get_network(x)
  init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 2], [0.5, -0.5]))
  let (y, _params) = forward(nn, inp)
  let (pri, adj) = backward(nn, y)
  @test.assert_eq(true, pri.length() >= 2)
  @test.assert_eq(true, adj.length() >= 2)
}

///|
test "neural_multi_layer" {
  let x = input([4])
  let h1 = linear(x, 8, init_typ=init_glorot_uniform())
  let a1 = activation(h1, act_tanh())
  let h2 = linear(a1, 4, init_typ=init_glorot_uniform())
  let _ = activation(h2, act_relu())
  let nn = get_network(x)
  init_network(nn)
  let inp = @algodiff.pack_arr(
    @ndarray.from_data([1, 4], [0.1, 0.2, -0.1, -0.2]),
  )
  let (y, _) = forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([4], shape)
}

///|
test "neural_dropout_layer" {
  let x = input([3])
  let _ = dropout(x, 0.5)
  let nn = get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_lambda_layer" {
  let x = input([3])
  let _ = lambda(x, fn(v) raise { @algodiff.relu(v) })
  let nn = get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_init_typ_standard" {
  let n = init_run(init_standard(), [3, 4])
  let s = @algodiff.shape(n)
  @test.assert_eq([3, 4], s)
}

///|
test "neural_init_typ_glorot" {
  let n = init_run(init_glorot_uniform(), [3, 4])
  let s = @algodiff.shape(n)
  @test.assert_eq([3, 4], s)
}

///|
test "neural_get_in_out_shape" {
  let x = input([5])
  let neuron = x.neuron.val
  let in_s = get_in_shape(neuron)
  let out_s = get_out_shape(neuron)
  @test.assert_eq([5], in_s)
  @test.assert_eq([5], out_s)
}

///|
test "neural_connect_shapes" {
  let x = input([2])
  let h = linear(x, 3, init_typ=init_standard())
  let nn = get_network(x)
  init_network(nn)
  let neuron = h.neuron.val
  @test.assert_eq([2], get_in_shape(neuron))
  @test.assert_eq([3], get_out_shape(neuron))
}

///|
test "neural_run_activation_relu" {
  let x = @algodiff.pack_flt(-1.0)
  let y = run_activation(x, act_relu())
  match y {
    F(v) => @test.assert_eq(true, v < 0.001)
    _ => @test.assert_eq(true, false)
  }
}

///|
test "neural_run_activation_sigmoid" {
  let x = @algodiff.pack_flt(-1.0)
  let y = run_activation(x, act_sigmoid())
  match y {
    F(v) => @test.assert_eq(true, (v - 1.0).abs() < 0.01)
    _ => @test.assert_eq(true, false)
  }
}

///|
test "neural_run_activation_none" {
  let x = @algodiff.pack_flt(3.14)
  let y = run_activation(x, act_none())
  match y {
    F(v) => @test.assert_eq(3.14, v)
    _ => @test.assert_eq(true, false)
  }
}
