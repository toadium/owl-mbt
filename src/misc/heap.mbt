///|
/// Min-heap with comparison function.
pub struct Heap[T] {
  used : Ref[Int]
  data : Ref[Array[T]]
  cmp : (T, T) -> Int
}

///|
/// Create a new empty heap with a comparison function.
pub fn[T] Heap::new(cmp : (T, T) -> Int) -> Heap[T] {
  { used: Ref(0), data: Ref([]), cmp }
}

///|
/// Get the number of elements in the heap.
pub fn[T] Heap::size(h : Heap[T]) -> Int {
  h.used.val
}

///|
/// Check if the heap is empty.
pub fn[T] Heap::is_empty(h : Heap[T]) -> Bool {
  h.used.val == 0
}

///|
fn _left_son(pos : Int) -> Int {
  pos * 2 + 1
}

///|
fn _right_son(pos : Int) -> Int {
  pos * 2 + 2
}

///|
fn _parent(pos : Int) -> Int {
  (pos - 1) / 2
}

///|
/// Push an element onto the heap.
pub fn[T] Heap::push(h : Heap[T], x : T) -> Unit {
  h.data.val.push(x)
  let pos = h.used.val
  h.used.val = pos + 1
  let mut i = pos
  while i > 0 {
    let par = _parent(i)
    if (h.cmp)(h.data.val[i], h.data.val[par]) < 0 {
      let tmp = h.data.val[i]
      h.data.val[i] = h.data.val[par]
      h.data.val[par] = tmp
      i = par
    } else {
      break
    }
  }
}

///|
/// Pop the minimum element from the heap.
pub fn[T] Heap::pop(h : Heap[T]) -> T raise {
  if h.used.val == 0 {
    raise @types.OwlError::InvalidArgument("Heap::pop: heap is empty")
  }
  let x = h.data.val[0]
  h.used.val = h.used.val - 1
  h.data.val[0] = h.data.val[h.used.val]
  ignore(h.data.val.remove(h.used.val))
  let mut pos = 0
  let mut again = true
  while again {
    let mut small = pos
    let left = _left_son(pos)
    let right = _right_son(pos)
    if left < h.used.val && (h.cmp)(h.data.val[left], h.data.val[small]) < 0 {
      small = left
    }
    if right < h.used.val && (h.cmp)(h.data.val[right], h.data.val[small]) < 0 {
      small = right
    }
    if pos == small {
      again = false
    } else {
      let tmp = h.data.val[pos]
      h.data.val[pos] = h.data.val[small]
      h.data.val[small] = tmp
      pos = small
    }
  }
  x
}

///|
/// Peek at the minimum element without removing it.
pub fn[T] Heap::peek(h : Heap[T]) -> T raise {
  if h.used.val == 0 {
    raise @types.OwlError::InvalidArgument("Heap::peek: heap is empty")
  }
  h.data.val[0]
}

///|
/// Convert the heap to an array.
pub fn[T] Heap::to_array(h : Heap[T]) -> Array[T] {
  h.data.val.copy()
}
