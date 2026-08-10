///|
/// Ndarray core tests.

///|
test "zeros and ones" {
  let z = zeros([2, 3])
  @test.assert_eq(6, numel(z))
  @test.assert_eq(true, is_zero(z))
  let o = ones([2, 3])
  @test.assert_eq(6.0, sum_(o))
}

///|
test "create and fill" {
  let c = create([2, 2], 3.5)
  @test.assert_eq(14.0, sum_(c))
  @test.assert_eq(true, equal_scalar(c, 3.5))
}

///|
test "sequential" {
  let s = sequential([5])
  @test.assert_eq(0.0, s.data[0])
  @test.assert_eq(4.0, s.data[4])
  let s2 = sequential([3], a=10.0, step=2.0)
  @test.assert_eq(10.0, s2.data[0])
  @test.assert_eq(14.0, s2.data[2])
}

///|
test "of_array and of_arrays" {
  let a = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  @test.assert_eq(2, row_num(a))
  @test.assert_eq(3, col_num(a))
  @test.assert_eq(21.0, sum_(a))
  let b = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(10.0, sum_(b))
}

///|
test "get and set" {
  let a = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  @test.assert_eq(1.0, get(a, [0, 0]))
  @test.assert_eq(6.0, get(a, [1, 2]))
  set(a, [1, 2], 100.0)
  @test.assert_eq(100.0, get(a, [1, 2]))
}

///|
test "eye" {
  let e = eye(3)
  @test.assert_eq(3.0, sum_(e))
  @test.assert_eq(1.0, get(e, [0, 0]))
  @test.assert_eq(0.0, get(e, [0, 1]))
  @test.assert_eq(1.0, get(e, [2, 2]))
}

///|
test "add and sub" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let b = of_arrays([[5.0, 6.0], [7.0, 8.0]])
  let c = add(a, b)
  @test.assert_eq(6.0, get(c, [0, 0]))
  @test.assert_eq(8.0, get(c, [0, 1]))
  @test.assert_eq(10.0, get(c, [1, 0]))
  let d = sub(b, a)
  @test.assert_eq(4.0, get(d, [0, 0]))
  @test.assert_eq(4.0, get(d, [1, 1]))
}

///|
test "mul and div" {
  let a = of_arrays([[2.0, 4.0], [6.0, 8.0]])
  let b = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let c = mul(a, b)
  @test.assert_eq(2.0, get(c, [0, 0]))
  @test.assert_eq(8.0, get(c, [0, 1]))
  @test.assert_eq(18.0, get(c, [1, 0]))
  let d = div(a, b)
  @test.assert_eq(2.0, get(d, [0, 0]))
  @test.assert_eq(2.0, get(d, [0, 1]))
  @test.assert_eq(2.0, get(d, [1, 0]))
}

///|
test "scalar ops" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let b = add_scalar(a, 10.0)
  @test.assert_eq(11.0, get(b, [0, 0]))
  let c = mul_scalar(a, 2.0)
  @test.assert_eq(2.0, get(c, [0, 0]))
  @test.assert_eq(8.0, get(c, [1, 1]))
}

///|
test "broadcasting" {
  let a = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  let b = of_array([10.0, 20.0, 30.0], [3])
  let c = add(a, b)
  @test.assert_eq(11.0, get(c, [0, 0]))
  @test.assert_eq(22.0, get(c, [0, 1]))
  @test.assert_eq(33.0, get(c, [0, 2]))
  @test.assert_eq(14.0, get(c, [1, 0]))
  @test.assert_eq(25.0, get(c, [1, 1]))
  @test.assert_eq(36.0, get(c, [1, 2]))
}

///|
test "sum reduction" {
  let a = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  @test.assert_eq(21.0, sum_(a))
  let s0 = sum(a, axis=0, keep_dims=false)
  @test.assert_eq(5.0, get(s0, [0]))
  @test.assert_eq(7.0, get(s0, [1]))
  @test.assert_eq(9.0, get(s0, [2]))
  let s1 = sum(a, axis=1, keep_dims=false)
  @test.assert_eq(6.0, get(s1, [0]))
  @test.assert_eq(15.0, get(s1, [1]))
}

///|
test "min max reduction" {
  let a = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  @test.assert_eq(1.0, min_(a))
  @test.assert_eq(6.0, max_(a))
  let m0 = max(a, axis=0, keep_dims=false)
  @test.assert_eq(4.0, get(m0, [0]))
  @test.assert_eq(5.0, get(m0, [1]))
  @test.assert_eq(6.0, get(m0, [2]))
}

///|
test "reshape and flatten" {
  let a = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let b = reshape(a, [3, 2])
  @test.assert_eq(3, row_num(b))
  @test.assert_eq(2, col_num(b))
  @test.assert_eq(1.0, get(b, [0, 0]))
  @test.assert_eq(3.0, get(b, [1, 0]))
  let f = flatten(a)
  @test.assert_eq(6, numel(f))
  @test.assert_eq(1.0, f.data[0])
  @test.assert_eq(6.0, f.data[5])
}

///|
test "transpose" {
  let a = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  let t = transpose(a)
  @test.assert_eq(3, row_num(t))
  @test.assert_eq(2, col_num(t))
  @test.assert_eq(1.0, get(t, [0, 0]))
  @test.assert_eq(4.0, get(t, [0, 1]))
  @test.assert_eq(2.0, get(t, [1, 0]))
  @test.assert_eq(6.0, get(t, [2, 1]))
}

///|
test "matrix dot" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let b = of_arrays([[5.0, 6.0], [7.0, 8.0]])
  let c = dot(a, b)
  @test.assert_eq(19.0, get(c, [0, 0]))
  @test.assert_eq(22.0, get(c, [0, 1]))
  @test.assert_eq(43.0, get(c, [1, 0]))
  @test.assert_eq(50.0, get(c, [1, 1]))
}

///|
test "trace and diag" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(5.0, trace(a))
  let d = diag(a)
  @test.assert_eq(1.0, d.data[0])
  @test.assert_eq(4.0, d.data[1])
}

///|
test "element-wise math" {
  let a = of_array([1.0, 4.0, 9.0], [3])
  let s = sqrt(a)
  @test.assert_eq(1.0, s.data[0])
  @test.assert_eq(2.0, s.data[1])
  @test.assert_eq(3.0, s.data[2])
  let e = exp(of_array([0.0], [1]))
  @test.assert_eq(true, (e.data[0] - 1.0).abs() < 1.0e-10)
}

///|
test "map and iter" {
  let a = of_array([1.0, 2.0, 3.0, 4.0], [4])
  let b = map(fn(v) { v * v }, a)
  @test.assert_eq(1.0, b.data[0])
  @test.assert_eq(4.0, b.data[1])
  @test.assert_eq(9.0, b.data[2])
  @test.assert_eq(16.0, b.data[3])
  let mut s = 0.0
  iter(fn(v) { s += v }, a)
  @test.assert_eq(10.0, s)
}

///|
test "equal and approx_equal" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let b = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(true, equal(a, b))
  let c = of_arrays([[1.0, 2.0], [3.0, 5.0]])
  @test.assert_eq(false, equal(a, c))
}

///|
test "concatenate" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let b = of_arrays([[5.0, 6.0], [7.0, 8.0]])
  let c = concatenate([a, b], axis=0)
  @test.assert_eq(4, row_num(c))
  @test.assert_eq(2, col_num(c))
  @test.assert_eq(5.0, get(c, [2, 0]))
  let d = concatenate([a, b], axis=1)
  @test.assert_eq(2, row_num(d))
  @test.assert_eq(4, col_num(d))
  @test.assert_eq(5.0, get(d, [0, 2]))
}

///|
test "row and rows" {
  let a = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
  let r = row(a, 1)
  @test.assert_eq(4.0, r.data[0])
  @test.assert_eq(6.0, r.data[2])
  let rs = rows(a, [0, 2])
  @test.assert_eq(1.0, get(rs, [0, 0]))
  @test.assert_eq(7.0, get(rs, [1, 0]))
}

///|
test "to_rows and of_rows" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let rs = to_rows(a)
  @test.assert_eq(1.0, rs[0].data[0])
  @test.assert_eq(3.0, rs[1].data[0])
  let b = of_rows(rs)
  @test.assert_eq(true, equal(a, b))
}

///|
test "l2norm" {
  let a = of_array([3.0, 4.0], [2])
  @test.assert_eq(25.0, l2norm_sqr_(a))
  @test.assert_eq(5.0, l2norm_(a))
}

///|
test "copy and reset" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let b = copy(a)
  @test.assert_eq(true, equal(a, b))
  reset(b)
  @test.assert_eq(true, is_zero(b))
  @test.assert_eq(1.0, get(a, [0, 0]))
}

///|
test "get_slice and set_slice" {
  let a = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
  let s = get_slice([[0, 1]], a)
  @test.assert_eq(2, row_num(s))
  @test.assert_eq(3, col_num(s))
  @test.assert_eq(1.0, get(s, [0, 0]))
  @test.assert_eq(4.0, get(s, [1, 0]))
  let s2 = get_slice([[], [1, 2]], a)
  @test.assert_eq(3, row_num(s2))
  @test.assert_eq(2, col_num(s2))
  @test.assert_eq(2.0, get(s2, [0, 0]))
  @test.assert_eq(3.0, get(s2, [0, 1]))
}

///|
test "pad" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let p = pad(a, [[1, 1], [1, 1]], v=0.0)
  @test.assert_eq(4, row_num(p))
  @test.assert_eq(4, col_num(p))
  @test.assert_eq(0.0, get(p, [0, 0]))
  @test.assert_eq(1.0, get(p, [1, 1]))
  @test.assert_eq(4.0, get(p, [2, 2]))
  @test.assert_eq(0.0, get(p, [3, 3]))
}

///|
test "split" {
  let a = of_arrays([[1.0, 2.0, 3.0, 4.0], [5.0, 6.0, 7.0, 8.0]])
  let parts = split(a, [2, 2], axis=1)
  @test.assert_eq(2, parts.length())
  @test.assert_eq(1.0, get(parts[0], [0, 0]))
  @test.assert_eq(2.0, get(parts[0], [0, 1]))
  @test.assert_eq(3.0, get(parts[1], [0, 0]))
  @test.assert_eq(4.0, get(parts[1], [0, 1]))
}

///|
test "one_hot" {
  let a = of_array([0.0, 1.0, 2.0, 1.0], [4])
  let oh = one_hot(3, a)
  @test.assert_eq(4, row_num(oh))
  @test.assert_eq(3, col_num(oh))
  @test.assert_eq(1.0, get(oh, [0, 0]))
  @test.assert_eq(0.0, get(oh, [0, 1]))
  @test.assert_eq(1.0, get(oh, [1, 1]))
  @test.assert_eq(1.0, get(oh, [2, 2]))
  @test.assert_eq(1.0, get(oh, [3, 1]))
}

///|
test "copy_ and copy_row_to" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let b = zeros([2, 2])
  copy_(b, a)
  @test.assert_eq(1.0, get(b, [0, 0]))
  @test.assert_eq(4.0, get(b, [1, 1]))
  let v = of_array([10.0, 20.0], [2])
  copy_row_to(v, b, 0)
  @test.assert_eq(10.0, get(b, [0, 0]))
  @test.assert_eq(20.0, get(b, [0, 1]))
}

///|
test "clip_by_value" {
  let a = of_array([-5.0, -1.0, 0.0, 1.0, 5.0], [5])
  let c = clip_by_value(a, amin=-2.0, amax=2.0)
  @test.assert_eq(-2.0, c.data[0])
  @test.assert_eq(-1.0, c.data[1])
  @test.assert_eq(0.0, c.data[2])
  @test.assert_eq(1.0, c.data[3])
  @test.assert_eq(2.0, c.data[4])
}

///|
test "clip_by_l2norm" {
  let a = of_array([3.0, 4.0], [2])
  @test.assert_eq(5.0, l2norm_(a))
  let c = clip_by_l2norm(2.5, a)
  @test.assert_eq(true, (l2norm_(c) - 2.5).abs() < 1.0e-10)
}

///|
test "atan2" {
  let y = of_array([1.0, 0.0, -1.0], [3])
  let x = of_array([1.0, 1.0, 1.0], [3])
  let r = atan2(y, x)
  @test.assert_eq(true, (r.data[0] - @math.atan2(1.0, 1.0)).abs() < 1.0e-10)
  @test.assert_eq(true, r.data[1].abs() < 1.0e-10)
  @test.assert_eq(true, (r.data[2] + @math.atan2(1.0, 1.0)).abs() < 1.0e-10)
}

///|
test "sum_slices" {
  let a = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  let s = sum_slices(a, axis=0)
  @test.assert_eq(5.0, s.data[0])
  @test.assert_eq(7.0, s.data[1])
  @test.assert_eq(9.0, s.data[2])
}

///|
test "log_sum_exp" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  let lse = log_sum_exp_(a)
  let expected = @math.ln(@math.exp(1.0) + @math.exp(2.0) + @math.exp(3.0))
  @test.assert_eq(true, (lse - expected).abs() < 1.0e-10)
}

///|
test "softmax" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  let s = softmax(a)
  @test.assert_eq(true, (sum_(s) - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, s.data[0] < s.data[1])
  @test.assert_eq(true, s.data[1] < s.data[2])
}

///|
test "approx_equal_scalar and approx_elt_equal" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  @test.assert_eq(true, approx_equal_scalar(a, 2.0, eps=2.0))
  @test.assert_eq(false, approx_equal_scalar(a, 2.0, eps=0.5))
  let b = of_array([1.001, 2.001, 3.001], [3])
  let eq = approx_elt_equal(a, b, eps=0.01)
  @test.assert_eq(1.0, eq.data[0])
  @test.assert_eq(1.0, eq.data[1])
  @test.assert_eq(1.0, eq.data[2])
}

///|
test "init_flat" {
  let a = init_flat([2, 3], fn(i) { i.to_double() })
  @test.assert_eq(0.0, a.data[0])
  @test.assert_eq(5.0, a.data[5])
  @test.assert_eq(2, row_num(a))
  @test.assert_eq(3, col_num(a))
}

///|
test "to_string formatting" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  let s = to_string(a)
  @test.assert_eq(true, s.contains("1"))
  @test.assert_eq(true, s.contains("2"))
  @test.assert_eq(true, s.contains("3"))
  let b = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let s2 = to_string(b)
  @test.assert_eq(true, s2.contains("4"))
}

///|
test "conv2d basic" {
  let input = of_array(
    [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0],
    [1, 3, 4, 1],
  )
  let kernel = of_array([1.0, 0.0, 0.0, 1.0], [2, 2, 1, 1])
  let output = conv2d(input, kernel, [1, 1], padding=@types.Padding::Valid)
  @test.assert_eq(1, output.shape[0])
  @test.assert_eq(2, output.shape[1])
  @test.assert_eq(3, output.shape[2])
  @test.assert_eq(1, output.shape[3])
  @test.assert_eq(7.0, get(output, [0, 0, 0, 0]))
  @test.assert_eq(9.0, get(output, [0, 0, 1, 0]))
}

///|
test "conv1d basic" {
  let input = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [1, 6, 1])
  let kernel = of_array([1.0, 0.0, 1.0], [3, 1, 1])
  let output = conv1d(input, kernel, [1], padding=@types.Padding::Valid)
  @test.assert_eq(1, output.shape[0])
  @test.assert_eq(4, output.shape[1])
  @test.assert_eq(1, output.shape[2])
  @test.assert_eq(4.0, get(output, [0, 0, 0]))
  @test.assert_eq(6.0, get(output, [0, 1, 0]))
}

///|
test "max_pool2d basic" {
  let input = of_array(
    [
      1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0,
      15.0, 16.0,
    ],
    [1, 4, 4, 1],
  )
  let output = max_pool2d(input, [2, 2], [2, 2], padding=@types.Padding::Valid)
  @test.assert_eq(1, output.shape[0])
  @test.assert_eq(2, output.shape[1])
  @test.assert_eq(2, output.shape[2])
  @test.assert_eq(1, output.shape[3])
  @test.assert_eq(6.0, get(output, [0, 0, 0, 0]))
  @test.assert_eq(8.0, get(output, [0, 0, 1, 0]))
  @test.assert_eq(14.0, get(output, [0, 1, 0, 0]))
  @test.assert_eq(16.0, get(output, [0, 1, 1, 0]))
}

///|
test "avg_pool2d basic" {
  let input = of_array(
    [
      1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0,
      15.0, 16.0,
    ],
    [1, 4, 4, 1],
  )
  let output = avg_pool2d(input, [2, 2], [2, 2], padding=@types.Padding::Valid)
  @test.assert_eq(3.5, get(output, [0, 0, 0, 0]))
  @test.assert_eq(5.5, get(output, [0, 0, 1, 0]))
  @test.assert_eq(11.5, get(output, [0, 1, 0, 0]))
  @test.assert_eq(13.5, get(output, [0, 1, 1, 0]))
}

///|
test "upsampling2d basic" {
  let input = of_array([1.0, 2.0, 3.0, 4.0], [1, 2, 2, 1])
  let output = upsampling2d(input, [2, 2])
  @test.assert_eq(1, output.shape[0])
  @test.assert_eq(4, output.shape[1])
  @test.assert_eq(4, output.shape[2])
  @test.assert_eq(1, output.shape[3])
  @test.assert_eq(1.0, get(output, [0, 0, 0, 0]))
  @test.assert_eq(1.0, get(output, [0, 0, 1, 0]))
  @test.assert_eq(1.0, get(output, [0, 1, 0, 0]))
  @test.assert_eq(2.0, get(output, [0, 0, 2, 0]))
  @test.assert_eq(4.0, get(output, [0, 2, 2, 0]))
}

///|
test "dilated_conv2d basic" {
  let input = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0], [
    1, 3, 3, 1,
  ])
  let kernel = of_array([1.0, 0.0, 0.0, 1.0], [2, 2, 1, 1])
  let output = dilated_conv2d(
    input,
    kernel,
    [1, 1],
    [2, 2],
    padding=@types.Padding::Valid,
  )
  @test.assert_eq(1, output.shape[0])
  @test.assert_eq(1, output.shape[1])
  @test.assert_eq(1, output.shape[2])
  @test.assert_eq(1, output.shape[3])
  @test.assert_eq(10.0, get(output, [0, 0, 0, 0]))
}
