///|
fn _fa(arr : Array[Double]) -> FixedArray[Double] {
  FixedArray::makei(arr.length(), fn(i) { arr[i] })
}

///|
test "compute_make_graph" {
  let g = @compute.make_graph("test")
  @test.assert_eq("test", g.name.val)
  @test.assert_eq(0, g.nodes.val.length())
}

///|
test "compute_make_node" {
  let g = @compute.make_graph("test")
  let n = @compute.make_node(g, @compute.op_zeros([3]), "x")
  @test.assert_eq(0, @compute.node_id(n))
  @test.assert_eq("x", @compute.node_name(n))
  @test.assert_eq(1, g.nodes.val.length())
}

///|
test "compute_connect" {
  let g = @compute.make_graph("test")
  let n1 = @compute.make_node(g, @compute.op_var(), "x")
  let n2 = @compute.make_node(g, @compute.op_abs(), "y")
  @compute.connect(n1, n2)
  @test.assert_eq(1, n2.prev.val.length())
  @test.assert_eq(1, n1.next.val.length())
}

///|
test "compute_eval_zeros" {
  let g = @compute.make_graph("test")
  let n = @compute.make_node(g, @compute.op_zeros([2, 3]), "x")
  @compute.set_outputs(g, [n])
  @compute.eval_graph(g)
  let v = @compute.get_node_value(n)
  @test.assert_eq([2, 3], @ndarray.shape(v))
  @test.assert_eq(true, @ndarray.get(@ndarray.sum(v), [0]) < 0.001)
}

///|
test "compute_eval_ones" {
  let g = @compute.make_graph("test")
  let n = @compute.make_node(g, @compute.op_ones([3]), "x")
  @compute.set_outputs(g, [n])
  @compute.eval_graph(g)
  let v = @compute.get_node_value(n)
  @test.assert_eq([3], @ndarray.shape(v))
  @test.assert_eq(3.0, @ndarray.get(@ndarray.sum(v), [0]))
}

///|
test "compute_eval_abs" {
  let g = @compute.make_graph("test")
  let x = @compute.make_node(g, @compute.op_var(), "x")
  let y = @compute.make_node(g, @compute.op_abs(), "y")
  @compute.connect(x, y)
  @compute.set_inputs(g, [x])
  @compute.set_outputs(g, [y])
  @compute.set_node_value(x, @ndarray.from_data([3], _fa([-1.0, -2.0, -3.0])))
  @compute.eval_graph(g)
  let v = @compute.get_node_value(y)
  @test.assert_eq(1.0, @ndarray.get(v, [0]))
  @test.assert_eq(2.0, @ndarray.get(v, [1]))
  @test.assert_eq(3.0, @ndarray.get(v, [2]))
}

///|
test "compute_eval_add" {
  let g = @compute.make_graph("test")
  let x = @compute.make_node(g, @compute.op_var(), "x")
  let w = @compute.make_node(g, @compute.op_var(), "w")
  let y = @compute.make_node(g, @compute.op_add(), "y")
  @compute.connect(x, y)
  @compute.connect(w, y)
  @compute.set_inputs(g, [x, w])
  @compute.set_outputs(g, [y])
  @compute.set_node_value(x, @ndarray.from_data([2], _fa([1.0, 2.0])))
  @compute.set_node_value(w, @ndarray.from_data([2], _fa([3.0, 4.0])))
  @compute.eval_graph(g)
  let v = @compute.get_node_value(y)
  @test.assert_eq(4.0, @ndarray.get(v, [0]))
  @test.assert_eq(6.0, @ndarray.get(v, [1]))
}

///|
test "compute_eval_mul" {
  let g = @compute.make_graph("test")
  let x = @compute.make_node(g, @compute.op_var(), "x")
  let w = @compute.make_node(g, @compute.op_var(), "w")
  let y = @compute.make_node(g, @compute.op_mul(), "y")
  @compute.connect(x, y)
  @compute.connect(w, y)
  @compute.set_inputs(g, [x, w])
  @compute.set_outputs(g, [y])
  @compute.set_node_value(x, @ndarray.from_data([2], _fa([2.0, 3.0])))
  @compute.set_node_value(w, @ndarray.from_data([2], _fa([4.0, 5.0])))
  @compute.eval_graph(g)
  let v = @compute.get_node_value(y)
  @test.assert_eq(8.0, @ndarray.get(v, [0]))
  @test.assert_eq(15.0, @ndarray.get(v, [1]))
}

///|
test "compute_eval_exp" {
  let g = @compute.make_graph("test")
  let x = @compute.make_node(g, @compute.op_var(), "x")
  let y = @compute.make_node(g, @compute.op_exp(), "y")
  @compute.connect(x, y)
  @compute.set_inputs(g, [x])
  @compute.set_outputs(g, [y])
  @compute.set_node_value(x, @ndarray.from_data([1], _fa([0.0])))
  @compute.eval_graph(g)
  let v = @compute.get_node_value(y)
  @test.assert_eq(true, (@ndarray.get(v, [0]) - 1.0).abs() < 0.001)
}

///|
test "compute_eval_chain" {
  let g = @compute.make_graph("test")
  let x = @compute.make_node(g, @compute.op_var(), "x")
  let h = @compute.make_node(g, @compute.op_sqr(), "h")
  let y = @compute.make_node(g, @compute.op_neg(), "y")
  @compute.connect(x, h)
  @compute.connect(h, y)
  @compute.set_inputs(g, [x])
  @compute.set_outputs(g, [y])
  @compute.set_node_value(x, @ndarray.from_data([1], _fa([3.0])))
  @compute.eval_graph(g)
  let v = @compute.get_node_value(y)
  @test.assert_eq(true, (@ndarray.get(v, [0]) - -9.0).abs() < 0.001)
}

///|
test "compute_shape_inference" {
  let g = @compute.make_graph("test")
  let x = @compute.make_node(g, @compute.op_zeros([2, 3]), "x")
  @compute.set_outputs(g, [x])
  @compute.infer_shapes(g)
  let s = @compute.get_node_shape(x)
  match s[0] {
    Some(shape) => @test.assert_eq([2, 3], shape)
    None => @test.assert_eq(true, false)
  }
}

///|
test "compute_topological_sort" {
  let g = @compute.make_graph("test")
  let x = @compute.make_node(g, @compute.op_var(), "x")
  let h = @compute.make_node(g, @compute.op_abs(), "h")
  let y = @compute.make_node(g, @compute.op_neg(), "y")
  @compute.connect(x, h)
  @compute.connect(h, y)
  @compute.set_outputs(g, [y])
  let topo = @compute.topological_sort(g)
  @test.assert_eq(3, topo.length())
}

///|
test "compute_op_to_str" {
  @test.assert_eq("Add", @compute.op_to_str(@compute.op_add()))
  @test.assert_eq("Mul", @compute.op_to_str(@compute.op_mul()))
  @test.assert_eq("Var", @compute.op_to_str(@compute.op_var()))
  @test.assert_eq("Abs", @compute.op_to_str(@compute.op_abs()))
}

///|
test "compute_is_unary" {
  @test.assert_eq(true, @compute.is_unary(@compute.op_abs()))
  @test.assert_eq(true, @compute.is_unary(@compute.op_neg()))
  @test.assert_eq(false, @compute.is_unary(@compute.op_add()))
}

///|
test "compute_is_binary" {
  @test.assert_eq(true, @compute.is_binary(@compute.op_add()))
  @test.assert_eq(true, @compute.is_binary(@compute.op_mul()))
  @test.assert_eq(false, @compute.is_binary(@compute.op_abs()))
}

///|
test "compute_eval_copy" {
  let g = @compute.make_graph("test")
  let x = @compute.make_node(g, @compute.op_var(), "x")
  let y = @compute.make_node(g, @compute.op_copy(), "y")
  @compute.connect(x, y)
  @compute.set_inputs(g, [x])
  @compute.set_outputs(g, [y])
  @compute.set_node_value(x, @ndarray.from_data([3], _fa([1.0, 2.0, 3.0])))
  @compute.eval_graph(g)
  let v = @compute.get_node_value(y)
  @test.assert_eq(1.0, @ndarray.get(v, [0]))
  @test.assert_eq(2.0, @ndarray.get(v, [1]))
  @test.assert_eq(3.0, @ndarray.get(v, [2]))
}
