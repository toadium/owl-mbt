///|
/// Coverage: calc_fans 2D case
test "neuron_wb: calc_fans 2D" {
  let (fi, fo) = calc_fans([3, 4])
  @test.assert_eq(3.0, fi)
  @test.assert_eq(4.0, fo)
}

///|
/// Coverage: calc_fans 3-5D case (conv kernel)
test "neuron_wb: calc_fans 3D conv kernel" {
  let (fi, fo) = calc_fans([3, 3, 4])
  @test.assert_eq(9.0, fi)
  @test.assert_eq(12.0, fo)
}

///|
/// Coverage: calc_fans 4D case (conv kernel with channels)
test "neuron_wb: calc_fans 4D conv kernel" {
  let (fi, fo) = calc_fans([3, 3, 2, 4])
  @test.assert_eq(18.0, fi)
  @test.assert_eq(36.0, fo)
}

///|
/// Coverage: calc_fans 1D case (fallback)
test "neuron_wb: calc_fans 1D fallback" {
  let (fi, fo) = calc_fans([9])
  @test.assert_eq(3.0, fi)
  @test.assert_eq(3.0, fo)
}

///|
/// Coverage: calc_fans 6D case (fallback)
test "neuron_wb: calc_fans 6D fallback" {
  let (fi, _fo) = calc_fans([2, 2, 2, 2, 2, 2])
  @test.assert_eq(true, fi > 0.0)
}

///|
/// Coverage: _array_prod
test "neuron_wb: _array_prod" {
  @test.assert_eq(24, _array_prod([2, 3, 4]))
  @test.assert_eq(1, _array_prod([]))
  @test.assert_eq(7, _array_prod([7]))
}

///|
/// Coverage: run_activation Elu
test "neuron_wb: run_activation elu" {
  let x = @algodiff.pack_flt(0.0)
  let y = run_activation(x, act_elu())
  match y {
    F(v) => @test.assert_eq(true, v.abs() < 0.001)
    _ => @test.assert_eq(true, false)
  }
}

///|
/// Coverage: run_activation HardSigmoid (scalar)
test "neuron_wb: run_activation hard_sigmoid scalar" {
  let x = @algodiff.pack_flt(10.0)
  let y = run_activation(x, act_hard_sigmoid())
  match y {
    F(v) => @test.assert_eq(1.0, v)
    _ => @test.assert_eq(true, false)
  }
}

///|
/// Coverage: run_activation HardSigmoid (array) - exercises _min_scalar Arr branch
test "neuron_wb: run_activation hard_sigmoid array" {
  let x = @algodiff.pack_arr(@ndarray.from_data([1, 2], [10.0, -10.0]))
  let y = run_activation(x, act_hard_sigmoid())
  let s = @algodiff.arr_shape(y)
  @test.assert_eq([2], s)
}

///|
/// Coverage: run_activation Relu6 (scalar)
test "neuron_wb: run_activation relu6 scalar" {
  let x = @algodiff.pack_flt(10.0)
  let y = run_activation(x, act_relu6())
  match y {
    F(v) => @test.assert_eq(6.0, v)
    _ => @test.assert_eq(true, false)
  }
}

///|
/// Coverage: run_activation Relu6 (array) - exercises _min_scalar Arr branch
test "neuron_wb: run_activation relu6 array" {
  let x = @algodiff.pack_arr(@ndarray.from_data([1, 2], [10.0, 3.0]))
  let y = run_activation(x, act_relu6())
  let s = @algodiff.arr_shape(y)
  @test.assert_eq([2], s)
}

///|
/// Coverage: run_activation Softmax
test "neuron_wb: run_activation softmax" {
  let x = @algodiff.pack_arr(@ndarray.from_data([1, 2], [1.0, 2.0]))
  let y = run_activation(x, act_softmax(0))
  let s = @algodiff.arr_shape(y)
  @test.assert_eq([2], s)
}

///|
/// Coverage: run_activation Softplus
test "neuron_wb: run_activation softplus" {
  let x = @algodiff.pack_flt(0.0)
  let y = run_activation(x, act_softplus())
  match y {
    F(v) => @test.assert_eq(true, (v - 0.6931).abs() < 0.01)
    _ => @test.assert_eq(true, false)
  }
}

///|
/// Coverage: run_activation Softsign
test "neuron_wb: run_activation softsign" {
  let x = @algodiff.pack_flt(0.0)
  let y = run_activation(x, act_softsign())
  match y {
    F(v) => @test.assert_eq(0.0, v)
    _ => @test.assert_eq(true, false)
  }
}

///|
/// Coverage: run_activation Tanh
test "neuron_wb: run_activation tanh" {
  let x = @algodiff.pack_flt(0.0)
  let y = run_activation(x, act_tanh())
  match y {
    F(v) => @test.assert_eq(0.0, v)
    _ => @test.assert_eq(true, false)
  }
}

///|
/// Coverage: run_activation LeakyRelu
test "neuron_wb: run_activation leaky_relu" {
  let x = @algodiff.pack_flt(-1.0)
  let y = run_activation(x, act_leaky_relu(0.1))
  match y {
    F(v) => @test.assert_eq(true, (v - -0.1).abs() < 0.001)
    _ => @test.assert_eq(true, false)
  }
}

///|
/// Coverage: run_activation TRelu
test "neuron_wb: run_activation trelu" {
  let x = @algodiff.pack_flt(5.0)
  let y = run_activation(x, act_trelu(3.0))
  match y {
    F(v) => @test.assert_eq(2.0, v)
    _ => @test.assert_eq(true, false)
  }
}

///|
/// Coverage: init_run with Uniform
test "neuron_wb: init_run uniform" {
  let n = init_run(init_uniform(-1.0, 1.0), [2, 3])
  let s = @algodiff.shape(n)
  @test.assert_eq([2, 3], s)
}

///|
/// Coverage: init_run with Gaussian
test "neuron_wb: init_run gaussian" {
  let n = init_run(init_gaussian(0.0, 1.0), [2, 3])
  let s = @algodiff.shape(n)
  @test.assert_eq([2, 3], s)
}

///|
/// Coverage: init_run with Tanh init
test "neuron_wb: init_run tanh" {
  let n = init_run(init_tanh(), [2, 3])
  let s = @algodiff.shape(n)
  @test.assert_eq([2, 3], s)
}

///|
/// Coverage: init_run with GlorotNormal
test "neuron_wb: init_run glorot_normal" {
  let n = init_run(init_glorot_normal(), [2, 3])
  let s = @algodiff.shape(n)
  @test.assert_eq([2, 3], s)
}

///|
/// Coverage: init_run with LecunNormal
test "neuron_wb: init_run lecun_normal" {
  let n = init_run(init_lecun_normal(), [2, 3])
  let s = @algodiff.shape(n)
  @test.assert_eq([2, 3], s)
}

///|
/// Coverage: init_run with HeNormal
test "neuron_wb: init_run he_normal" {
  let n = init_run(init_he_normal(), [2, 3])
  let s = @algodiff.shape(n)
  @test.assert_eq([2, 3], s)
}

///|
/// Coverage: run_neuron with LinearNoBias
test "neuron_wb: run_neuron linear_nobias" {
  let x = input([2])
  let _ = linear_nobias(x, 3, init_typ=init_standard())
  let nn = get_network(x)
  init_network(nn)
  let inp = @algodiff.pack_arr(@ndarray.from_data([1, 2], [1.0, 2.0]))
  let (y, _params) = forward(nn, inp)
  let shape = @algodiff.arr_shape(y)
  @test.assert_eq([3], shape)
}

///|
/// Coverage: run_neuron with Add (direct construction)
test "neuron_wb: run_neuron add" {
  let n = Add(add_create())
  let inp1 = @algodiff.pack_arr(@ndarray.from_data([1, 2], [1.0, 2.0]))
  let inp2 = @algodiff.pack_arr(@ndarray.from_data([1, 2], [3.0, 4.0]))
  let y = run_neuron([inp1, inp2], n)
  let s = @algodiff.arr_shape(y)
  @test.assert_eq([2], s)
}

///|
/// Coverage: run_neuron with Concatenate (direct construction)
test "neuron_wb: run_neuron concatenate" {
  let n = Concatenate(concatenate_create(1))
  let inp1 = @algodiff.pack_arr(@ndarray.from_data([1, 2], [1.0, 2.0]))
  let inp2 = @algodiff.pack_arr(@ndarray.from_data([1, 2], [3.0, 4.0]))
  let y = run_neuron([inp1, inp2], n)
  let s = @algodiff.arr_shape(y)
  @test.assert_eq([4], s)
}

///|
/// Coverage: connect with Concatenate
test "neuron_wb: connect concatenate" {
  let shapes = [[1, 2], [1, 3]]
  let n = Concatenate(concatenate_create(1))
  connect(shapes, n)
  @test.assert_eq([1, 5], get_out_shape(n))
}

///|
/// Coverage: connect with Add
test "neuron_wb: connect add" {
  let shapes = [[1, 3]]
  let n = Add(add_create())
  connect(shapes, n)
  @test.assert_eq([1, 3], get_out_shape(n))
}

///|
/// Coverage: connect with Flatten
test "neuron_wb: connect flatten" {
  let shapes = [[2, 3]]
  let n = Flatten(flatten_create())
  connect(shapes, n)
  @test.assert_eq([6], get_out_shape(n))
}

///|
/// Coverage: connect with Input (no-op)
test "neuron_wb: connect input" {
  let shapes = [[3]]
  let n = Input(input_create([3]))
  connect(shapes, n)
  @test.assert_eq([3], get_in_shape(n))
}

///|
/// Coverage: update_neuron with LinearNoBias
test "neuron_wb: update_neuron linear_nobias" {
  let neuron = LinearNoBias(linear_nobias_create(2, init_standard()))
  let new_w = @algodiff.pack_arr(
    @ndarray.from_data([2, 2], [1.0, 2.0, 3.0, 4.0]),
  )
  update_neuron(neuron, [new_w])
  @test.assert_eq(true, true)
}

///|
/// Coverage: update_neuron with non-Linear (no-op)
test "neuron_wb: update_neuron activation noop" {
  let neuron = Activation(activation_create(act_relu()))
  update_neuron(neuron, [])
  @test.assert_eq(true, true)
}

///|
/// Coverage: init_neuron with non-Linear (no-op)
test "neuron_wb: init_neuron activation noop" {
  let neuron = Activation(activation_create(act_relu()))
  init_neuron(neuron)
  @test.assert_eq(true, true)
}

///|
/// Coverage: get_in_shape/get_out_shape for all neuron types
test "neuron_wb: shapes all types" {
  let inp = Input(input_create([3]))
  @test.assert_eq([3], get_in_shape(inp))
  @test.assert_eq([3], get_out_shape(inp))

  let lin = Linear(linear_create(2, init_standard()))
  @test.assert_eq([0], get_in_shape(lin))
  @test.assert_eq([2], get_out_shape(lin))

  let lnb = LinearNoBias(linear_nobias_create(2, init_standard()))
  @test.assert_eq([0], get_in_shape(lnb))
  @test.assert_eq([2], get_out_shape(lnb))

  let act = Activation(activation_create(act_relu()))
  @test.assert_eq(0, get_in_shape(act).length())
  @test.assert_eq(0, get_out_shape(act).length())

  let flat = Flatten(flatten_create())
  @test.assert_eq(0, get_in_shape(flat).length())
  @test.assert_eq(0, get_out_shape(flat).length())

  let res = Reshape(reshape_create([2, 3]))
  @test.assert_eq(0, get_in_shape(res).length())
  @test.assert_eq([2, 3], get_out_shape(res))

  let drop = Dropout(dropout_create(0.5))
  @test.assert_eq(0, get_in_shape(drop).length())
  @test.assert_eq(0, get_out_shape(drop).length())

  let add = Add(add_create())
  @test.assert_eq(0, get_in_shape(add).length())
  @test.assert_eq(0, get_out_shape(add).length())

  let concat = Concatenate(concatenate_create(0))
  @test.assert_eq(0, get_in_shape(concat).length())
  @test.assert_eq(0, get_out_shape(concat).length())

  let lam = Lambda(lambda_create(fn(v) { v }))
  @test.assert_eq(0, get_in_shape(lam).length())
  @test.assert_eq(0, get_out_shape(lam).length())
}
