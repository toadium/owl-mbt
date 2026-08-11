///|
/// Reset adjoints in reverse mode.
/// Traverses the computation graph and zeros out all adjoint values.
pub fn reverse_reset(x : T) -> Unit raise {
  let stack = [x]
  while stack.length() > 0 {
    let node = stack.remove(stack.length() - 1)
    match node {
      DR(_, aa, op, af, _, tracker) => {
        aa.val = reset_zero(aa.val)
        af.val += 1
        tracker.val += 1
        if af.val == 1 && tracker.val == 1 {
          let parents = (op.register)([])
          for p in parents {
            stack.push(p)
          }
        }
      }
      _ => continue
    }
  }
}

///|
/// Push gradient in reverse mode.
/// Propagates the gradient v through the computation graph starting from x.
pub fn reverse_push(v : T, x : T) -> Unit raise {
  let stack : Array[(T, T)] = [(v, x)]
  while stack.length() > 0 {
    let (v, node) = stack.remove(stack.length() - 1)
    match node {
      DR(cp, aa, op, af, _, tracker) => {
        aa.val = add(aa.val, v)
        af.val -= 1
        if af.val == 0 && tracker.val == 1 {
          let new_pairs = (op.adjoint)(cp, aa, [])
          for pair in new_pairs {
            stack.push(pair)
          }
        } else {
          tracker.val -= 1
        }
      }
      _ => continue
    }
  }
}

///|
/// Reverse propagation: reset then push.
pub fn reverse_prop(v : T, x : T) -> Unit raise {
  reverse_reset(x)
  reverse_push(v, x)
}
