///|
/// Generic stack with dynamic array backing.
pub struct Stack[T] {
  used : Ref[Int]
  data : Ref[Array[T]]
}

///|
/// Create a new empty stack.
pub fn[T] Stack::new() -> Stack[T] {
  { used: Ref(0), data: Ref([]) }
}

///|
/// Push an element onto the stack.
pub fn[T] Stack::push(s : Stack[T], x : T) -> Unit {
  s.data.val.push(x)
  s.used.val = s.used.val + 1
}

///|
/// Pop an element from the stack.
pub fn[T] Stack::pop(s : Stack[T]) -> T? {
  if s.used.val == 0 {
    None
  } else {
    let v = s.data.val.remove(s.used.val - 1)
    s.used.val = s.used.val - 1
    Some(v)
  }
}

///|
/// Peek at the top element without removing it.
pub fn[T] Stack::peek(s : Stack[T]) -> T? {
  if s.used.val == 0 {
    None
  } else {
    Some(s.data.val[s.used.val - 1])
  }
}

///|
/// Check if the stack is empty.
pub fn[T] Stack::is_empty(s : Stack[T]) -> Bool {
  s.used.val == 0
}

///|
/// Get the number of elements in the stack.
pub fn[T] Stack::length(s : Stack[T]) -> Int {
  s.used.val
}

///|
/// Convert the stack to an array.
pub fn[T] Stack::to_array(s : Stack[T]) -> Array[T] {
  s.data.val.copy()
}
