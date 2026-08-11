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
  size : Ref[Int]
  roots : Ref[Array[Node]]
  outputs : Ref[Array[Node]]
  topo : Ref[Array[Node]]
}

///|
/// Create a new network.
pub fn make_network(
  size : Int,
  roots : Array[Node],
  topo : Array[Node],
  nnid? : String = "Graphical network",
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
pub fn make_node(
  prev : Array[Node],
  next : Array[Node],
  neuron : Neuron,
  output : @algodiff.T?,
  network : Network,
  name? : String = "",
  train? : Bool = false,
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
pub fn get_roots(nn : Network) -> Array[Node] {
  nn.roots.val
}

///|
pub fn get_outputs(nn : Network) -> Array[Node] {
  nn.outputs.val
}

///|
pub fn get_network(n : Node) -> Network {
  n.network.val
}

///|
pub fn collect_output(nodes : Array[Node]) -> Array[@algodiff.T] {
  let result = Array::make(nodes.length(), @algodiff.pack_flt(0.0))
  for i in 0..<nodes.length() {
    match nodes[i].output.val {
      Some(o) => result[i] = o
      None => abort("collect_output: node has no output")
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
pub fn connect_to_parents(parents : Array[Node], child : Node) -> Unit {
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
pub fn add_node(
  nn : Network,
  parents : Array[Node],
  child : Node,
  act_typ? : ActivationTyp? = None,
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
pub fn init_network(nn : Network) -> Unit {
  for n in nn.topo.val {
    init_neuron(n.neuron.val)
  }
}

///|
pub fn mktag_network(t : Int, nn : Network) -> Unit {
  for n in nn.topo.val {
    mktag(t, n.neuron.val)
  }
}

///|
pub fn mkpar_network(nn : Network) -> Array[Array[@algodiff.T]] {
  Array::makei(nn.topo.val.length(), fn(i) { mkpar(nn.topo.val[i].neuron.val) })
}

///|
pub fn mkpri_network(nn : Network) -> Array[Array[@algodiff.T]] {
  Array::makei(nn.topo.val.length(), fn(i) { mkpri(nn.topo.val[i].neuron.val) })
}

///|
pub fn mkadj_network(nn : Network) -> Array[Array[@algodiff.T]] raise {
  Array::makei(nn.topo.val.length(), fn(i) raise {
    mkadj(nn.topo.val[i].neuron.val)
  })
}

///|
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
    let output = run_neuron(input, n.neuron.val)
    n.output.val = Some(output)
  }
  let sink = nn.topo.val[nn.topo.val.length() - 1]
  match sink.output.val {
    Some(o) => o
    None => abort("run: sink node has no output")
  }
}

///|
pub fn forward(
  nn : Network,
  x : @algodiff.T,
) -> (@algodiff.T, Array[Array[@algodiff.T]]) raise {
  mktag_network(@algodiff.tag(), nn)
  let y = run(x, nn)
  (y, mkpar_network(nn))
}

///|
pub fn backward(
  nn : Network,
  y : @algodiff.T,
) -> (Array[Array[@algodiff.T]], Array[Array[@algodiff.T]]) raise {
  @algodiff.reverse_prop(@algodiff.pack_flt(1.0), y)
  (mkpri_network(nn), mkadj_network(nn))
}

///|
#warnings("-unused_error_type")
pub fn input(inputs : Array[Int]) -> Node raise {
  let neuron = Input(input_create(inputs))
  let nn = make_network(0, [], [])
  let n = make_node([], [], neuron, None, nn, name="input_0")
  nn.roots.val = [n]
  nn.topo.val = [n]
  n
}

///|
pub fn linear(
  input_node : Node,
  outputs : Int,
  init_typ? : InitTyp = Standard,
  act_typ? : ActivationTyp? = None,
) -> Node raise {
  let neuron = Linear(linear_create(outputs, init_typ))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n, act_typ~)
}

///|
pub fn linear_nobias(
  input_node : Node,
  outputs : Int,
  init_typ? : InitTyp = Standard,
  act_typ? : ActivationTyp? = None,
) -> Node raise {
  let neuron = LinearNoBias(linear_nobias_create(outputs, init_typ))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n, act_typ~)
}

///|
pub fn activation(input_node : Node, typ : ActivationTyp) -> Node raise {
  let neuron = Activation(activation_create(typ))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n)
}

///|
pub fn flatten(input_node : Node) -> Node raise {
  let neuron = Flatten(flatten_create())
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n)
}

///|
pub fn reshape(input_node : Node, shape : Array[Int]) -> Node raise {
  let neuron = Reshape(reshape_create(shape))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n)
}

///|
pub fn dropout(input_node : Node, rate : Double) -> Node raise {
  let neuron = Dropout(dropout_create(rate))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn, train=true)
  add_node(nn, [input_node], n)
}

///|
pub fn lambda(
  input_node : Node,
  f : (@algodiff.T) -> @algodiff.T raise,
) -> Node raise {
  let neuron = Lambda(lambda_create(f))
  let nn = get_network(input_node)
  let n = make_node([], [], neuron, None, nn)
  add_node(nn, [input_node], n)
}
