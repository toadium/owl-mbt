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

///|
test "comparison: exists and not_exists" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  @test.assert_eq(true, exists(fn(v) { v == 2.0 }, a))
  @test.assert_eq(false, exists(fn(v) { v == 5.0 }, a))
  @test.assert_eq(false, not_exists(fn(v) { v == 2.0 }, a))
  @test.assert_eq(true, not_exists(fn(v) { v == 5.0 }, a))
}

///|
test "comparison: for_all and is_positive/negative" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  @test.assert_eq(true, for_all(fn(v) { v > 0.0 }, a))
  @test.assert_eq(true, is_positive(a))
  @test.assert_eq(false, is_negative(a))
  @test.assert_eq(false, is_nonpositive(a))
  @test.assert_eq(true, is_nonnegative(a))
  let b = of_array([-1.0, -2.0], [2])
  @test.assert_eq(true, is_negative(b))
  @test.assert_eq(true, is_nonpositive(b))
  @test.assert_eq(false, is_positive(b))
  let z = zeros([3])
  @test.assert_eq(true, is_zero(z))
  @test.assert_eq(true, is_nonnegative(z))
  @test.assert_eq(true, is_nonpositive(z))
}

///|
test "comparison: is_normal, not_nan, not_inf" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  @test.assert_eq(true, is_normal(a))
  @test.assert_eq(true, not_nan(a))
  @test.assert_eq(true, not_inf(a))
}

///|
test "comparison: not_equal, greater, less, greater_equal, less_equal" {
  let a = of_array([2.0, 3.0, 4.0], [3])
  let b = of_array([1.0, 2.0, 3.0], [3])
  @test.assert_eq(true, not_equal(a, b))
  @test.assert_eq(true, greater(a, b))
  @test.assert_eq(true, less(b, a))
  @test.assert_eq(true, greater_equal(a, b))
  @test.assert_eq(true, less_equal(b, a))
  @test.assert_eq(false, greater(b, a))
  @test.assert_eq(false, less(a, b))
}

///|
test "comparison: elt_*" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  let b = of_array([1.0, 3.0, 2.0], [3])
  let eq = elt_equal(a, b)
  @test.assert_eq(1.0, eq.data[0])
  @test.assert_eq(0.0, eq.data[1])
  let ne = elt_not_equal(a, b)
  @test.assert_eq(0.0, ne.data[0])
  @test.assert_eq(1.0, ne.data[1])
  let lt = elt_less(a, b)
  @test.assert_eq(0.0, lt.data[0])
  @test.assert_eq(1.0, lt.data[1])
  let gt = elt_greater(a, b)
  @test.assert_eq(0.0, gt.data[0])
  @test.assert_eq(0.0, gt.data[1])
  @test.assert_eq(1.0, gt.data[2])
  let le = elt_less_equal(a, b)
  @test.assert_eq(1.0, le.data[0])
  @test.assert_eq(1.0, le.data[1])
  let ge = elt_greater_equal(a, b)
  @test.assert_eq(1.0, ge.data[0])
  @test.assert_eq(0.0, ge.data[1])
  @test.assert_eq(1.0, ge.data[2])
}

///|
test "comparison: *_scalar" {
  let a = of_array([2.0, 2.0, 2.0], [3])
  @test.assert_eq(true, equal_scalar(a, 2.0))
  @test.assert_eq(false, not_equal_scalar(a, 2.0))
  @test.assert_eq(true, not_equal_scalar(a, 3.0))
  @test.assert_eq(true, less_scalar(a, 3.0))
  @test.assert_eq(true, greater_scalar(a, 1.0))
  @test.assert_eq(true, less_equal_scalar(a, 2.0))
  @test.assert_eq(true, greater_equal_scalar(a, 2.0))
  @test.assert_eq(false, less_scalar(a, 2.0))
  @test.assert_eq(false, greater_scalar(a, 2.0))
}

///|
test "comparison: elt_*_scalar" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  let eq = elt_equal_scalar(a, 2.0)
  @test.assert_eq(0.0, eq.data[0])
  @test.assert_eq(1.0, eq.data[1])
  let ne = elt_not_equal_scalar(a, 2.0)
  @test.assert_eq(1.0, ne.data[0])
  @test.assert_eq(0.0, ne.data[1])
  let lt = elt_less_scalar(a, 2.0)
  @test.assert_eq(1.0, lt.data[0])
  @test.assert_eq(0.0, lt.data[1])
  let gt = elt_greater_scalar(a, 2.0)
  @test.assert_eq(0.0, gt.data[0])
  @test.assert_eq(1.0, gt.data[2])
  let le = elt_less_equal_scalar(a, 2.0)
  @test.assert_eq(1.0, le.data[0])
  @test.assert_eq(1.0, le.data[1])
  let ge = elt_greater_equal_scalar(a, 2.0)
  @test.assert_eq(0.0, ge.data[0])
  @test.assert_eq(1.0, ge.data[1])
}

///|
test "comparison: approx_equal" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  let b = of_array([1.001, 2.001, 3.001], [3])
  @test.assert_eq(true, approx_equal(a, b, eps=0.01))
  @test.assert_eq(false, approx_equal(a, b, eps=0.0001))
  let c = of_array([1.0, 2.0], [2])
  @test.assert_eq(false, approx_equal(a, c))
}

///|
test "iteration: iteri and mapi" {
  let a = of_array([10.0, 20.0, 30.0], [3])
  let mut sum_idx = 0
  iteri(fn(i, _v) { sum_idx += i }, a)
  @test.assert_eq(3, sum_idx)
  let b = mapi(fn(i, v) { v + i.to_double() }, a)
  @test.assert_eq(10.0, b.data[0])
  @test.assert_eq(21.0, b.data[1])
  @test.assert_eq(32.0, b.data[2])
}

///|
test "iteration: filteri and filter" {
  let a = of_array([1.0, -2.0, 3.0, -4.0], [4])
  let idxs = filteri(fn(_i, v) { v > 0.0 }, a)
  @test.assert_eq(2, idxs.length())
  @test.assert_eq(0, idxs[0])
  @test.assert_eq(2, idxs[1])
  let idxs2 = filter(fn(v) { v < 0.0 }, a)
  @test.assert_eq(2, idxs2.length())
  @test.assert_eq(1, idxs2[0])
  @test.assert_eq(3, idxs2[1])
}

///|
test "iteration: foldi and fold" {
  let a = of_array([1.0, 2.0, 3.0, 4.0], [4])
  let s = foldi(fn(_i, acc, v) { acc + v }, 0.0, a)
  @test.assert_eq(10.0, s.data[0])
  let s2 = fold(fn(acc, v) { acc + v }, 0.0, a)
  @test.assert_eq(10.0, s2.data[0])
  let p = fold(fn(acc, v) { acc * v }, 1.0, a)
  @test.assert_eq(24.0, p.data[0])
  let m = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  let col_sum = fold(fn(acc, v) { acc + v }, 0.0, m, axis=0)
  @test.assert_eq(5.0, col_sum.data[0])
  @test.assert_eq(7.0, col_sum.data[1])
  @test.assert_eq(9.0, col_sum.data[2])
}

///|
test "iteration: scani and scan" {
  let a = of_array([1.0, 2.0, 3.0, 4.0], [4])
  let cs = scan(fn(acc, v) { acc + v }, a)
  @test.assert_eq(4, cs.data.length())
  @test.assert_eq(1.0, cs.data[0])
  let csi = scani(fn(_i, acc, v) { acc + v }, a)
  @test.assert_eq(1.0, csi.data[0])
}

///|
test "shape_ops: reshape with -1" {
  let a = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [6])
  let b = reshape(a, [2, -1])
  @test.assert_eq(2, b.shape[0])
  @test.assert_eq(3, b.shape[1])
  let c = reshape(a, [-1, 2])
  @test.assert_eq(3, c.shape[0])
  @test.assert_eq(2, c.shape[1])
}

///|
test "shape_ops: reverse" {
  let a = of_array([1.0, 2.0, 3.0, 4.0], [4])
  let r = reverse(a)
  @test.assert_eq(4.0, r.data[0])
  @test.assert_eq(3.0, r.data[1])
  @test.assert_eq(2.0, r.data[2])
  @test.assert_eq(1.0, r.data[3])
}

///|
test "shape_ops: squeeze and expand" {
  let a = of_array([1.0, 2.0, 3.0, 4.0], [1, 4, 1])
  let s = squeeze(a)
  @test.assert_eq(1, s.shape.length())
  @test.assert_eq(4, s.shape[0])
  let s2 = squeeze(a, axis=[0])
  @test.assert_eq(2, s2.shape.length())
  @test.assert_eq(4, s2.shape[0])
  @test.assert_eq(1, s2.shape[1])
  let b = of_array([1.0, 2.0, 3.0], [3])
  let e = expand(b, 0)
  @test.assert_eq(2, e.shape.length())
  @test.assert_eq(1, e.shape[0])
  @test.assert_eq(3, e.shape[1])
  let e2 = expand(b, 0, hi=true)
  @test.assert_eq(2, e2.shape.length())
  @test.assert_eq(3, e2.shape[0])
  @test.assert_eq(1, e2.shape[1])
}

///|
test "shape_ops: transpose with axis" {
  let a = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let t = transpose(a, axis=[1, 0])
  @test.assert_eq(3, t.shape[0])
  @test.assert_eq(2, t.shape[1])
  @test.assert_eq(1.0, get(t, [0, 0]))
  @test.assert_eq(4.0, get(t, [0, 1]))
  @test.assert_eq(2.0, get(t, [1, 0]))
}

///|
test "shape_ops: stack" {
  let a = of_array([1.0, 2.0, 3.0], [3])
  let b = of_array([4.0, 5.0, 6.0], [3])
  let s = stack([a, b], axis=0)
  @test.assert_eq(2, s.shape[0])
  @test.assert_eq(3, s.shape[1])
  @test.assert_eq(1.0, get(s, [0, 0]))
  @test.assert_eq(4.0, get(s, [1, 0]))
  let s2 = stack([a, b], axis=1)
  @test.assert_eq(3, s2.shape[0])
  @test.assert_eq(2, s2.shape[1])
  @test.assert_eq(1.0, get(s2, [0, 0]))
  @test.assert_eq(4.0, get(s2, [0, 1]))
}

///|
test "shape_ops: tile and repeat" {
  let a = of_array([1.0, 2.0], [2])
  let t = tile(a, [3])
  @test.assert_eq(6, t.shape[0])
  @test.assert_eq(1.0, t.data[0])
  @test.assert_eq(2.0, t.data[1])
  @test.assert_eq(1.0, t.data[2])
  let r = repeat(a, [2])
  @test.assert_eq(4, r.shape[0])
  @test.assert_eq(1.0, r.data[0])
  @test.assert_eq(1.0, r.data[1])
  @test.assert_eq(2.0, r.data[2])
  @test.assert_eq(2.0, r.data[3])
}

///|
test "math_ops: abs and neg" {
  let a = of_array([-1.0, 2.0, -3.0], [3])
  let ab = abs(a)
  @test.assert_eq(1.0, ab.data[0])
  @test.assert_eq(2.0, ab.data[1])
  @test.assert_eq(3.0, ab.data[2])
  let n = neg(a)
  @test.assert_eq(1.0, n.data[0])
  @test.assert_eq(-2.0, n.data[1])
  @test.assert_eq(3.0, n.data[2])
}

///|
test "math_ops: floor ceil round sqr" {
  let a = of_array([1.5, 2.4, 3.6], [3])
  @test.assert_eq(1.0, floor(a).data[0])
  @test.assert_eq(4.0, ceil(a).data[2])
  @test.assert_eq(2.0, round(a).data[0])
  @test.assert_eq(2.0, round(a).data[1])
  @test.assert_eq(true, (sqr(a).data[1] - 5.76).abs() < 1.0e-10)
}

///|
test "math_ops: log2 log10" {
  let a = of_array([2.0, 10.0, 100.0], [3])
  @test.assert_eq(true, (log2(a).data[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (log10(a).data[1] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (log10(a).data[2] - 2.0).abs() < 1.0e-10)
}

///|
test "math_ops: trig" {
  let a = of_array([0.0, 1.0], [2])
  @test.assert_eq(true, sin(a).data[0].abs() < 1.0e-10)
  @test.assert_eq(true, (cos(a).data[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, tan(a).data[0].abs() < 1.0e-10)
  @test.assert_eq(true, sinh(a).data[0].abs() < 1.0e-10)
  @test.assert_eq(true, (cosh(a).data[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, tanh(a).data[0].abs() < 1.0e-10)
}

///|
test "math_ops: inverse trig" {
  let a = of_array([0.0, 0.5], [2])
  @test.assert_eq(true, asin(a).data[0].abs() < 1.0e-10)
  @test.assert_eq(true, (acos(a).data[0] - @math.PI / 2.0).abs() < 1.0e-10)
  @test.assert_eq(true, atan(a).data[0].abs() < 1.0e-10)
  @test.assert_eq(true, asinh(a).data[0].abs() < 1.0e-10)
  @test.assert_eq(true, acosh(of_array([1.0], [1])).data[0].abs() < 1.0e-10)
  @test.assert_eq(true, atanh(a).data[0].abs() < 1.0e-10)
}

///|
test "math_ops: signum sigmoid relu" {
  let a = of_array([-2.0, 0.0, 3.0], [3])
  let s = signum(a)
  @test.assert_eq(-1.0, s.data[0])
  @test.assert_eq(0.0, s.data[1])
  @test.assert_eq(1.0, s.data[2])
  let sg = sigmoid(of_array([-1.0], [1]))
  @test.assert_eq(
    true,
    (sg.data[0] - 1.0 / (1.0 + @math.exp(1.0))).abs() < 1.0e-10,
  )
  let r = relu(a)
  @test.assert_eq(0.0, r.data[0])
  @test.assert_eq(0.0, r.data[1])
  @test.assert_eq(3.0, r.data[2])
}

///|
test "conv2d_backward basic" {
  let input = of_array(
    [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0],
    [1, 3, 4, 1],
  )
  let kernel = of_array([1.0, 0.0, 0.0, 1.0], [2, 2, 1, 1])
  let output = conv2d(input, kernel, [1, 1], padding=@types.Padding::Valid)
  let grad_out = ones(output.shape)
  let grad_in = conv2d_backward_input(input, kernel, [1, 1], grad_out)
  @test.assert_eq(input.data.length(), grad_in.data.length())
  @test.assert_eq(1.0, grad_in.data[0])
  let grad_k = conv2d_backward_kernel(input, kernel, [1, 1], grad_out)
  @test.assert_eq(kernel.data.length(), grad_k.data.length())
}

///|
test "conv1d_backward basic" {
  let input = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [1, 6, 1])
  let kernel = of_array([1.0, 0.0, 1.0], [3, 1, 1])
  let output = conv1d(input, kernel, [1], padding=@types.Padding::Valid)
  let grad_out = ones(output.shape)
  let grad_in = conv1d_backward_input(input, kernel, [1], grad_out)
  @test.assert_eq(input.data.length(), grad_in.data.length())
  let grad_k = conv1d_backward_kernel(input, kernel, [1], grad_out)
  @test.assert_eq(kernel.data.length(), grad_k.data.length())
}

///|
test "conv3d_backward basic" {
  let input = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0], [1, 2, 2, 2, 1])
  let kernel = of_array([1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0], [
    2, 2, 2, 1, 1,
  ])
  let output = conv3d(input, kernel, [1, 1, 1], padding=@types.Padding::Valid)
  let grad_out = ones(output.shape)
  let grad_in = conv3d_backward_input(input, kernel, [1, 1, 1], grad_out)
  @test.assert_eq(input.data.length(), grad_in.data.length())
  let grad_k = conv3d_backward_kernel(input, kernel, [1, 1, 1], grad_out)
  @test.assert_eq(kernel.data.length(), grad_k.data.length())
}

///|
test "transpose_conv basic" {
  let input2d = of_array([1.0, 2.0, 3.0, 4.0], [1, 2, 2, 1])
  let kernel2d = of_array([1.0, 0.0, 0.0, 1.0], [2, 2, 1, 1])
  let out2d = transpose_conv2d(
    input2d,
    kernel2d,
    [1, 1],
    padding=@types.Padding::Valid,
  )
  @test.assert_eq(1, out2d.shape[0])
  @test.assert_eq(1, out2d.shape[3])
  let input1d = of_array([1.0, 2.0, 3.0], [1, 3, 1])
  let kernel1d = of_array([1.0, 0.0, 1.0], [3, 1, 1])
  let out1d = transpose_conv1d(
    input1d,
    kernel1d,
    [1],
    padding=@types.Padding::Valid,
  )
  @test.assert_eq(1, out1d.shape[0])
  let input3d = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0], [
    1, 2, 2, 2, 1,
  ])
  let kernel3d = of_array([1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0], [
    2, 2, 2, 1, 1,
  ])
  let out3d = transpose_conv3d(
    input3d,
    kernel3d,
    [1, 1, 1],
    padding=@types.Padding::Valid,
  )
  @test.assert_eq(1, out3d.shape[0])
}

///|
test "transpose_conv_backward basic" {
  let input2d = of_array([1.0, 2.0, 3.0, 4.0], [1, 2, 2, 1])
  let kernel2d = of_array([1.0, 0.0, 0.0, 1.0], [2, 2, 1, 1])
  let out2d = transpose_conv2d(
    input2d,
    kernel2d,
    [1, 1],
    padding=@types.Padding::Valid,
  )
  let grad_out = ones(out2d.shape)
  let gi2 = transpose_conv2d_backward_input(input2d, kernel2d, [1, 1], grad_out)
  @test.assert_eq(input2d.data.length(), gi2.data.length())
  let gk2 = transpose_conv2d_backward_kernel(
    input2d,
    kernel2d,
    [1, 1],
    grad_out,
  )
  @test.assert_eq(true, gk2.data.length() > 0)
  let input1d = of_array([1.0, 2.0, 3.0], [1, 3, 1])
  let kernel1d = of_array([1.0, 0.0, 1.0], [3, 1, 1])
  let out1d = transpose_conv1d(
    input1d,
    kernel1d,
    [1],
    padding=@types.Padding::Valid,
  )
  let grad_out1 = ones(out1d.shape)
  let gi1 = transpose_conv1d_backward_input(input1d, kernel1d, [1], grad_out1)
  @test.assert_eq(input1d.data.length(), gi1.data.length())
  let gk1 = transpose_conv1d_backward_kernel(input1d, kernel1d, [1], grad_out1)
  @test.assert_eq(true, gk1.data.length() > 0)
  let input3d = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0], [
    1, 2, 2, 2, 1,
  ])
  let kernel3d = of_array([1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0], [
    2, 2, 2, 1, 1,
  ])
  let out3d = transpose_conv3d(
    input3d,
    kernel3d,
    [1, 1, 1],
    padding=@types.Padding::Valid,
  )
  let grad_out3 = ones(out3d.shape)
  let gi3 = transpose_conv3d_backward_input(
    input3d,
    kernel3d,
    [1, 1, 1],
    grad_out3,
  )
  @test.assert_eq(input3d.data.length(), gi3.data.length())
  let gk3 = transpose_conv3d_backward_kernel(
    input3d,
    kernel3d,
    [1, 1, 1],
    grad_out3,
  )
  @test.assert_eq(true, gk3.data.length() > 0)
}

///|
test "pool_backward basic" {
  let input2d = of_array(
    [
      1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0,
      15.0, 16.0,
    ],
    [1, 4, 4, 1],
  )
  let out2d = max_pool2d(input2d, [2, 2], [2, 2], padding=@types.Padding::Valid)
  let grad_out = ones(out2d.shape)
  let mgi = max_pool2d_backward(
    @types.Padding::Valid,
    input2d,
    [2, 2],
    [2, 2],
    grad_out,
  )
  @test.assert_eq(input2d.data.length(), mgi.data.length())
  let ogi = avg_pool2d_backward(
    @types.Padding::Valid,
    input2d,
    [2, 2],
    [2, 2],
    grad_out,
  )
  @test.assert_eq(input2d.data.length(), ogi.data.length())
  let input1d = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [1, 6, 1])
  let out1d = max_pool1d(input1d, [2], [2], padding=@types.Padding::Valid)
  let grad_out1 = ones(out1d.shape)
  let mgi1 = max_pool1d_backward(
    @types.Padding::Valid,
    input1d,
    [2],
    [2],
    grad_out1,
  )
  @test.assert_eq(input1d.data.length(), mgi1.data.length())
  let ogi1 = avg_pool1d_backward(
    @types.Padding::Valid,
    input1d,
    [2],
    [2],
    grad_out1,
  )
  @test.assert_eq(input1d.data.length(), ogi1.data.length())
  let input3d = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0], [
    1, 2, 2, 2, 1,
  ])
  let out3d = max_pool3d(
    input3d,
    [2, 2, 2],
    [2, 2, 2],
    padding=@types.Padding::Valid,
  )
  let grad_out3 = ones(out3d.shape)
  let mgi3 = max_pool3d_backward(
    @types.Padding::Valid,
    input3d,
    [2, 2, 2],
    [2, 2, 2],
    grad_out3,
  )
  @test.assert_eq(input3d.data.length(), mgi3.data.length())
  let ogi3 = avg_pool3d_backward(
    @types.Padding::Valid,
    input3d,
    [2, 2, 2],
    [2, 2, 2],
    grad_out3,
  )
  @test.assert_eq(input3d.data.length(), ogi3.data.length())
}

///|
test "upsampling2d_backward basic" {
  let input = of_array([1.0, 2.0, 3.0, 4.0], [1, 2, 2, 1])
  let output = upsampling2d(input, [2, 2])
  let grad_out = ones(output.shape)
  let grad_in = upsampling2d_backward(input, [2, 2], grad_out)
  @test.assert_eq(input.data.length(), grad_in.data.length())
  @test.assert_eq(4.0, grad_in.data[0])
}

///|
test "dilated_conv2d_backward basic" {
  let input2d = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0], [
    1, 3, 3, 1,
  ])
  let kernel2d = of_array([1.0, 0.0, 0.0, 1.0], [2, 2, 1, 1])
  let out2d = dilated_conv2d(
    input2d,
    kernel2d,
    [1, 1],
    [2, 2],
    padding=@types.Padding::Valid,
  )
  let grad_out = ones(out2d.shape)
  let gi2 = dilated_conv2d_backward_input(
    input2d,
    kernel2d,
    [1, 1],
    [2, 2],
    grad_out,
  )
  @test.assert_eq(input2d.data.length(), gi2.data.length())
  let gk2 = dilated_conv2d_backward_kernel(
    input2d,
    kernel2d,
    [1, 1],
    [2, 2],
    grad_out,
  )
  @test.assert_eq(true, gk2.data.length() > 0)
}

///|
test "dilated_conv1d_backward basic" {
  let input1d = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [1, 6, 1])
  let kernel1d = of_array([1.0, 0.0, 1.0], [3, 1, 1])
  let out1d = dilated_conv1d(
    input1d,
    kernel1d,
    [1],
    [1, 1],
    padding=@types.Padding::Valid,
  )
  let grad_out1 = ones(out1d.shape)
  let gi1 = dilated_conv1d_backward_input(
    input1d,
    kernel1d,
    [1],
    [1, 1],
    grad_out1,
  )
  @test.assert_eq(input1d.data.length(), gi1.data.length())
  let gk1 = dilated_conv1d_backward_kernel(
    input1d,
    kernel1d,
    [1],
    [1, 1],
    grad_out1,
  )
  @test.assert_eq(true, gk1.data.length() > 0)
}

///|
test "dilated_conv3d_backward basic" {
  let input3d = of_array(
    [
      1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0,
      15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0,
    ],
    [1, 3, 3, 3, 1],
  )
  let kernel3d = of_array([1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0], [
    2, 2, 2, 1, 1,
  ])
  let out3d = dilated_conv3d(
    input3d,
    kernel3d,
    [1, 1, 1],
    [2, 2, 2],
    padding=@types.Padding::Valid,
  )
  let grad_out3 = ones(out3d.shape)
  let gi3 = dilated_conv3d_backward_input(
    input3d,
    kernel3d,
    [1, 1, 1],
    [2, 2, 2],
    grad_out3,
  )
  @test.assert_eq(input3d.data.length(), gi3.data.length())
  let gk3 = dilated_conv3d_backward_kernel(
    input3d,
    kernel3d,
    [1, 1, 1],
    [2, 2, 2],
    grad_out3,
  )
  @test.assert_eq(true, gk3.data.length() > 0)
}

///|
test "arithmetic: fma scalar_sub scalar_div scalar_pow pow_scalar" {
  let x = of_array([1.0, 2.0, 3.0], [3])
  let y = of_array([4.0, 5.0, 6.0], [3])
  let z = of_array([0.1, 0.1, 0.1], [3])
  let r = fma(x, y, z)
  @test.assert_eq(r.data[0], 4.1)
  @test.assert_eq(r.data[1], 10.1)
  @test.assert_eq(r.data[2], 18.1)
  let sr = scalar_sub(10.0, x)
  @test.assert_eq(sr.data[0], 9.0)
  @test.assert_eq(sr.data[2], 7.0)
  let dr = scalar_div(12.0, x)
  @test.assert_eq(dr.data[0], 12.0)
  @test.assert_eq(dr.data[1], 6.0)
  let pr = scalar_pow(2.0, x)
  @test.assert_eq(pr.data[0], 2.0)
  @test.assert_eq(pr.data[1], 4.0)
  @test.assert_eq(pr.data[2], 8.0)
  let ps = pow_scalar(x, 2.0)
  @test.assert_eq(ps.data[0], 1.0)
  @test.assert_eq(ps.data[1], 4.0)
  @test.assert_eq(ps.data[2], 9.0)
}

///|
test "reduction: min_ max_ mean_ l1norm_ l2norm_" {
  let x = of_array([3.0, 1.0, 4.0, 1.0, 5.0, 9.0], [6])
  @test.assert_eq(min_(x), 1.0)
  @test.assert_eq(max_(x), 9.0)
  @test.assert_eq(mean_(x), 23.0 / 6.0)
  @test.assert_eq(l1norm_(x), 23.0)
  @test.assert_eq(l2norm_sqr_(x), 3.0 * 3.0 + 1.0 + 16.0 + 1.0 + 25.0 + 81.0)
  @test.assert_eq(l2norm_(of_array([3.0, 4.0], [2])), 5.0)
}

///|
test "reduction: min max along axis" {
  let x = of_array([3.0, 1.0, 4.0, 1.0, 5.0, 9.0], [2, 3])
  let mn = min(x, axis=0, keep_dims=false)
  @test.assert_eq(mn.data[0], 1.0)
  @test.assert_eq(mn.data[1], 1.0)
  @test.assert_eq(mn.data[2], 4.0)
  let mx = max(x, axis=1, keep_dims=false)
  @test.assert_eq(mx.data[0], 4.0)
  @test.assert_eq(mx.data[1], 9.0)
  let mn_all = min(x)
  @test.assert_eq(mn_all.data[0], 1.0)
  let mx_all = max(x)
  @test.assert_eq(mx_all.data[0], 9.0)
}

///|
test "real_ops: atan2 scalar_atan2 atan2_scalar" {
  let y = of_array([0.0, 1.0, 0.0], [3])
  let x = of_array([1.0, 1.0, -1.0], [3])
  let r = atan2(y, x)
  @test.assert_eq(r.data[0], 0.0)
  @test.assert_eq(r.data[1], 0.7853981633974483)
  let sa = scalar_atan2(1.0, x)
  @test.assert_eq(sa.data[0], 0.7853981633974483)
  let as_ = atan2_scalar(y, 1.0)
  @test.assert_eq(as_.data[0], 0.0)
  @test.assert_eq(as_.data[1], 0.7853981633974483)
}

///|
test "real_ops: clip_by_value clip_by_l2norm" {
  let x = of_array([-5.0, 0.0, 5.0], [3])
  let clipped = clip_by_value(x, amin=-1.0, amax=1.0)
  @test.assert_eq(clipped.data[0], -1.0)
  @test.assert_eq(clipped.data[1], 0.0)
  @test.assert_eq(clipped.data[2], 1.0)
  let v = of_array([3.0, 4.0], [2])
  let cl2 = clip_by_l2norm(3.0, v)
  @test.assert_eq(l2norm_(cl2), 3.0)
  let small = of_array([0.3, 0.4], [2])
  let cl2s = clip_by_l2norm(10.0, small)
  @test.assert_eq(cl2s.data[0], 0.3)
}

///|
test "real_ops: sum_slices log_sum_exp_ log_sum_exp" {
  let x = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let ss = sum_slices(x, axis=0)
  @test.assert_eq(ss.data[0], 5.0)
  @test.assert_eq(ss.data[1], 7.0)
  @test.assert_eq(ss.data[2], 9.0)
  let lse_ = log_sum_exp_(of_array([0.0, 0.0], [2]))
  @test.assert_eq(lse_, 0.6931471805599453)
  let lse = log_sum_exp(x, axis=0, keep_dims=false)
  @test.assert_eq(lse.data.length(), 3)
  let lse_all = log_sum_exp(x)
  @test.assert_eq(lse_all.data.length(), 1)
}

///|
test "real_ops: softmax approx_equal" {
  let x = of_array([1.0, 2.0, 3.0], [3])
  let sm = softmax(x)
  let s = sm.data[0] + sm.data[1] + sm.data[2]
  @test.assert_eq((s - 1.0).abs() < 1.0e-10, true)
  let sm2 = softmax(x, axis=0)
  let s2 = sm2.data[0] + sm2.data[1] + sm2.data[2]
  @test.assert_eq((s2 - 1.0).abs() < 1.0e-10, true)
  let eq = approx_equal_scalar(of_array([1.0, 1.0, 1.0], [3]), 1.0)
  @test.assert_eq(eq, true)
  let neq = approx_equal_scalar(of_array([1.0, 2.0, 1.0], [3]), 1.0)
  @test.assert_eq(neq, false)
  let aee = approx_elt_equal(
    of_array([1.0, 2.0], [2]),
    of_array([1.0, 3.0], [2]),
  )
  @test.assert_eq(aee.data[0], 1.0)
  @test.assert_eq(aee.data[1], 0.0)
  let aees = approx_elt_equal_scalar(
    of_array([1.0, 1.001, 5.0], [3]),
    1.0,
    eps=0.01,
  )
  @test.assert_eq(aees.data[0], 1.0)
  @test.assert_eq(aees.data[1], 1.0)
  @test.assert_eq(aees.data[2], 0.0)
}

///|
test "perf: map_elem_inplace" {
  let x = of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let y = map_elem_inplace(x, fn(v) { v * v })
  @test.assert_eq(y.data[0], 1.0)
  @test.assert_eq(y.data[1], 4.0)
  @test.assert_eq(y.data[2], 9.0)
  @test.assert_eq(y.data[3], 16.0)
  // Verify it's the same array (in-place)
  @test.assert_eq(x.data[0], 1.0)
  @test.assert_eq(x.data[3], 16.0)
}

///|
test "perf: add_scalar_inplace" {
  let x = of_array([1.0, 2.0, 3.0], [3])
  let y = add_scalar_inplace(x, 10.0)
  @test.assert_eq(y.data[0], 11.0)
  @test.assert_eq(y.data[1], 12.0)
  @test.assert_eq(y.data[2], 13.0)
  // Verify in-place
  @test.assert_eq(x.data[0], 11.0)
}

///|
test "perf: mul_scalar_inplace" {
  let x = of_array([1.0, 2.0, 3.0], [3])
  let y = mul_scalar_inplace(x, 2.0)
  @test.assert_eq(y.data[0], 2.0)
  @test.assert_eq(y.data[1], 4.0)
  @test.assert_eq(y.data[2], 6.0)
  // Verify in-place
  @test.assert_eq(x.data[1], 4.0)
}

///|
test "perf: add_inplace" {
  let x = of_array([1.0, 2.0, 3.0], [3])
  let y = of_array([10.0, 20.0, 30.0], [3])
  let z = add_inplace(x, y)
  @test.assert_eq(z.data[0], 11.0)
  @test.assert_eq(z.data[1], 22.0)
  @test.assert_eq(z.data[2], 33.0)
  // Verify in-place
  @test.assert_eq(x.data[0], 11.0)
}

///|
test "perf: fma single-pass" {
  let x = of_array([1.0, 2.0, 3.0], [3])
  let y = of_array([4.0, 5.0, 6.0], [3])
  let z = of_array([0.1, 0.2, 0.3], [3])
  let r = fma(x, y, z)
  @test.assert_eq(r.data[0], 4.1)
  @test.assert_eq(r.data[1], 10.2)
  @test.assert_eq(r.data[2], 18.3)
}

///|
test "perf: same-shape add fast path" {
  let x = of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let y = of_array([5.0, 6.0, 7.0, 8.0], [2, 2])
  let r = add(x, y)
  @test.assert_eq(r.data[0], 6.0)
  @test.assert_eq(r.data[1], 8.0)
  @test.assert_eq(r.data[2], 10.0)
  @test.assert_eq(r.data[3], 12.0)
}

///|
test "perf: same-shape mul fast path" {
  let x = of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let y = of_array([2.0, 3.0, 4.0, 5.0], [2, 2])
  let r = mul(x, y)
  @test.assert_eq(r.data[0], 2.0)
  @test.assert_eq(r.data[1], 6.0)
  @test.assert_eq(r.data[2], 12.0)
  @test.assert_eq(r.data[3], 20.0)
}

///|
test "perf: matmul i-p-j order" {
  let a = of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let b = of_array([5.0, 6.0, 7.0, 8.0], [2, 2])
  let c = dot(a, b)
  // [1*5+2*7, 1*6+2*8] = [19, 22]
  // [3*5+4*7, 3*6+4*8] = [43, 50]
  @test.assert_eq(c.data[0], 19.0)
  @test.assert_eq(c.data[1], 22.0)
  @test.assert_eq(c.data[2], 43.0)
  @test.assert_eq(c.data[3], 50.0)
}

///|
test "perf: get 1D fast path" {
  let x = of_array([1.0, 2.0, 3.0, 4.0, 5.0], [5])
  @test.assert_eq(get(x, [0]), 1.0)
  @test.assert_eq(get(x, [4]), 5.0)
  @test.assert_eq(get(x, [2]), 3.0)
}

///|
test "perf: get 2D fast path" {
  let x = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  @test.assert_eq(get(x, [0, 0]), 1.0)
  @test.assert_eq(get(x, [0, 2]), 3.0)
  @test.assert_eq(get(x, [1, 0]), 4.0)
  @test.assert_eq(get(x, [1, 2]), 6.0)
}

///|
/// T111: transpose twice returns original (transpose²=I)
test "invariance: transpose twice is identity" {
  let x = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let tt = transpose(transpose(x))
  @test.assert_eq(tt.shape[0], 2)
  @test.assert_eq(tt.shape[1], 3)
  for i in 0..<6 {
    @test.assert_eq(tt.data[i], x.data[i])
  }
}

///|
/// T111: reshape preserves data
test "invariance: reshape preserves total" {
  let x = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let y = reshape(x, [3, 2])
  @test.assert_eq(numel(y), numel(x))
  for i in 0..<6 {
    @test.assert_eq(y.data[i], x.data[i])
  }
}

///|
/// T111: flatten then reshape restores data
test "invariance: flatten then reshape" {
  let x = of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let f = flatten(x)
  @test.assert_eq(f.shape.length(), 1)
  @test.assert_eq(f.shape[0], 6)
  let r = reshape(f, [2, 3])
  for i in 0..<6 {
    @test.assert_eq(r.data[i], x.data[i])
  }
}
