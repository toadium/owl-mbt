///|
/// A node in the computation graph.
pub struct Node {
  id : Ref[Int]
  name : Ref[String]
  op : Ref[Op]
  prev : Ref[Array[Node]]
  next : Ref[Array[Node]]
  shape : Ref[Array[Array[Int]?]]
  value : Ref[@ndarray.Ndarray?]
  freeze : Ref[Bool]
  reuse : Ref[Bool]
  state : Ref[State]
  is_assigned : Ref[Bool]
}

///|
/// The computation graph.
pub struct Graph {
  name : Ref[String]
  input : Ref[Array[Node]]
  output : Ref[Array[Node]]
  nodes : Ref[Array[Node]]
  counter : Ref[Int]
}

///|
/// Create a new empty graph.
pub fn make_graph(name : String) -> Graph {
  {
    name: Ref(name),
    input: Ref([]),
    output: Ref([]),
    nodes: Ref([]),
    counter: Ref(0),
  }
}

///|
/// Create a new node in the graph.
pub fn make_node(graph : Graph, op : Op, name : String) -> Node {
  let id = graph.counter.val
  graph.counter.val = id + 1
  let node : Node = {
    id: Ref(id),
    name: Ref(name),
    op: Ref(op),
    prev: Ref([]),
    next: Ref([]),
    shape: Ref([None]),
    value: Ref(None),
    freeze: Ref(false),
    reuse: Ref(false),
    state: Ref(Invalid),
    is_assigned: Ref(false),
  }
  graph.nodes.val.push(node)
  node
}

///|
/// Get the ID of a node.
pub fn node_id(n : Node) -> Int {
  n.id.val
}

///|
/// Get the name of a node.
pub fn node_name(n : Node) -> String {
  n.name.val
}

///|
/// Get the op of a node.
pub fn node_op(n : Node) -> Op {
  n.op.val
}

///|
/// Connect nodes: parent -> child.
/// Note: does not check for duplicate edges. Calling connect(p, c) multiple
/// times will add redundant edges, which may cause redundant computation
/// or incorrect results in binary ops that index into inputs by position.
pub fn connect(parent : Node, child : Node) -> Unit {
  child.prev.val.push(parent)
  parent.next.val.push(child)
}

///|
/// Set graph inputs.
pub fn set_inputs(graph : Graph, inputs : Array[Node]) -> Unit {
  graph.input.val = inputs
}

///|
/// Set graph outputs.
pub fn set_outputs(graph : Graph, outputs : Array[Node]) -> Unit {
  graph.output.val = outputs
}

///|
/// Get graph inputs.
pub fn get_inputs(graph : Graph) -> Array[Node] {
  graph.input.val
}

///|
/// Get graph outputs.
pub fn get_outputs(graph : Graph) -> Array[Node] {
  graph.output.val
}

///|
/// Get all nodes in the graph.
pub fn get_nodes(graph : Graph) -> Array[Node] {
  graph.nodes.val
}

///|
/// Set a node's value.
pub fn set_node_value(node : Node, v : @ndarray.Ndarray) -> Unit {
  node.value.val = Some(v)
  node.is_assigned.val = true
  node.state.val = Valid
}

///|
/// Get a node's value.
pub fn get_node_value(node : Node) -> @ndarray.Ndarray raise {
  match node.value.val {
    Some(v) => v
    None => raise @types.OwlError::InvalidArgument("get_node_value: node has no value")
  }
}

///|
/// Check if a node is assigned.
pub fn is_assigned(node : Node) -> Bool {
  node.is_assigned.val
}

///|
/// Set a node's shape.
pub fn set_node_shape(node : Node, shape : Array[Array[Int]?]) -> Unit {
  node.shape.val = shape
}

///|
/// Get a node's shape.
pub fn get_node_shape(node : Node) -> Array[Array[Int]?] {
  node.shape.val
}

///|
/// Collect all ancestor nodes of the given nodes in topological order.
/// Uses recursive post-order DFS: parents are fully processed before the node.
fn collect_ancestors(nodes : Array[Node], total_nodes : Int) -> Array[Node] {
  let visited = Array::make(total_nodes, false)
  let result : Array[Node] = []
  fn _dfs(n : Node) -> Unit {
    let nid = n.id.val
    if nid < total_nodes && !visited[nid] {
      visited[nid] = true
      for p in n.prev.val {
        _dfs(p)
      }
      result.push(n)
    }
  }
  for n in nodes {
    _dfs(n)
  }
  result
}

///|
/// Topological sort of all nodes reachable from outputs.
pub fn topological_sort(graph : Graph) -> Array[Node] {
  collect_ancestors(graph.output.val, graph.counter.val)
}
