///|
fn _fa(arr : Array[Double]) -> FixedArray[Double] {
  FixedArray::makei(arr.length(), fn(i) { arr[i] })
}

///|
test "compute_make_graph" {
  let g = make_graph("test")
  @test.assert_eq("test", g.name.val)
  @test.assert_eq(0, g.nodes.val.length())
}

///|
test "compute_make_node" {
  let g = make_graph("test")
  let n = make_node(g, op_zeros([3]), "x")
  @test.assert_eq(0, node_id(n))
  @test.assert_eq("x", node_name(n))
  @test.assert_eq(1, g.nodes.val.length())
}

///|
test "compute_connect" {
  let g = make_graph("test")
  let n1 = make_node(g, op_var(), "x")
  let n2 = make_node(g, op_abs(), "y")
  connect(n1, n2)
  @test.assert_eq(1, n2.prev.val.length())
  @test.assert_eq(1, n1.next.val.length())
}

///|
test "compute_eval_zeros" {
  let g = make_graph("test")
  let n = make_node(g, op_zeros([2, 3]), "x")
  set_outputs(g, [n])
  eval_graph(g)
  let v = get_node_value(n)
  @test.assert_eq([2, 3], @ndarray.shape(v))
  @test.assert_eq(true, @ndarray.get(@ndarray.sum(v), [0]) < 0.001)
}

///|
test "compute_eval_ones" {
  let g = make_graph("test")
  let n = make_node(g, op_ones([3]), "x")
  set_outputs(g, [n])
  eval_graph(g)
  let v = get_node_value(n)
  @test.assert_eq([3], @ndarray.shape(v))
  @test.assert_eq(3.0, @ndarray.get(@ndarray.sum(v), [0]))
}

///|
test "compute_eval_abs" {
  let g = make_graph("test")
  let x = make_node(g, op_var(), "x")
  let y = make_node(g, op_abs(), "y")
  connect(x, y)
  set_inputs(g, [x])
  set_outputs(g, [y])
  set_node_value(x, @ndarray.from_data([3], _fa([-1.0, -2.0, -3.0])))
  eval_graph(g)
  let v = get_node_value(y)
  @test.assert_eq(1.0, @ndarray.get(v, [0]))
  @test.assert_eq(2.0, @ndarray.get(v, [1]))
  @test.assert_eq(3.0, @ndarray.get(v, [2]))
}

///|
test "compute_eval_add" {
  let g = make_graph("test")
  let x = make_node(g, op_var(), "x")
  let w = make_node(g, op_var(), "w")
  let y = make_node(g, op_add(), "y")
  connect(x, y)
  connect(w, y)
  set_inputs(g, [x, w])
  set_outputs(g, [y])
  set_node_value(x, @ndarray.from_data([2], _fa([1.0, 2.0])))
  set_node_value(w, @ndarray.from_data([2], _fa([3.0, 4.0])))
  eval_graph(g)
  let v = get_node_value(y)
  @test.assert_eq(4.0, @ndarray.get(v, [0]))
  @test.assert_eq(6.0, @ndarray.get(v, [1]))
}

///|
test "compute_eval_mul" {
  let g = make_graph("test")
  let x = make_node(g, op_var(), "x")
  let w = make_node(g, op_var(), "w")
  let y = make_node(g, op_mul(), "y")
  connect(x, y)
  connect(w, y)
  set_inputs(g, [x, w])
  set_outputs(g, [y])
  set_node_value(x, @ndarray.from_data([2], _fa([2.0, 3.0])))
  set_node_value(w, @ndarray.from_data([2], _fa([4.0, 5.0])))
  eval_graph(g)
  let v = get_node_value(y)
  @test.assert_eq(8.0, @ndarray.get(v, [0]))
  @test.assert_eq(15.0, @ndarray.get(v, [1]))
}

///|
test "compute_eval_exp" {
  let g = make_graph("test")
  let x = make_node(g, op_var(), "x")
  let y = make_node(g, op_exp(), "y")
  connect(x, y)
  set_inputs(g, [x])
  set_outputs(g, [y])
  set_node_value(x, @ndarray.from_data([1], _fa([0.0])))
  eval_graph(g)
  let v = get_node_value(y)
  @test.assert_eq(true, (@ndarray.get(v, [0]) - 1.0).abs() < 0.001)
}

///|
test "compute_eval_chain" {
  let g = make_graph("test")
  let x = make_node(g, op_var(), "x")
  let h = make_node(g, op_sqr(), "h")
  let y = make_node(g, op_neg(), "y")
  connect(x, h)
  connect(h, y)
  set_inputs(g, [x])
  set_outputs(g, [y])
  set_node_value(x, @ndarray.from_data([1], _fa([3.0])))
  eval_graph(g)
  let v = get_node_value(y)
  @test.assert_eq(true, (@ndarray.get(v, [0]) - -9.0).abs() < 0.001)
}

///|
test "compute_shape_inference" {
  let g = make_graph("test")
  let x = make_node(g, op_zeros([2, 3]), "x")
  set_outputs(g, [x])
  infer_shapes(g)
  let s = get_node_shape(x)
  match s[0] {
    Some(shape) => @test.assert_eq([2, 3], shape)
    None => @test.assert_eq(true, false)
  }
}

///|
test "compute_topological_sort" {
  let g = make_graph("test")
  let x = make_node(g, op_var(), "x")
  let h = make_node(g, op_abs(), "h")
  let y = make_node(g, op_neg(), "y")
  connect(x, h)
  connect(h, y)
  set_outputs(g, [y])
  let topo = topological_sort(g)
  @test.assert_eq(3, topo.length())
}

///|
test "compute_op_to_str" {
  @test.assert_eq("Add", op_to_str(op_add()))
  @test.assert_eq("Mul", op_to_str(op_mul()))
  @test.assert_eq("Var", op_to_str(op_var()))
  @test.assert_eq("Abs", op_to_str(op_abs()))
}

///|
test "compute_is_unary" {
  @test.assert_eq(true, is_unary(op_abs()))
  @test.assert_eq(true, is_unary(op_neg()))
  @test.assert_eq(false, is_unary(op_add()))
}

///|
test "compute_is_binary" {
  @test.assert_eq(true, is_binary(op_add()))
  @test.assert_eq(true, is_binary(op_mul()))
  @test.assert_eq(false, is_binary(op_abs()))
}

///|
test "compute_eval_copy" {
  let g = make_graph("test")
  let x = make_node(g, op_var(), "x")
  let y = make_node(g, op_copy(), "y")
  connect(x, y)
  set_inputs(g, [x])
  set_outputs(g, [y])
  set_node_value(x, @ndarray.from_data([3], _fa([1.0, 2.0, 3.0])))
  eval_graph(g)
  let v = get_node_value(y)
  @test.assert_eq(1.0, @ndarray.get(v, [0]))
  @test.assert_eq(2.0, @ndarray.get(v, [1]))
  @test.assert_eq(3.0, @ndarray.get(v, [2]))
}
