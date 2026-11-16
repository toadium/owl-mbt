///|
test "stack_basic" {
  let s = @misc.Stack::new()
  @test.assert_eq(true, @misc.Stack::is_empty(s))
  @test.assert_eq(0, @misc.Stack::length(s))
  @misc.Stack::push(s, 1)
  @misc.Stack::push(s, 2)
  @misc.Stack::push(s, 3)
  @test.assert_eq(false, @misc.Stack::is_empty(s))
  @test.assert_eq(3, @misc.Stack::length(s))
  @test.assert_eq(Some(3), @misc.Stack::peek(s))
  @test.assert_eq(Some(3), @misc.Stack::pop(s))
  @test.assert_eq(Some(2), @misc.Stack::pop(s))
  @test.assert_eq(Some(1), @misc.Stack::pop(s))
  @test.assert_eq(None, @misc.Stack::pop(s))
  @test.assert_eq(true, @misc.Stack::is_empty(s))
}

///|
test "stack_to_array" {
  let s = @misc.Stack::new()
  @misc.Stack::push(s, 10)
  @misc.Stack::push(s, 20)
  @misc.Stack::push(s, 30)
  let arr = @misc.Stack::to_array(s)
  @test.assert_eq(3, arr.length())
  @test.assert_eq(10, arr[0])
  @test.assert_eq(20, arr[1])
  @test.assert_eq(30, arr[2])
}

///|
test "stack_peek_empty" {
  let s : @misc.Stack[Int32] = @misc.Stack::new()
  @test.assert_eq(None, @misc.Stack::peek(s))
}

///|
test "heap_basic" {
  let h = @misc.Heap::new(fn(a : Int32, b : Int32) -> Int32 { a - b })
  @test.assert_eq(true, @misc.Heap::is_empty(h))
  @test.assert_eq(0, @misc.Heap::size(h))
  @misc.Heap::push(h, 5)
  @misc.Heap::push(h, 3)
  @misc.Heap::push(h, 8)
  @misc.Heap::push(h, 1)
  @misc.Heap::push(h, 7)
  @test.assert_eq(5, @misc.Heap::size(h))
  @test.assert_eq(1, @misc.Heap::peek(h))
  @test.assert_eq(1, @misc.Heap::pop(h))
  @test.assert_eq(3, @misc.Heap::pop(h))
  @test.assert_eq(5, @misc.Heap::pop(h))
  @test.assert_eq(7, @misc.Heap::pop(h))
  @test.assert_eq(8, @misc.Heap::pop(h))
  @test.assert_eq(true, @misc.Heap::is_empty(h))
}

///|
test "heap_to_array" {
  let h = @misc.Heap::new(fn(a : Int32, b : Int32) -> Int32 { a - b })
  @misc.Heap::push(h, 3)
  @misc.Heap::push(h, 1)
  @misc.Heap::push(h, 2)
  let arr = @misc.Heap::to_array(h)
  @test.assert_eq(3, arr.length())
}

///|
test "heap_max_heap" {
  let h = @misc.Heap::new(fn(a : Int32, b : Int32) -> Int32 { b - a })
  @misc.Heap::push(h, 5)
  @misc.Heap::push(h, 3)
  @misc.Heap::push(h, 8)
  @misc.Heap::push(h, 1)
  @test.assert_eq(8, @misc.Heap::pop(h))
  @test.assert_eq(5, @misc.Heap::pop(h))
  @test.assert_eq(3, @misc.Heap::pop(h))
  @test.assert_eq(1, @misc.Heap::pop(h))
}

///|
test "countmin_basic" {
  let cms = @misc.cms_init_lw(3, 10)
  @misc.cms_incr(cms, 1)
  @misc.cms_incr(cms, 1)
  @misc.cms_incr(cms, 2)
  @misc.cms_incr(cms, 1)
  @misc.cms_incr(cms, 3)
  let c1 = @misc.cms_count(cms, 1)
  let c2 = @misc.cms_count(cms, 2)
  let c3 = @misc.cms_count(cms, 3)
  let c4 = @misc.cms_count(cms, 999)
  @test.assert_eq(true, c1 >= 3)
  @test.assert_eq(true, c2 >= 1)
  @test.assert_eq(true, c3 >= 1)
  @test.assert_eq(true, c4 >= 0)
}

///|
test "utils_longest_string" {
  let arr = ["hello", "world!", "foo", "barbaz"]
  @test.assert_eq(6, @misc.longest_string(arr))
  @test.assert_eq(0, @misc.longest_string([]))
}

///|
test "utils_pad_string_left" {
  let s = @misc.pad_string("hi", 5, @misc.pad_left())
  @test.assert_eq("   hi", s)
}

///|
test "utils_pad_string_right" {
  let s = @misc.pad_string("hi", 5, @misc.pad_right())
  @test.assert_eq("hi   ", s)
}

///|
test "utils_pad_string_center" {
  let s = @misc.pad_string("hi", 6, @misc.pad_center())
  @test.assert_eq("  hi  ", s)
}

///|
test "utils_pad_string_noop" {
  let s = @misc.pad_string("hello", 3, @misc.pad_left())
  @test.assert_eq("hello", s)
}

///|
test "utils_pad_strings" {
  let arr = ["a", "bb", "ccc"]
  let padded = @misc.pad_strings(arr, 3, @misc.pad_right())
  @test.assert_eq("a  ", padded[0])
  @test.assert_eq("bb ", padded[1])
  @test.assert_eq("ccc", padded[2])
}

///|
test "utils_approx_equal" {
  @test.assert_eq(true, @misc.approx_equal(1.0, 1.0001, 0.001))
  @test.assert_eq(false, @misc.approx_equal(1.0, 2.0, 0.001))
  @test.assert_eq(true, @misc.approx_equal(0.0, 0.0, 0.0001))
}

///|
test "utils_repeat_string" {
  @test.assert_eq("abcabcabc", @misc.repeat_string("abc", 3))
  @test.assert_eq("", @misc.repeat_string("abc", 0))
  @test.assert_eq("x", @misc.repeat_string("x", 1))
}

///|
test "dataframe_float_column" {
  let col = @misc.float_column("x", [1.0, 2.0, 3.0])
  @test.assert_eq("x", col.name)
  @test.assert_eq(3, col.float_data.length())
  @test.assert_eq(1.0, col.float_data[0])
}

///|
test "dataframe_int_column" {
  let col = @misc.int_column("n", [10, 20, 30])
  @test.assert_eq("n", col.name)
  @test.assert_eq(3, col.int_data.length())
  @test.assert_eq(20, col.int_data[1])
}

///|
test "dataframe_string_column" {
  let col = @misc.string_column("name", ["alice", "bob"])
  @test.assert_eq("name", col.name)
  @test.assert_eq(2, col.string_data.length())
  @test.assert_eq("alice", col.string_data[0])
}

///|
test "dataframe_basic" {
  let c1 = @misc.float_column("x", [1.0, 2.0, 3.0])
  let c2 = @misc.float_column("y", [4.0, 5.0, 6.0])
  let df = @misc.make_dataframe([c1, c2])
  @test.assert_eq(3, @misc.num_rows(df))
  @test.assert_eq(2, @misc.num_cols(df))
  let names = @misc.col_names(df)
  @test.assert_eq("x", names[0])
  @test.assert_eq("y", names[1])
}

///|
test "dataframe_stats" {
  let c1 = @misc.float_column("x", [1.0, 2.0, 3.0, 4.0])
  let df = @misc.make_dataframe([c1])
  @test.assert_eq(2.5, @misc.col_mean(df, "x"))
  @test.assert_eq(10.0, @misc.col_sum(df, "x"))
  @test.assert_eq(1.0, @misc.col_min(df, "x"))
  @test.assert_eq(4.0, @misc.col_max(df, "x"))
}

///|
test "dataframe_get_column" {
  let c1 = @misc.int_column("a", [1, 2])
  let c2 = @misc.string_column("b", ["x", "y"])
  let df = @misc.make_dataframe([c1, c2])
  let col = @misc.get_column(df, "b")
  @test.assert_eq("b", col.name)
  @test.assert_eq("x", col.string_data[0])
}

///|
test "dataframe_to_string" {
  let c1 = @misc.float_column("x", [1.0])
  let df = @misc.make_dataframe([c1])
  let s = @misc.dataframe_to_string(df)
  @test.assert_eq(true, s.length() > 0)
}

///|
test "log_basic" {
  let logger = @misc.make_logger()
  @test.assert_eq(true, @misc.should_print(logger, @misc.level_info()))
  @test.assert_eq(true, @misc.should_print(logger, @misc.level_warn()))
  @test.assert_eq(true, @misc.should_print(logger, @misc.level_error()))
  @test.assert_eq(true, @misc.should_print(logger, @misc.level_fatal()))
  @test.assert_eq(false, @misc.should_print(logger, @misc.level_debug()))
}

///|
test "log_set_level" {
  let logger = @misc.make_logger()
  @misc.set_level(logger, @misc.level_debug())
  @test.assert_eq(true, @misc.should_print(logger, @misc.level_debug()))
  @test.assert_eq(true, @misc.should_print(logger, @misc.level_info()))
  @misc.set_level(logger, @misc.level_error())
  @test.assert_eq(false, @misc.should_print(logger, @misc.level_info()))
  @test.assert_eq(false, @misc.should_print(logger, @misc.level_warn()))
  @test.assert_eq(true, @misc.should_print(logger, @misc.level_error()))
  @test.assert_eq(true, @misc.should_print(logger, @misc.level_fatal()))
}

///|
test "log_format_msg" {
  let logger = @misc.make_logger()
  let msg = @misc.format_msg(logger, @misc.level_info(), "hello world")
  @test.assert_eq("INFO : hello world", msg)
  let msg2 = @misc.format_msg(logger, @misc.level_debug(), "debug msg")
  @test.assert_eq("", msg2)
}

///|
test "log_level_to_str" {
  @test.assert_eq("DEBUG", @misc.level_to_str(@misc.level_debug()))
  @test.assert_eq("INFO", @misc.level_to_str(@misc.level_info()))
  @test.assert_eq("WARN", @misc.level_to_str(@misc.level_warn()))
  @test.assert_eq("ERROR", @misc.level_to_str(@misc.level_error()))
  @test.assert_eq("FATAL", @misc.level_to_str(@misc.level_fatal()))
}

///|
test "log_set_colorful" {
  let logger = @misc.make_logger()
  @misc.set_colorful(logger, false)
  @misc.set_colorful(logger, true)
  @test.assert_eq(true, @misc.should_print(logger, @misc.level_info()))
}

///|
test "approx_equal_rel: large and small values" {
  // Large values: relative error is small
  @test.assert_eq(true, @misc.approx_equal_rel(1.0e10, 1.0e10 + 1.0, 1.0e-8))
  // Large values: relative error is large
  @test.assert_eq(false, @misc.approx_equal_rel(1.0e10, 2.0e10, 1.0e-8))
  // Both near zero: the 1+ denominator makes this true (graceful handling)
  @test.assert_eq(true, @misc.approx_equal_rel(0.0, 0.0, 1.0e-8))
  // Moderate values
  @test.assert_eq(true, @misc.approx_equal_rel(1.0, 1.0 + 1.0e-10, 1.0e-8))
  @test.assert_eq(false, @misc.approx_equal_rel(1.0, 1.5, 1.0e-8))
}
