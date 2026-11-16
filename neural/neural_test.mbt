///|
test "neural_input_create" {
  let n = @neural.input([3])
  let nn = @neural.get_network(n)
  @test.assert_eq(1, nn.topo.val.length())
}

///|
test "neural_linear_layer" {
  let x = @neural.input([2])
  let _ = @neural.linear(x, 3, init_typ=@neural.init_standard())
  let nn = @neural.get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_linear_nobias_layer" {
  let x = @neural.input([2])
  let _ = @neural.linear_nobias(x, 3, init_typ=@neural.init_standard())
  let nn = @neural.get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_activation_layer" {
  let x = @neural.input([3])
  let _ = @neural.activation(x, @neural.act_relu())
  let nn = @neural.get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_flatten_layer" {
  let x = @neural.input([2, 3])
  let _ = @neural.flatten(x)
  let nn = @neural.get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_reshape_layer" {
  let x = @neural.input([6])
  let _ = @neural.reshape(x, [2, 3])
  let nn = @neural.get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_forward_pass" {
  let x = @neural.input([2])
  let h = @neural.linear(x, 3, init_typ=@neural.init_standard())
  let _ = @neural.activation(h, @neural.act_relu())
  let nn = @neural.get_network(x)
  @neural.init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 2], [1.0, 2.0]))
  let (y, _params) = @neural.forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([3], shape)
}

///|
test "neural_forward_backward" {
  let x = @neural.input([2])
  let h = @neural.linear(x, 1, init_typ=@neural.init_standard())
  let _ = @neural.activation(h, @neural.act_sigmoid())
  let nn = @neural.get_network(x)
  @neural.init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 2], [0.5, -0.5]))
  let (y, _params) = @neural.forward(nn, inp)
  let (pri, adj) = @neural.backward(nn, y)
  @test.assert_eq(true, pri.length() >= 2)
  @test.assert_eq(true, adj.length() >= 2)
}

///|
test "neural_multi_layer" {
  let x = @neural.input([4])
  let h1 = @neural.linear(x, 8, init_typ=@neural.init_glorot_uniform())
  let a1 = @neural.activation(h1, @neural.act_tanh())
  let h2 = @neural.linear(a1, 4, init_typ=@neural.init_glorot_uniform())
  let _ = @neural.activation(h2, @neural.act_relu())
  let nn = @neural.get_network(x)
  @neural.init_network(nn)
  let inp = @algodiff.pack_arr(
    @ndarray.from_data([1, 4], [0.1, 0.2, -0.1, -0.2]),
  )
  let (y, _) = @neural.forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([4], shape)
}

///|
test "neural_dropout_layer" {
  let x = @neural.input([3])
  let _ = @neural.dropout(x, 0.5)
  let nn = @neural.get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_lambda_layer" {
  let x = @neural.input([3])
  let _ = @neural.lambda(x, fn(v) raise { @algodiff.relu(v) })
  let nn = @neural.get_network(x)
  @test.assert_eq(true, nn.topo.val.length() >= 2)
}

///|
test "neural_init_typ_standard" {
  let n = @neural.init_run(@neural.init_standard(), [3, 4])
  let s = @algodiff.shape(n)
  @test.assert_eq([3, 4], s)
}

///|
test "neural_init_typ_glorot" {
  let n = @neural.init_run(@neural.init_glorot_uniform(), [3, 4])
  let s = @algodiff.shape(n)
  @test.assert_eq([3, 4], s)
}

///|
test "neural_get_in_out_shape" {
  let x = @neural.input([5])
  let neuron = x.neuron.val
  let in_s = @neural.get_in_shape(neuron)
  let out_s = @neural.get_out_shape(neuron)
  @test.assert_eq([5], in_s)
  @test.assert_eq([5], out_s)
}

///|
test "neural_connect_shapes" {
  let x = @neural.input([2])
  let h = @neural.linear(x, 3, init_typ=@neural.init_standard())
  let nn = @neural.get_network(x)
  @neural.init_network(nn)
  let neuron = h.neuron.val
  @test.assert_eq([2], @neural.get_in_shape(neuron))
  @test.assert_eq([3], @neural.get_out_shape(neuron))
}

///|
test "neural_run_activation_relu" {
  let x = @algodiff.pack_flt(-1.0)
  let y = @neural.run_activation(x, @neural.act_relu())
  match y {
    F(v) => @test.assert_eq(true, v < 0.001)
    _ => @test.assert_eq(true, false)
  }
}

///|
test "neural_run_activation_sigmoid" {
  let x = @algodiff.pack_flt(-1.0)
  let y = @neural.run_activation(x, @neural.act_sigmoid())
  match y {
    F(v) => @test.assert_eq(true, (v - 0.2689).abs() < 0.01)
    _ => @test.assert_eq(true, false)
  }
}

///|
test "neural_run_activation_none" {
  let x = @algodiff.pack_flt(3.14)
  let y = @neural.run_activation(x, @neural.act_none())
  match y {
    F(v) => @test.assert_eq(3.14, v)
    _ => @test.assert_eq(true, false)
  }
}

// ===== Business Scenario Tests =====

///|
test "scenario: MLP forward pass with multiple layers" {
  // Build: input(4) -> linear(8) -> tanh -> linear(4) -> relu -> linear(1) -> sigmoid
  let x = @neural.input([4])
  let h1 = @neural.linear(x, 8, init_typ=@neural.init_he_normal())
  let a1 = @neural.activation(h1, @neural.act_tanh())
  let h2 = @neural.linear(a1, 4, init_typ=@neural.init_he_normal())
  let a2 = @neural.activation(h2, @neural.act_relu())
  let h3 = @neural.linear(a2, 1, init_typ=@neural.init_glorot_uniform())
  let _ = @neural.activation(h3, @neural.act_sigmoid())
  let nn = @neural.get_network(x)
  @neural.init_network(nn)
  let inp = @algodiff.pack_arr(
    @ndarray.from_data([1, 4], [0.1, -0.2, 0.3, -0.4]),
  )
  let (y, params) = @neural.forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([1], shape)
  @test.assert_eq(true, params.length() > 0)
}

///|
test "scenario: forward-backward gradient flow" {
  // Build: input(2) -> linear(3) -> relu -> linear(1)
  let x = @neural.input([2])
  let h = @neural.linear(x, 3, init_typ=@neural.init_standard())
  let a = @neural.activation(h, @neural.act_relu())
  let _ = @neural.linear(a, 1, init_typ=@neural.init_standard())
  let nn = @neural.get_network(x)
  @neural.init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 2], [1.0, -1.0]))
  let (y, _) = @neural.forward(nn, inp)
  let (pri, adj) = @neural.backward(nn, y)
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
    @neural.act_relu(),
    @neural.act_sigmoid(),
    @neural.act_tanh(),
    @neural.act_none(),
    @neural.act_softplus(),
    @neural.act_softsign(),
    @neural.act_relu6(),
  ]
  for act in activations {
    let x = @neural.input([3])
    let _ = @neural.activation(x, act)
    let nn = @neural.get_network(x)
    @neural.init_network(nn)
    let inp = @algodiff.pack_arr(@ndarray.from_data([1, 3], [0.5, -0.5, 1.0]))
    let (y, _) = @neural.forward(nn, inp)
    let shape = @algodiff.arr_shape(y)
    @test.assert_eq([3], shape)
  }
}

///|
test "scenario: different init strategies" {
  // Test all initialization strategies
  let inits = [
    @neural.init_standard(),
    @neural.init_glorot_uniform(),
    @neural.init_glorot_normal(),
    @neural.init_tanh(),
    @neural.init_lecun_normal(),
    @neural.init_he_normal(),
  ]
  for init_t in inits {
    let x = @neural.input([2])
    let _ = @neural.linear(x, 4, init_typ=init_t)
    let nn = @neural.get_network(x)
    @neural.init_network(nn)
    @test.assert_eq(true, nn.topo.val.length() >= 2)
  }
}

///|
test "scenario: dropout in training mode" {
  // Dropout should work in forward pass
  let x = @neural.input([4])
  let h = @neural.linear(x, 4, init_typ=@neural.init_standard())
  let _ = @neural.dropout(h, 0.3)
  let nn = @neural.get_network(x)
  @neural.init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 4], [1.0, 2.0, 3.0, 4.0]))
  let (y, _) = @neural.forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([4], shape)
}

///|
test "scenario: reshape and flatten in network" {
  // input(6) -> reshape(2,3) -> flatten -> linear(2)
  let x = @neural.input([6])
  let r = @neural.reshape(x, [2, 3])
  let f = @neural.flatten(r)
  let _ = @neural.linear(f, 2, init_typ=@neural.init_standard())
  let nn = @neural.get_network(x)
  @neural.init_network(nn)
  let inp = @algodiff.pack_arr(
    @ndarray.from_data([1, 6], [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]),
  )
  let (y, _) = @neural.forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([2], shape)
}

///|
test "scenario: lambda custom layer" {
  // Custom layer: x -> x^2 (element-wise square)
  let x = @neural.input([3])
  let _ = @neural.lambda(x, v => @algodiff.mul(v, v))
  let nn = @neural.get_network(x)
  @neural.init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 3], [2.0, 3.0, 4.0]))
  let (y, _) = @neural.forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([3], shape)
}

///|
test "scenario: dropout rate zero passes through" {
  // rate=0.0: bernoulli(p=1.0) mask is all ones, output equals input exactly.
  let x = @neural.input([4])
  let d = @neural.dropout(x, 0.0)
  let nn = @neural.get_network(d)
  let expected = @ndarray.from_data([1, 4], [1.0, 2.0, 3.0, 4.0])
  let (y, _) = @neural.forward(nn, @algodiff.pack_arr(expected))
  @test.assert_eq(
    true,
    @ndarray.approx_equal(@algodiff.unpack_arr(y), expected),
  )
}

///|
test "scenario: dropout training mode scaling" {
  // rate=0.5 inverted dropout: each element is either dropped (0) or kept
  // and scaled by 1/(1-rate) = 2, regardless of the random mask.
  let x = @neural.input([4])
  let d = @neural.dropout(x, 0.5)
  let nn = @neural.get_network(d)
  let inp_arr = @ndarray.from_data([1, 4], [1.0, 2.0, 3.0, 4.0])
  let (y, _) = @neural.forward(nn, @algodiff.pack_arr(inp_arr))
  @test.assert_eq([4], @algodiff.arr_shape(y))
  let ya = @algodiff.unpack_arr(y)
  // ya keeps the batch dimension, e.g. shape [1, 4]; build a full index.
  let dims = @ndarray.shape(ya)
  for i in 0..<4 {
    let idx = Array::make(dims.length(), 0)
    idx[dims.length() - 1] = i
    let v = @ndarray.get(ya, idx)
    let src = @ndarray.get(inp_arr, [0, i])
    @test.assert_eq(true, v.abs() < 1.0e-9 || (v - src * 2.0).abs() < 1.0e-9)
  }
}
