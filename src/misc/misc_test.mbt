///|
test "stack_basic" {
  let s = Stack::new()
  @test.assert_eq(true, Stack::is_empty(s))
  @test.assert_eq(0, Stack::length(s))
  Stack::push(s, 1)
  Stack::push(s, 2)
  Stack::push(s, 3)
  @test.assert_eq(false, Stack::is_empty(s))
  @test.assert_eq(3, Stack::length(s))
  @test.assert_eq(Some(3), Stack::peek(s))
  @test.assert_eq(Some(3), Stack::pop(s))
  @test.assert_eq(Some(2), Stack::pop(s))
  @test.assert_eq(Some(1), Stack::pop(s))
  @test.assert_eq(None, Stack::pop(s))
  @test.assert_eq(true, Stack::is_empty(s))
}

///|
test "stack_to_array" {
  let s = Stack::new()
  Stack::push(s, 10)
  Stack::push(s, 20)
  Stack::push(s, 30)
  let arr = Stack::to_array(s)
  @test.assert_eq(3, arr.length())
  @test.assert_eq(10, arr[0])
  @test.assert_eq(20, arr[1])
  @test.assert_eq(30, arr[2])
}

///|
test "stack_peek_empty" {
  let s : Stack[Int] = Stack::new()
  @test.assert_eq(None, Stack::peek(s))
}

///|
test "heap_basic" {
  let h = Heap::new(fn(a : Int, b : Int) -> Int { a - b })
  @test.assert_eq(true, Heap::is_empty(h))
  @test.assert_eq(0, Heap::size(h))
  Heap::push(h, 5)
  Heap::push(h, 3)
  Heap::push(h, 8)
  Heap::push(h, 1)
  Heap::push(h, 7)
  @test.assert_eq(5, Heap::size(h))
  @test.assert_eq(1, Heap::peek(h))
  @test.assert_eq(1, Heap::pop(h))
  @test.assert_eq(3, Heap::pop(h))
  @test.assert_eq(5, Heap::pop(h))
  @test.assert_eq(7, Heap::pop(h))
  @test.assert_eq(8, Heap::pop(h))
  @test.assert_eq(true, Heap::is_empty(h))
}

///|
test "heap_to_array" {
  let h = Heap::new(fn(a : Int, b : Int) -> Int { a - b })
  Heap::push(h, 3)
  Heap::push(h, 1)
  Heap::push(h, 2)
  let arr = Heap::to_array(h)
  @test.assert_eq(3, arr.length())
}

///|
test "heap_max_heap" {
  let h = Heap::new(fn(a : Int, b : Int) -> Int { b - a })
  Heap::push(h, 5)
  Heap::push(h, 3)
  Heap::push(h, 8)
  Heap::push(h, 1)
  @test.assert_eq(8, Heap::pop(h))
  @test.assert_eq(5, Heap::pop(h))
  @test.assert_eq(3, Heap::pop(h))
  @test.assert_eq(1, Heap::pop(h))
}

///|
test "countmin_basic" {
  let cms = cms_init_lw(3, 10)
  cms_incr(cms, 1)
  cms_incr(cms, 1)
  cms_incr(cms, 2)
  cms_incr(cms, 1)
  cms_incr(cms, 3)
  let c1 = cms_count(cms, 1)
  let c2 = cms_count(cms, 2)
  let c3 = cms_count(cms, 3)
  let c4 = cms_count(cms, 999)
  @test.assert_eq(true, c1 >= 3)
  @test.assert_eq(true, c2 >= 1)
  @test.assert_eq(true, c3 >= 1)
  @test.assert_eq(true, c4 >= 0)
}

///|
test "utils_longest_string" {
  let arr = ["hello", "world!", "foo", "barbaz"]
  @test.assert_eq(6, longest_string(arr))
  @test.assert_eq(0, longest_string([]))
}

///|
test "utils_pad_string_left" {
  let s = pad_string("hi", 5, pad_left())
  @test.assert_eq("   hi", s)
}

///|
test "utils_pad_string_right" {
  let s = pad_string("hi", 5, pad_right())
  @test.assert_eq("hi   ", s)
}

///|
test "utils_pad_string_center" {
  let s = pad_string("hi", 6, pad_center())
  @test.assert_eq("  hi  ", s)
}

///|
test "utils_pad_string_noop" {
  let s = pad_string("hello", 3, pad_left())
  @test.assert_eq("hello", s)
}

///|
test "utils_pad_strings" {
  let arr = ["a", "bb", "ccc"]
  let padded = pad_strings(arr, 3, pad_right())
  @test.assert_eq("a  ", padded[0])
  @test.assert_eq("bb ", padded[1])
  @test.assert_eq("ccc", padded[2])
}

///|
test "utils_approx_equal" {
  @test.assert_eq(true, approx_equal(1.0, 1.0001, 0.001))
  @test.assert_eq(false, approx_equal(1.0, 2.0, 0.001))
  @test.assert_eq(true, approx_equal(0.0, 0.0, 0.0001))
}

///|
test "utils_repeat_string" {
  @test.assert_eq("abcabcabc", repeat_string("abc", 3))
  @test.assert_eq("", repeat_string("abc", 0))
  @test.assert_eq("x", repeat_string("x", 1))
}

///|
test "dataframe_float_column" {
  let col = float_column("x", [1.0, 2.0, 3.0])
  @test.assert_eq("x", col.name)
  @test.assert_eq(3, col.float_data.length())
  @test.assert_eq(1.0, col.float_data[0])
}

///|
test "dataframe_int_column" {
  let col = int_column("n", [10, 20, 30])
  @test.assert_eq("n", col.name)
  @test.assert_eq(3, col.int_data.length())
  @test.assert_eq(20, col.int_data[1])
}

///|
test "dataframe_string_column" {
  let col = string_column("name", ["alice", "bob"])
  @test.assert_eq("name", col.name)
  @test.assert_eq(2, col.string_data.length())
  @test.assert_eq("alice", col.string_data[0])
}

///|
test "dataframe_basic" {
  let c1 = float_column("x", [1.0, 2.0, 3.0])
  let c2 = float_column("y", [4.0, 5.0, 6.0])
  let df = make_dataframe([c1, c2])
  @test.assert_eq(3, num_rows(df))
  @test.assert_eq(2, num_cols(df))
  let names = col_names(df)
  @test.assert_eq("x", names[0])
  @test.assert_eq("y", names[1])
}

///|
test "dataframe_stats" {
  let c1 = float_column("x", [1.0, 2.0, 3.0, 4.0])
  let df = make_dataframe([c1])
  @test.assert_eq(2.5, col_mean(df, "x"))
  @test.assert_eq(10.0, col_sum(df, "x"))
  @test.assert_eq(1.0, col_min(df, "x"))
  @test.assert_eq(4.0, col_max(df, "x"))
}

///|
test "dataframe_get_column" {
  let c1 = int_column("a", [1, 2])
  let c2 = string_column("b", ["x", "y"])
  let df = make_dataframe([c1, c2])
  let col = get_column(df, "b")
  @test.assert_eq("b", col.name)
  @test.assert_eq("x", col.string_data[0])
}

///|
test "dataframe_to_string" {
  let c1 = float_column("x", [1.0])
  let df = make_dataframe([c1])
  let s = dataframe_to_string(df)
  @test.assert_eq(true, s.length() > 0)
}

///|
test "log_basic" {
  let logger = make_logger()
  @test.assert_eq(true, should_print(logger, level_info()))
  @test.assert_eq(true, should_print(logger, level_warn()))
  @test.assert_eq(true, should_print(logger, level_error()))
  @test.assert_eq(true, should_print(logger, level_fatal()))
  @test.assert_eq(false, should_print(logger, level_debug()))
}

///|
test "log_set_level" {
  let logger = make_logger()
  set_level(logger, level_debug())
  @test.assert_eq(true, should_print(logger, level_debug()))
  @test.assert_eq(true, should_print(logger, level_info()))
  set_level(logger, level_error())
  @test.assert_eq(false, should_print(logger, level_info()))
  @test.assert_eq(false, should_print(logger, level_warn()))
  @test.assert_eq(true, should_print(logger, level_error()))
  @test.assert_eq(true, should_print(logger, level_fatal()))
}

///|
test "log_format_msg" {
  let logger = make_logger()
  let msg = format_msg(logger, level_info(), "hello world")
  @test.assert_eq("INFO : hello world", msg)
  let msg2 = format_msg(logger, level_debug(), "debug msg")
  @test.assert_eq("", msg2)
}

///|
test "log_level_to_str" {
  @test.assert_eq("DEBUG", level_to_str(level_debug()))
  @test.assert_eq("INFO", level_to_str(level_info()))
  @test.assert_eq("WARN", level_to_str(level_warn()))
  @test.assert_eq("ERROR", level_to_str(level_error()))
  @test.assert_eq("FATAL", level_to_str(level_fatal()))
}

///|
test "log_set_colorful" {
  let logger = make_logger()
  set_colorful(logger, false)
  set_colorful(logger, true)
  @test.assert_eq(true, should_print(logger, level_info()))
}

///|
test "approx_equal_rel: large and small values" {
  // Large values: relative error is small
  @test.assert_eq(true, approx_equal_rel(1.0e10, 1.0e10 + 1.0, 1.0e-8))
  // Large values: relative error is large
  @test.assert_eq(false, approx_equal_rel(1.0e10, 2.0e10, 1.0e-8))
  // Both near zero: the 1+ denominator makes this true (graceful handling)
  @test.assert_eq(true, approx_equal_rel(0.0, 0.0, 1.0e-8))
  // Moderate values
  @test.assert_eq(true, approx_equal_rel(1.0, 1.0 + 1.0e-10, 1.0e-8))
  @test.assert_eq(false, approx_equal_rel(1.0, 1.5, 1.0e-8))
}
