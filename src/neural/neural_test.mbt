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

// ===== Business Scenario Tests =====

///|
test "scenario: MLP forward pass with multiple layers" {
  // Build: input(4) -> linear(8) -> tanh -> linear(4) -> relu -> linear(1) -> sigmoid
  let x = input([4])
  let h1 = linear(x, 8, init_typ=init_he_normal())
  let a1 = activation(h1, act_tanh())
  let h2 = linear(a1, 4, init_typ=init_he_normal())
  let a2 = activation(h2, act_relu())
  let h3 = linear(a2, 1, init_typ=init_glorot_uniform())
  let _ = activation(h3, act_sigmoid())
  let nn = get_network(x)
  init_network(nn)
  let inp = @algodiff.pack_arr(
    @ndarray.from_data([1, 4], [0.1, -0.2, 0.3, -0.4]),
  )
  let (y, params) = forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([1], shape)
  @test.assert_eq(true, params.length() > 0)
}

///|
test "scenario: forward-backward gradient flow" {
  // Build: input(2) -> linear(3) -> relu -> linear(1)
  let x = input([2])
  let h = linear(x, 3, init_typ=init_standard())
  let a = activation(h, act_relu())
  let _ = linear(a, 1, init_typ=init_standard())
  let nn = get_network(x)
  init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 2], [1.0, -1.0]))
  let (y, _) = forward(nn, inp)
  let (pri, adj) = backward(nn, y)
  // Verify primal and adjoint flows have correct structure
  // Network has 4 topo nodes: input, linear, activation, linear
  let n_nodes = nn.topo.val.length()
  @test.assert_eq(n_nodes, pri.length())
  @test.assert_eq(n_nodes, adj.length())
  // Each node should have primal and adjoint
  for i in 0..<pri.length() {
    @test.assert_eq(true, pri[i].length() >= 0)
  }
}

///|
test "scenario: different activation functions" {
  // Test all activation types work in a network
  let activations = [
    act_relu(),
    act_sigmoid(),
    act_tanh(),
    act_none(),
    act_softplus(),
    act_softsign(),
    act_relu6(),
  ]
  for act in activations {
    let x = input([3])
    let _ = activation(x, act)
    let nn = get_network(x)
    init_network(nn)
    let inp = @algodiff.pack_arr(@ndarray.from_data([1, 3], [0.5, -0.5, 1.0]))
    let (y, _) = forward(nn, inp)
    let shape = @algodiff.arr_shape(y)
    @test.assert_eq([3], shape)
  }
}

///|
test "scenario: different init strategies" {
  // Test all initialization strategies
  let inits = [
    init_standard(),
    init_glorot_uniform(),
    init_glorot_normal(),
    init_tanh(),
    init_lecun_normal(),
    init_he_normal(),
  ]
  for init_t in inits {
    let x = input([2])
    let _ = linear(x, 4, init_typ=init_t)
    let nn = get_network(x)
    init_network(nn)
    @test.assert_eq(true, nn.topo.val.length() >= 2)
  }
}

///|
test "scenario: dropout in training mode" {
  // Dropout should work in forward pass
  let x = input([4])
  let h = linear(x, 4, init_typ=init_standard())
  let _ = dropout(h, 0.3)
  let nn = get_network(x)
  init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 4], [1.0, 2.0, 3.0, 4.0]))
  let (y, _) = forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([4], shape)
}

///|
test "scenario: reshape and flatten in network" {
  // input(6) -> reshape(2,3) -> flatten -> linear(2)
  let x = input([6])
  let r = reshape(x, [2, 3])
  let f = flatten(r)
  let _ = linear(f, 2, init_typ=init_standard())
  let nn = get_network(x)
  init_network(nn)
  let inp = @algodiff.pack_arr(
    @ndarray.from_data([1, 6], [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]),
  )
  let (y, _) = forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([2], shape)
}

///|
test "scenario: lambda custom layer" {
  // Custom layer: x -> x^2 (element-wise square)
  let x = input([3])
  let _ = lambda(x, fn(v) { @algodiff.mul(v, v) })
  let nn = get_network(x)
  init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 3], [2.0, 3.0, 4.0]))
  let (y, _) = forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([3], shape)
}
