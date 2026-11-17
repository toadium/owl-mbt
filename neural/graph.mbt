///|
/// Graph node: a neuron in the network DAG.
pub struct Node {
  name : Ref[String]
  prev : Ref[Array[Node]]
  next : Ref[Array[Node]]
  neuron : Ref[Neuron]
  output : Ref[@algodiff.T?]
  network : Ref[Network]
  train : Ref[Bool]
}

///|
/// Graph network: the full DAG.
pub struct Network {
  nnid : Ref[String]
  size : Ref[Int32]
  roots : Ref[Array[Node]]
  outputs : Ref[Array[Node]]
  topo : Ref[Array[Node]]
}

///|
/// Create a new network.
fn make_network(
  size : Int32,
  roots : Array[Node],
  topo : Array[Node],
  nnid~ : String = "Graphical network",
) -> Network {
  {
    nnid: Ref(nnid),
    size: Ref(size),
    roots: Ref(roots),
    outputs: Ref([]),
    topo: Ref(topo),
  }
}

///|
/// Create a new node.
fn make_node(
  prev : Array[Node],
  next : Array[Node],
  neuron : Neuron,
  output : @algodiff.T?,
  network : Network,
  name~ : String = "",
  train~ : Bool = false,
) -> Node {
  let n : Node = {
    name: Ref(
      if name == "" {
        "\{to_name(neuron)}_\{network.size.val}"
      } else {
        name
      },
    ),
    prev: Ref(prev),
    next: Ref(next),
    neuron: Ref(neuron),
    output: Ref(output),
    network: Ref(network),
    train: Ref(train),
  }
  n
}

///|
/// 返回神经元类型对应的节点名称前缀。
pub fn to_name(n : Neuron) -> String {
  match n {
    Input(_) => "input"
    Linear(_) => "linear"
    LinearNoBias(_) => "linear_nobias"
    Activation(_) => "activation"
    Flatten(_) => "flatten"
    Reshape(_) => "reshape"
    Dropout(_) => "dropout"
    Add(_) => "add"
    Concatenate(_) => "concatenate"
    Lambda(_) => "lambda"
  }
}

///|
/// 获取网络的根节点（输入节点）数组。
pub fn get_roots(nn : Network) -> Array[Node] {
  nn.roots.val
}

///|
/// 获取网络的输出节点数组。
pub fn get_outputs(nn : Network) -> Array[Node] {
  nn.outputs.val
}

///|
/// 获取节点所属的网络。
pub fn get_network(n : Node) -> Network {
  n.network.val
}

///|
/// 收集各节点输出值；节点尚无输出时抛出异常。
pub fn collect_output(nodes : Array[Node]) -> Array[@algodiff.T] raise {
  let result = Array::make(nodes.length(), @algodiff.pack_flt(0.0))
  for i in 0..<nodes.length() {
    match nodes[i].output.val {
      Some(o) => result[i] = o
      None =>
        raise @core.OwlError::InvalidArgument(
          "collect_output: node has no output",
        )
    }
  }
  result
}

///|
/// Check if a node is in the array by name comparison.
/// Note: relies on unique node names; potential issue if names conflict.
fn _contains_node(arr : Array[Node], name : String) -> Bool {
  let mut found = false
  for n in arr {
    if n.name.val == name {
      found = true
    }
  }
  found
}

///|
fn connect_pair(prev : Node, next : Node) -> Unit {
  if !_contains_node(next.prev.val, prev.name.val) {
    next.prev.val.push(prev)
  }
  if !_contains_node(prev.next.val, next.name.val) {
    prev.next.val.push(next)
  }
}

///|
fn connect_to_parents(parents : Array[Node], child : Node) -> Unit {
  if parents.length() > 0 {
    let out_shapes = Array::makei(parents.length(), fn(i) {
      get_out_shape(parents[i].neuron.val)
    })
    connect(out_shapes, child.neuron.val)
  }
  for p in parents {
    connect_pair(p, child)
  }
}

///|
/// 向网络添加节点并连接到父节点；提供 act_typ 时自动追加激活节点。
pub fn add_node(
  nn : Network,
  parents : Array[Node],
  child : Node,
  act_typ~ : ActivationTyp? = None,
) -> Node raise {
  nn.size.val = nn.size.val + 1
  connect_to_parents(parents, child)
  nn.topo.val.push(child)
  child.network.val = nn
  match act_typ {
    Some(act) => {
      let neuron = Activation(activation_create(act))
      let child_of_child = make_node([], [], neuron, None, nn)
      add_node(nn, [child], child_of_child)
    }
    None => child
  }
}

///|
/// 初始化网络中所有神经元的参数（按输入形状分配权重）。
pub fn init_network(nn : Network) -> Unit {
  for n in nn.topo.val {
    init_neuron(n.neuron.val)
  }
}

///|
fn mktag_network(t : Int32, nn : Network) -> Unit {
  for n in nn.topo.val {
    mktag(t, n.neuron.val)
  }
}

///|
fn mkpar_network(nn : Network) -> Array[Array[@algodiff.T]] {
  Array::makei(nn.topo.val.length(), fn(i) { mkpar(nn.topo.val[i].neuron.val) })
}

///|
fn mkpri_network(nn : Network) -> Array[Array[@algodiff.T]] {
  Array::makei(nn.topo.val.length(), fn(i) { mkpri(nn.topo.val[i].neuron.val) })
}

///|
fn mkadj_network(nn : Network) -> Array[Array[@algodiff.T]] raise {
  Array::makei(nn.topo.val.length(), fn(i) raise {
    mkadj(nn.topo.val[i].neuron.val)
  })
}

///|
/// 用参数数组更新网络中各神经元的参数。
pub fn update_network(nn : Network, us : Array[Array[@algodiff.T]]) -> Unit {
  for i in 0..<nn.topo.val.length() {
    update_neuron(nn.topo.val[i].neuron.val, us[i])
  }
}

///|
/// Run forward pass. Note: assumes single-input single-output network.
/// All Input nodes are bound to the same input x.
pub fn run(x : @algodiff.T, nn : Network) -> @algodiff.T raise {
  for n in nn.topo.val {
    let input = match n.neuron.val {
      Input(_) => [x]
      _ => collect_output(n.prev.val)
    }
    let output = run_neuron(input, n.neuron.val, train=n.train.val)
    n.output.val = Some(output)
  }
  let sink = nn.topo.val[nn.topo.val.length() - 1]
  match sink.output.val {
    Some(o) => o
    None =>
      raise @core.OwlError::InvalidArgument("run: sink node has no output")
  }
}

///|
/// 前向传播：打标后运行网络，返回输出值与各层参数。
pub fn forward(
  nn : Network,
  x : @algodiff.T,
) -> (@algodiff.T, Array[Array[@algodiff.T]]) raise {
  mktag_network(@algodiff.tag(), nn)
  let y = run(x, nn)
  (y, mkpar_network(nn))
}

///|
/// Backward pass: propagate gradient from output y through the network.
/// Note: uses scalar 1.0 as initial adjoint, assuming y is a scalar.
/// For array outputs, the initial gradient should be a same-shaped ones array.
pub fn backward(
  nn : Network,
  y : @algodiff.T,
) -> (Array[Array[@algodiff.T]], Array[Array[@algodiff.T]]) raise {
  @algodiff.reverse_prop(@algodiff.pack_flt(1.0), y)
  (mkpri_network(nn), mkadj_network(nn))
}

///|
/// 创建输入节点并构建新网络（inputs 为输入形状）。
#warnings("-unused_error_type")
pub fn input(inputs : Array[Int32]) -> Node raise {
  let neuron = Input(input_create(inputs))
  let nn = make_network(0, [], [])
  let n = make_node([], [], neuron, None, nn, name="input_0")
  nn.roots.val = [n]
  nn.topo.val = [n]
  n
}

///|
/// 创建线性层节点（in_shape→outputs，含偏置）。
pub fn linear(
  input_node : Node,
  outputs : Int32,
  init_typ~ : InitTyp = Standard,
  act_typ~ : ActivationTyp? = None,
) -> Node raise {
  let neuron = Linear(linear_create(outputs, init_typ))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n, act_typ~)
}

///|
/// 创建无偏置线性层节点。
pub fn linear_nobias(
  input_node : Node,
  outputs : Int32,
  init_typ~ : InitTyp = Standard,
  act_typ~ : ActivationTyp? = None,
) -> Node raise {
  let neuron = LinearNoBias(linear_nobias_create(outputs, init_typ))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n, act_typ~)
}

///|
/// 在节点后追加激活层节点。
pub fn activation(input_node : Node, typ : ActivationTyp) -> Node raise {
  let neuron = Activation(activation_create(typ))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n)
}

///|
/// 在节点后追加展平层节点。
pub fn flatten(input_node : Node) -> Node raise {
  let neuron = Flatten(flatten_create())
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n)
}

///|
/// 在节点后追加形状重塑层节点。
pub fn reshape(input_node : Node, shape : Array[Int32]) -> Node raise {
  let neuron = Reshape(reshape_create(shape))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n)
}

///|
/// 在节点后追加 Dropout 层节点（rate 为丢弃率）。
pub fn dropout(input_node : Node, rate : Double) -> Node raise {
  let neuron = Dropout(dropout_create(rate))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn, train=true)
  add_node(nn, [input_node], n)
}

///|
/// 在节点后追加自定义函数层节点。
pub fn lambda(
  input_node : Node,
  f : (@algodiff.T) -> @algodiff.T raise,
) -> Node raise {
  let neuron = Lambda(lambda_create(f))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n)
}
