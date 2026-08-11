///|
fn _array_prod(arr : Array[Int]) -> Int {
  let mut p = 1
  for v in arr {
    p = p * v
  }
  p
}

///|
fn calc_fans(s : Array[Int]) -> (Double, Double) {
  let l = s.length()
  if l == 2 {
    (s[0].to_double(), s[1].to_double())
  } else if l > 2 && l < 6 {
    let mut receptive = 1
    let mut i = 0
    while i < l - 2 {
      receptive = receptive * s[i]
      i = i + 1
    }
    let fan_in = (s[l - 2] * receptive).to_double()
    let fan_out = (s[l - 1] * receptive).to_double()
    (fan_in, fan_out)
  } else {
    let prod = _array_prod(s)
    let io = prod.to_double().sqrt()
    (io, io)
  }
}

///|
pub fn init_run(typ : InitTyp, s : Array[Int]) -> @algodiff.T {
  let (fan_in, fan_out) = calc_fans(s)
  let r0 = (1.0 / fan_in).sqrt()
  let r1 = (6.0 / (fan_in + fan_out)).sqrt()
  let r2 = (2.0 / (fan_in + fan_out)).sqrt()
  let r3 = (2.0 / fan_in).sqrt()
  match typ {
    Uniform(a, b) => @algodiff.uniform_arr(a, b, s)
    Gaussian(mu, sigma) => @algodiff.gaussian_arr(mu, sigma, s)
    Standard => @algodiff.uniform_arr(-r0, r0, s)
    Tanh => @algodiff.uniform_arr(-r1, r1, s)
    GlorotUniform => @algodiff.uniform_arr(-r1, r1, s)
    GlorotNormal => @algodiff.gaussian_arr(0.0, r2, s)
    LecunNormal => @algodiff.gaussian_arr(0.0, r0, s)
    HeNormal => @algodiff.gaussian_arr(0.0, r3, s)
  }
}

///|
pub fn run_activation(
  x : @algodiff.T,
  typ : ActivationTyp,
) -> @algodiff.T raise {
  match typ {
    Elu =>
      @algodiff.add(
        @algodiff.relu(x),
        @algodiff.sub(
          @algodiff.exp(@algodiff.neg(@algodiff.relu(@algodiff.neg(x)))),
          @algodiff.pack_flt(1.0),
        ),
      )
    Relu => @algodiff.relu(x)
    Sigmoid => @algodiff.sigmoid(x)
    HardSigmoid => _hard_sigmoid(x)
    Softmax(a) => @algodiff.softmax(x, axis=a)
    Softplus => @algodiff.softplus(x)
    Softsign => @algodiff.softsign(x)
    Tanh => @algodiff.tanh(x)
    Relu6 => _relu6(x)
    LeakyRelu(a) =>
      @algodiff.sub(
        @algodiff.relu(x),
        @algodiff.mul_scalar(@algodiff.relu(@algodiff.neg(x)), a),
      )
    TRelu(a) => @algodiff.relu(@algodiff.sub(x, @algodiff.pack_flt(a)))
    None => x
  }
}

///|
fn _hard_sigmoid(x : @algodiff.T) -> @algodiff.T raise {
  let v = @algodiff.add_scalar(@algodiff.mul_scalar(x, 0.2), 0.5)
  _min_scalar(@algodiff.relu(v), 1.0)
}

///|
fn _relu6(x : @algodiff.T) -> @algodiff.T raise {
  _min_scalar(@algodiff.relu(x), 6.0)
}

///|
#warnings("-unused_error_type")
fn _min_scalar(x : @algodiff.T, s : Double) -> @algodiff.T raise {
  match x {
    F(v) => @algodiff.pack_flt(if v < s { v } else { s })
    Arr(arr) =>
      @algodiff.pack_arr(
        @ndarray.map_elem(arr, fn(v) { if v < s { v } else { s } }),
      )
    // min(x, s) = x - relu(x - s), differentiable through AD
    _ => @algodiff.sub(x, @algodiff.relu(@algodiff.sub(x, @algodiff.pack_flt(s))))
  }
}

///|
pub fn input_create(inputs : Array[Int]) -> InputNeuron {
  { in_shape: Ref(inputs.copy()), out_shape: Ref(inputs.copy()) }
}

///|
pub fn linear_create(outputs : Int, init_typ : InitTyp) -> LinearNeuron {
  {
    w: Ref(@algodiff.pack_arr(@ndarray.zeros([0, 0]))),
    b: Ref(@algodiff.pack_arr(@ndarray.zeros([0, 0]))),
    init_typ: Ref(init_typ),
    in_shape: Ref([0]),
    out_shape: Ref([outputs]),
  }
}

///|
pub fn linear_nobias_create(
  outputs : Int,
  init_typ : InitTyp,
) -> LinearNoBiasNeuron {
  {
    w: Ref(@algodiff.pack_arr(@ndarray.zeros([0, 0]))),
    init_typ: Ref(init_typ),
    in_shape: Ref([0]),
    out_shape: Ref([outputs]),
  }
}

///|
pub fn activation_create(typ : ActivationTyp) -> ActivationNeuron {
  { activation: typ, in_shape: Ref([]), out_shape: Ref([]) }
}

///|
pub fn flatten_create() -> FlattenNeuron {
  { in_shape: Ref([]), out_shape: Ref([]) }
}

///|
pub fn reshape_create(shape : Array[Int]) -> ReshapeNeuron {
  { in_shape: Ref([]), out_shape: Ref(shape.copy()) }
}

///|
pub fn dropout_create(rate : Double) -> DropoutNeuron {
  { rate, in_shape: Ref([]), out_shape: Ref([]) }
}

///|
pub fn add_create() -> AddNeuron {
  { in_shape: Ref([]), out_shape: Ref([]) }
}

///|
pub fn concatenate_create(axis : Int) -> ConcatenateNeuron {
  { axis, in_shape: Ref([]), out_shape: Ref([]) }
}

///|
pub fn lambda_create(f : (@algodiff.T) -> @algodiff.T raise) -> LambdaNeuron {
  { lambda: f, in_shape: Ref([]), out_shape: Ref([]) }
}

///|
pub fn get_in_shape(n : Neuron) -> Array[Int] {
  match n {
    Input(l) => l.in_shape.val
    Linear(l) => l.in_shape.val
    LinearNoBias(l) => l.in_shape.val
    Activation(l) => l.in_shape.val
    Flatten(l) => l.in_shape.val
    Reshape(l) => l.in_shape.val
    Dropout(l) => l.in_shape.val
    Add(l) => l.in_shape.val
    Concatenate(l) => l.in_shape.val
    Lambda(l) => l.in_shape.val
  }
}

///|
pub fn get_out_shape(n : Neuron) -> Array[Int] {
  match n {
    Input(l) => l.out_shape.val
    Linear(l) => l.out_shape.val
    LinearNoBias(l) => l.out_shape.val
    Activation(l) => l.out_shape.val
    Flatten(l) => l.out_shape.val
    Reshape(l) => l.out_shape.val
    Dropout(l) => l.out_shape.val
    Add(l) => l.out_shape.val
    Concatenate(l) => l.out_shape.val
    Lambda(l) => l.out_shape.val
  }
}

///|
pub fn connect(out_shapes : Array[Array[Int]], n : Neuron) -> Unit {
  match n {
    Input(_) => ()
    Linear(l) => l.in_shape.val = [out_shapes[0][0]]
    LinearNoBias(l) => l.in_shape.val = [out_shapes[0][0]]
    Activation(l) => {
      l.in_shape.val = out_shapes[0].copy()
      l.out_shape.val = out_shapes[0].copy()
    }
    Flatten(l) => {
      l.in_shape.val = out_shapes[0].copy()
      let total = _array_prod(out_shapes[0])
      l.out_shape.val = [total]
    }
    Reshape(l) => l.in_shape.val = out_shapes[0].copy()
    Dropout(l) => {
      l.in_shape.val = out_shapes[0].copy()
      l.out_shape.val = out_shapes[0].copy()
    }
    Add(l) => {
      l.in_shape.val = out_shapes[0].copy()
      l.out_shape.val = out_shapes[0].copy()
    }
    Concatenate(l) => {
      l.in_shape.val = out_shapes[0].copy()
      let axis = l.axis
      let mut total = 0
      for s in out_shapes {
        total = total + s[axis]
      }
      let out = out_shapes[0].copy()
      out[axis] = total
      l.out_shape.val = out
    }
    Lambda(l) => {
      l.in_shape.val = out_shapes[0].copy()
      l.out_shape.val = out_shapes[0].copy()
    }
  }
}

///|
pub fn init_neuron(n : Neuron) -> Unit {
  match n {
    Linear(l) => {
      let m = l.in_shape.val[0]
      let n = l.out_shape.val[0]
      l.w.val = init_run(l.init_typ.val, [m, n])
      l.b.val = @algodiff.pack_arr(@ndarray.zeros([1, n]))
    }
    LinearNoBias(l) => {
      let m = l.in_shape.val[0]
      let n = l.out_shape.val[0]
      l.w.val = init_run(l.init_typ.val, [m, n])
    }
    _ => ()
  }
}

///|
pub fn mktag(t : Int, n : Neuron) -> Unit {
  match n {
    Linear(l) => {
      l.w.val = @algodiff.make_reverse(l.w.val, t)
      l.b.val = @algodiff.make_reverse(l.b.val, t)
    }
    LinearNoBias(l) => l.w.val = @algodiff.make_reverse(l.w.val, t)
    _ => ()
  }
}

///|
pub fn mkpar(n : Neuron) -> Array[@algodiff.T] {
  match n {
    Linear(l) => [l.w.val, l.b.val]
    LinearNoBias(l) => [l.w.val]
    _ => []
  }
}

///|
pub fn mkpri(n : Neuron) -> Array[@algodiff.T] {
  match n {
    Linear(l) => [@algodiff.primal(l.w.val), @algodiff.primal(l.b.val)]
    LinearNoBias(l) => [@algodiff.primal(l.w.val)]
    _ => []
  }
}

///|
pub fn mkadj(n : Neuron) -> Array[@algodiff.T] raise {
  match n {
    Linear(l) => [@algodiff.adjval(l.w.val), @algodiff.adjval(l.b.val)]
    LinearNoBias(l) => [@algodiff.adjval(l.w.val)]
    _ => []
  }
}

///|
pub fn update_neuron(n : Neuron, u : Array[@algodiff.T]) -> Unit {
  match n {
    Linear(l) => {
      l.w.val = @algodiff.primal_(u[0])
      l.b.val = @algodiff.primal_(u[1])
    }
    LinearNoBias(l) => l.w.val = @algodiff.primal_(u[0])
    _ => ()
  }
}

///|
pub fn run_neuron(input : Array[@algodiff.T], n : Neuron) -> @algodiff.T raise {
  match n {
    Input(_) => input[0]
    Linear(l) => @algodiff.add(@algodiff.matmul(input[0], l.w.val), l.b.val)
    LinearNoBias(l) => @algodiff.matmul(input[0], l.w.val)
    Activation(l) => run_activation(input[0], l.activation)
    Flatten(_) => @algodiff.flatten(input[0])
    Reshape(l) => @algodiff.reshape(input[0], l.out_shape.val)
    Dropout(_) => input[0]
    Add(_) => {
      let mut acc = input[0]
      for i in 1..<input.length() {
        acc = @algodiff.add(acc, input[i])
      }
      acc
    }
    Concatenate(l) => {
      let mut acc = input[0]
      for i in 1..<input.length() {
        acc = @algodiff.concatenate([acc, input[i]], axis=l.axis)
      }
      acc
    }
    Lambda(l) => (l.lambda)(input[0])
  }
}
