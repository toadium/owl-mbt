///|
/// Apply a permutation to an index array.
fn _apply_perm(arr : Array[Int], perm : Array[Int]) -> Array[Int] {
  Array::makei(arr.length(), fn(i) { arr[perm[i]] })
}

///|
/// Transpose with explicit axis permutation.
fn _transpose_axis(x : Ndarray, perm : Array[Int]) -> Ndarray {
  let n = x.shape.length()
  let new_shape = Array::makei(n, fn(i) { x.shape[perm[i]] })
  let old_strides = calc_strides(x.shape)
  let new_strides = calc_strides(new_shape)
  let total = _numel_shape(x.shape)
  let data = FixedArray::make(total, 0.0)
  let old_idx = Array::make(n, 0)
  let mut should_stop = false
  while !should_stop {
    let new_idx = _apply_perm(old_idx, perm)
    let old_flat = flat_index(old_idx, old_strides)
    let new_flat = flat_index(new_idx, new_strides)
    data[new_flat] = x.data[old_flat]
    if !next_index(old_idx, x.shape) {
      should_stop = true
    }
  }
  { shape: new_shape, data }
}

///|
/// conv2d backward input (gradient w.r.t. input).
/// Used by transpose_conv2d.
pub fn conv2d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let in_channel = input_shp[3]
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let out_channel = kernel_shp[3]
  let output_shp = output_grad.shape
  let output_cols = output_shp[1]
  let output_rows = output_shp[2]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, _, _) = _calc_conv2d_padding(
    input_cols, input_rows, kernel_cols, kernel_rows, output_cols, output_rows, row_stride,
    col_stride,
  )
  for b in 0..<batches {
    for in_i in 0..<input_cols {
      for in_j in 0..<input_rows {
        for q in 0..<in_channel {
          let mut sum = 0.0
          for di in 0..<kernel_cols {
            for dj in 0..<kernel_rows {
              let rem_col = in_i + pad_left - di
              let rem_row = in_j + pad_top - dj
              if rem_col % col_stride == 0 && rem_row % row_stride == 0 {
                let out_col = rem_col / col_stride
                let out_row = rem_row / row_stride
                if out_col >= 0 &&
                  out_col < output_cols &&
                  out_row >= 0 &&
                  out_row < output_rows {
                  for k in 0..<out_channel {
                    let out_grad_idx = b *
                      (output_cols * output_rows * out_channel) +
                      out_col * (output_rows * out_channel) +
                      out_row * out_channel +
                      k
                    let k_idx = di * (kernel_rows * in_channel * out_channel) +
                      dj * (in_channel * out_channel) +
                      q * out_channel +
                      k
                    sum += output_grad.data[out_grad_idx] * kernel.data[k_idx]
                  }
                }
              }
            }
          }
          let in_idx = b * (input_cols * input_rows * in_channel) +
            in_i * (input_rows * in_channel) +
            in_j * in_channel +
            q
          in_grad[in_idx] = sum
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// conv2d backward kernel (gradient w.r.t. kernel).
pub fn conv2d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let in_channel = input_shp[3]
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let out_channel = kernel_shp[3]
  let output_shp = output_grad.shape
  let output_cols = output_shp[1]
  let output_rows = output_shp[2]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let k_grad = FixedArray::make(kernel.data.length(), 0.0)
  let (pad_top, pad_left, _, _) = _calc_conv2d_padding(
    input_cols, input_rows, kernel_cols, kernel_rows, output_cols, output_rows, row_stride,
    col_stride,
  )
  for b in 0..<batches {
    for di in 0..<kernel_cols {
      for dj in 0..<kernel_rows {
        for q in 0..<in_channel {
          for k in 0..<out_channel {
            let mut sum = 0.0
            for i in 0..<output_cols {
              for j in 0..<output_rows {
                let in_col = i * col_stride + di - pad_left
                let in_row = j * row_stride + dj - pad_top
                if in_col >= 0 &&
                  in_col < input_cols &&
                  in_row >= 0 &&
                  in_row < input_rows {
                  let in_idx = b * (input_cols * input_rows * in_channel) +
                    in_col * (input_rows * in_channel) +
                    in_row * in_channel +
                    q
                  let out_grad_idx = b *
                    (output_cols * output_rows * out_channel) +
                    i * (output_rows * out_channel) +
                    j * out_channel +
                    k
                  sum += input.data[in_idx] * output_grad.data[out_grad_idx]
                }
              }
            }
            let k_idx = di * (kernel_rows * in_channel * out_channel) +
              dj * (in_channel * out_channel) +
              q * out_channel +
              k
            k_grad[k_idx] += sum
          }
        }
      }
    }
  }
  { shape: kernel_shp.copy(), data: k_grad }
}

///|
/// 2D transpose convolution.
pub fn transpose_conv2d(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let out_channel = kernel_shp[3]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let (output_cols, output_rows) = _calc_transpose_conv2d_output_shape(
    padding, input_cols, input_rows, kernel_cols, kernel_rows, row_stride, col_stride,
  )
  let output_placeholder = zeros([
    batches, output_cols, output_rows, out_channel,
  ])
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 3, 2])
  conv2d_backward_input(output_placeholder, transposed_kernel, stride, input)
}

///|
/// 1D transpose convolution (via reshape to 2D).
pub fn transpose_conv1d(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let out_channel = kernel_shp[2]
  let kernel_4d = reshape(kernel, [1, kernel_cols, in_channel, out_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output = transpose_conv2d(input_4d, kernel_4d, stride_2d, padding~)
  let output_shp = output.shape
  let output_cols = output_shp[2]
  reshape(output, [batches, output_cols, out_channel])
}

///|
/// conv3d backward input.
pub fn conv3d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let input_dpts = input_shp[3]
  let in_channel = input_shp[4]
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let kernel_dpts = kernel_shp[2]
  let out_channel = kernel_shp[4]
  let output_shp = output_grad.shape
  let output_cols = output_shp[1]
  let output_rows = output_shp[2]
  let output_dpts = output_shp[3]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let dpt_stride = stride[2]
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, pad_shallow, _, _, _) = _calc_conv3d_padding(
    input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts, output_cols,
    output_rows, output_dpts, row_stride, col_stride, dpt_stride,
  )
  for b in 0..<batches {
    for in_i in 0..<input_cols {
      for in_j in 0..<input_rows {
        for in_dpt in 0..<input_dpts {
          for q in 0..<in_channel {
            let mut sum = 0.0
            for di in 0..<kernel_cols {
              for dj in 0..<kernel_rows {
                for d_dpt in 0..<kernel_dpts {
                  let rem_col = in_i + pad_left - di
                  let rem_row = in_j + pad_top - dj
                  let rem_dpt = in_dpt + pad_shallow - d_dpt
                  if rem_col % col_stride == 0 &&
                    rem_row % row_stride == 0 &&
                    rem_dpt % dpt_stride == 0 {
                    let out_col = rem_col / col_stride
                    let out_row = rem_row / row_stride
                    let out_dpt = rem_dpt / dpt_stride
                    if out_col >= 0 &&
                      out_col < output_cols &&
                      out_row >= 0 &&
                      out_row < output_rows &&
                      out_dpt >= 0 &&
                      out_dpt < output_dpts {
                      for k in 0..<out_channel {
                        let out_grad_idx = b *
                          (
                            output_cols *
                            output_rows *
                            output_dpts *
                            out_channel
                          ) +
                          out_col * (output_rows * output_dpts * out_channel) +
                          out_row * (output_dpts * out_channel) +
                          out_dpt * out_channel +
                          k
                        let k_idx = di *
                          (
                            kernel_rows *
                            kernel_dpts *
                            in_channel *
                            out_channel
                          ) +
                          dj * (kernel_dpts * in_channel * out_channel) +
                          d_dpt * (in_channel * out_channel) +
                          q * out_channel +
                          k
                        sum += output_grad.data[out_grad_idx] *
                          kernel.data[k_idx]
                      }
                    }
                  }
                }
              }
            }
            let in_idx = b * (input_cols * input_rows * input_dpts * in_channel) +
              in_i * (input_rows * input_dpts * in_channel) +
              in_j * (input_dpts * in_channel) +
              in_dpt * in_channel +
              q
            in_grad[in_idx] = sum
          }
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// conv3d backward kernel.
pub fn conv3d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let input_dpts = input_shp[3]
  let in_channel = input_shp[4]
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let kernel_dpts = kernel_shp[2]
  let out_channel = kernel_shp[4]
  let output_shp = output_grad.shape
  let output_cols = output_shp[1]
  let output_rows = output_shp[2]
  let output_dpts = output_shp[3]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let dpt_stride = stride[2]
  let k_grad = FixedArray::make(kernel.data.length(), 0.0)
  let (pad_top, pad_left, pad_shallow, _, _, _) = _calc_conv3d_padding(
    input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts, output_cols,
    output_rows, output_dpts, row_stride, col_stride, dpt_stride,
  )
  for b in 0..<batches {
    for di in 0..<kernel_cols {
      for dj in 0..<kernel_rows {
        for d_dpt in 0..<kernel_dpts {
          for q in 0..<in_channel {
            for k in 0..<out_channel {
              let mut sum = 0.0
              for i in 0..<output_cols {
                for j in 0..<output_rows {
                  for dpt in 0..<output_dpts {
                    let in_col = i * col_stride + di - pad_left
                    let in_row = j * row_stride + dj - pad_top
                    let in_dpt = dpt * dpt_stride + d_dpt - pad_shallow
                    if in_col >= 0 &&
                      in_col < input_cols &&
                      in_row >= 0 &&
                      in_row < input_rows &&
                      in_dpt >= 0 &&
                      in_dpt < input_dpts {
                      let in_idx = b *
                        (input_cols * input_rows * input_dpts * in_channel) +
                        in_col * (input_rows * input_dpts * in_channel) +
                        in_row * (input_dpts * in_channel) +
                        in_dpt * in_channel +
                        q
                      let out_grad_idx = b *
                        (output_cols * output_rows * output_dpts * out_channel) +
                        i * (output_rows * output_dpts * out_channel) +
                        j * (output_dpts * out_channel) +
                        dpt * out_channel +
                        k
                      sum += input.data[in_idx] * output_grad.data[out_grad_idx]
                    }
                  }
                }
              }
              let k_idx = di *
                (kernel_rows * kernel_dpts * in_channel * out_channel) +
                dj * (kernel_dpts * in_channel * out_channel) +
                d_dpt * (in_channel * out_channel) +
                q * out_channel +
                k
              k_grad[k_idx] += sum
            }
          }
        }
      }
    }
  }
  { shape: kernel_shp.copy(), data: k_grad }
}

///|
/// 3D transpose convolution.
#warnings("-unused_error_type")
pub fn transpose_conv3d(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let input_dpts = input_shp[3]
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let kernel_dpts = kernel_shp[2]
  let out_channel = kernel_shp[4]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let dpt_stride = stride[2]
  let (output_cols, output_rows, output_dpts) = _calc_conv3d_output_shape(
    padding, input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts,
    row_stride, col_stride, dpt_stride,
  )
  let output_placeholder = zeros([
    batches, output_cols, output_rows, output_dpts, out_channel,
  ])
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 2, 4, 3])
  conv3d_backward_input(output_placeholder, transposed_kernel, stride, input)
}

///|
/// 1D convolution backward input.
pub fn conv1d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let out_channel = kernel_shp[2]
  let kernel_4d = reshape(kernel, [1, kernel_cols, in_channel, out_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    out_channel,
  ])
  let result = conv2d_backward_input(
    input_4d, kernel_4d, stride_2d, output_grad_4d,
  )
  reshape(result, [batches, input_cols, in_channel])
}

///|
/// 1D convolution backward kernel.
pub fn conv1d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let out_channel = kernel_shp[2]
  let kernel_4d = reshape(kernel, [1, kernel_cols, in_channel, out_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    out_channel,
  ])
  let result = conv2d_backward_kernel(
    input_4d, kernel_4d, stride_2d, output_grad_4d,
  )
  reshape(result, [kernel_cols, in_channel, out_channel])
}

///|
/// Max pool 2d backward.
/// Note: parameter order differs from the forward `max_pool2d` — `padding`
/// is the first parameter here (required) vs the last parameter in the forward
/// (optional). This is faithfully ported from the OCaml source.
pub fn max_pool2d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let in_channel = input_shp[3]
  let kernel_cols = kernel[0]
  let kernel_rows = kernel[1]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let (output_cols, output_rows) = _calc_conv2d_output_shape(
    padding, input_cols, input_rows, kernel_cols, kernel_rows, row_stride, col_stride,
  )
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, _, _) = _calc_conv2d_padding(
    input_cols, input_rows, kernel_cols, kernel_rows, output_cols, output_rows, row_stride,
    col_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for k in 0..<in_channel {
          let mut max_val = -1.7976931348623157e308
          let mut max_in_col = -1
          let mut max_in_row = -1
          for di in 0..<kernel_cols {
            for dj in 0..<kernel_rows {
              let in_col = i * col_stride + di - pad_left
              let in_row = j * row_stride + dj - pad_top
              if in_col >= 0 &&
                in_col < input_cols &&
                in_row >= 0 &&
                in_row < input_rows {
                let in_idx = b * (input_cols * input_rows * in_channel) +
                  in_col * (input_rows * in_channel) +
                  in_row * in_channel +
                  k
                if input.data[in_idx] > max_val {
                  max_val = input.data[in_idx]
                  max_in_col = in_col
                  max_in_row = in_row
                }
              }
            }
          }
          if max_in_col >= 0 {
            let out_grad_idx = b * (output_cols * output_rows * in_channel) +
              i * (output_rows * in_channel) +
              j * in_channel +
              k
            let in_idx = b * (input_cols * input_rows * in_channel) +
              max_in_col * (input_rows * in_channel) +
              max_in_row * in_channel +
              k
            in_grad[in_idx] += output_grad.data[out_grad_idx]
          }
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// Max pool 1d backward.
pub fn max_pool1d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_cols = kernel[0]
  let kernel_2d = [1, kernel_cols]
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    in_channel,
  ])
  let result = max_pool2d_backward(
    padding, input_4d, kernel_2d, stride_2d, output_grad_4d,
  )
  reshape(result, [batches, input_cols, in_channel])
}

///|
/// Max pool 3d backward.
pub fn max_pool3d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let input_dpts = input_shp[3]
  let in_channel = input_shp[4]
  let kernel_cols = kernel[0]
  let kernel_rows = kernel[1]
  let kernel_dpts = kernel[2]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let dpt_stride = stride[2]
  let (output_cols, output_rows, output_dpts) = _calc_conv3d_output_shape(
    padding, input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts,
    row_stride, col_stride, dpt_stride,
  )
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, pad_shallow, _, _, _) = _calc_conv3d_padding(
    input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts, output_cols,
    output_rows, output_dpts, row_stride, col_stride, dpt_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for dpt in 0..<output_dpts {
          for k in 0..<in_channel {
            let mut max_val = -1.7976931348623157e308
            let mut max_idx = -1
            for di in 0..<kernel_cols {
              for dj in 0..<kernel_rows {
                for d_dpt in 0..<kernel_dpts {
                  let in_col = i * col_stride + di - pad_left
                  let in_row = j * row_stride + dj - pad_top
                  let in_dpt = dpt * dpt_stride + d_dpt - pad_shallow
                  if in_col >= 0 &&
                    in_col < input_cols &&
                    in_row >= 0 &&
                    in_row < input_rows &&
                    in_dpt >= 0 &&
                    in_dpt < input_dpts {
                    let in_idx = b *
                      (input_cols * input_rows * input_dpts * in_channel) +
                      in_col * (input_rows * input_dpts * in_channel) +
                      in_row * (input_dpts * in_channel) +
                      in_dpt * in_channel +
                      k
                    if input.data[in_idx] > max_val {
                      max_val = input.data[in_idx]
                      max_idx = in_idx
                    }
                  }
                }
              }
            }
            if max_idx >= 0 {
              let out_grad_idx = b *
                (output_cols * output_rows * output_dpts * in_channel) +
                i * (output_rows * output_dpts * in_channel) +
                j * (output_dpts * in_channel) +
                dpt * in_channel +
                k
              in_grad[max_idx] += output_grad.data[out_grad_idx]
            }
          }
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// Avg pool 2d backward.
pub fn avg_pool2d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let in_channel = input_shp[3]
  let kernel_cols = kernel[0]
  let kernel_rows = kernel[1]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let (output_cols, output_rows) = _calc_conv2d_output_shape(
    padding, input_cols, input_rows, kernel_cols, kernel_rows, row_stride, col_stride,
  )
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, _, _) = _calc_conv2d_padding(
    input_cols, input_rows, kernel_cols, kernel_rows, output_cols, output_rows, row_stride,
    col_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for k in 0..<in_channel {
          let mut cnt = 0
          for di in 0..<kernel_cols {
            for dj in 0..<kernel_rows {
              let in_col = i * col_stride + di - pad_left
              let in_row = j * row_stride + dj - pad_top
              if in_col >= 0 &&
                in_col < input_cols &&
                in_row >= 0 &&
                in_row < input_rows {
                cnt += 1
              }
            }
          }
          let grad_per = if cnt > 0 {
            let out_grad_idx = b * (output_cols * output_rows * in_channel) +
              i * (output_rows * in_channel) +
              j * in_channel +
              k
            output_grad.data[out_grad_idx] / cnt.to_double()
          } else {
            0.0
          }
          for di in 0..<kernel_cols {
            for dj in 0..<kernel_rows {
              let in_col = i * col_stride + di - pad_left
              let in_row = j * row_stride + dj - pad_top
              if in_col >= 0 &&
                in_col < input_cols &&
                in_row >= 0 &&
                in_row < input_rows {
                let in_idx = b * (input_cols * input_rows * in_channel) +
                  in_col * (input_rows * in_channel) +
                  in_row * in_channel +
                  k
                in_grad[in_idx] += grad_per
              }
            }
          }
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// Avg pool 1d backward.
pub fn avg_pool1d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_cols = kernel[0]
  let kernel_2d = [1, kernel_cols]
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    in_channel,
  ])
  let result = avg_pool2d_backward(
    padding, input_4d, kernel_2d, stride_2d, output_grad_4d,
  )
  reshape(result, [batches, input_cols, in_channel])
}

///|
/// Avg pool 3d backward.
pub fn avg_pool3d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let input_dpts = input_shp[3]
  let in_channel = input_shp[4]
  let kernel_cols = kernel[0]
  let kernel_rows = kernel[1]
  let kernel_dpts = kernel[2]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let dpt_stride = stride[2]
  let (output_cols, output_rows, output_dpts) = _calc_conv3d_output_shape(
    padding, input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts,
    row_stride, col_stride, dpt_stride,
  )
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, pad_shallow, _, _, _) = _calc_conv3d_padding(
    input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts, output_cols,
    output_rows, output_dpts, row_stride, col_stride, dpt_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for dpt in 0..<output_dpts {
          for k in 0..<in_channel {
            let mut cnt = 0
            for di in 0..<kernel_cols {
              for dj in 0..<kernel_rows {
                for d_dpt in 0..<kernel_dpts {
                  let in_col = i * col_stride + di - pad_left
                  let in_row = j * row_stride + dj - pad_top
                  let in_dpt = dpt * dpt_stride + d_dpt - pad_shallow
                  if in_col >= 0 &&
                    in_col < input_cols &&
                    in_row >= 0 &&
                    in_row < input_rows &&
                    in_dpt >= 0 &&
                    in_dpt < input_dpts {
                    cnt += 1
                  }
                }
              }
            }
            let grad_per = if cnt > 0 {
              let out_grad_idx = b *
                (output_cols * output_rows * output_dpts * in_channel) +
                i * (output_rows * output_dpts * in_channel) +
                j * (output_dpts * in_channel) +
                dpt * in_channel +
                k
              output_grad.data[out_grad_idx] / cnt.to_double()
            } else {
              0.0
            }
            for di in 0..<kernel_cols {
              for dj in 0..<kernel_rows {
                for d_dpt in 0..<kernel_dpts {
                  let in_col = i * col_stride + di - pad_left
                  let in_row = j * row_stride + dj - pad_top
                  let in_dpt = dpt * dpt_stride + d_dpt - pad_shallow
                  if in_col >= 0 &&
                    in_col < input_cols &&
                    in_row >= 0 &&
                    in_row < input_rows &&
                    in_dpt >= 0 &&
                    in_dpt < input_dpts {
                    let in_idx = b *
                      (input_cols * input_rows * input_dpts * in_channel) +
                      in_col * (input_rows * input_dpts * in_channel) +
                      in_row * (input_dpts * in_channel) +
                      in_dpt * in_channel +
                      k
                    in_grad[in_idx] += grad_per
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// Upsampling 2d backward.
pub fn upsampling2d_backward(
  input : Ndarray,
  size : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let in_channel = input_shp[3]
  let col_scale = size[0]
  let row_scale = size[1]
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  for b in 0..<batches {
    for c in 0..<input_cols {
      for r in 0..<input_rows {
        for k in 0..<in_channel {
          let mut sum = 0.0
          for dc in 0..<col_scale {
            for dr in 0..<row_scale {
              let out_col = c * col_scale + dc
              let out_row = r * row_scale + dr
              let out_idx = b *
                (input_cols * col_scale * input_rows * row_scale * in_channel) +
                out_col * (input_rows * row_scale * in_channel) +
                out_row * in_channel +
                k
              sum += output_grad.data[out_idx]
            }
          }
          let in_idx = b * (input_cols * input_rows * in_channel) +
            c * (input_rows * in_channel) +
            r * in_channel +
            k
          in_grad[in_idx] = sum
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// Dilated conv1d backward input.
pub fn dilated_conv1d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let upsampled = _upsample_kernel2d(
    reshape(kernel, [1, kernel.shape[0], kernel.shape[1], kernel.shape[2]]),
    rate,
  )
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    output_grad.shape[2],
  ])
  let result = conv2d_backward_input(
    input_4d, upsampled, stride_2d, output_grad_4d,
  )
  reshape(result, [batches, input_cols, in_channel])
}

///|
/// Dilated conv1d backward kernel.
pub fn dilated_conv1d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let out_channel = kernel_shp[2]
  let kernel_4d = reshape(kernel, [1, kernel_cols, in_channel, out_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    out_channel,
  ])
  let grad_4d = conv2d_backward_kernel(
    input_4d, kernel_4d, stride_2d, output_grad_4d,
  )
  let downsampled = _downsample_kernel2d(grad_4d, rate)
  reshape(downsampled, [kernel_cols, in_channel, out_channel])
}

///|
/// Downsample a 2D kernel (inverse of upsample).
fn _downsample_kernel2d(kernel : Ndarray, rate : Array[Int]) -> Ndarray {
  if rate[0] == 1 && rate[1] == 1 {
    return kernel
  }
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let in_channel = kernel_shp[2]
  let out_channel = kernel_shp[3]
  let col_rate = rate[0]
  let row_rate = rate[1]
  let col_down = (kernel_cols + col_rate - 1) / col_rate
  let row_down = (kernel_rows + row_rate - 1) / row_rate
  let new_data = FixedArray::make(
    col_down * row_down * in_channel * out_channel,
    0.0,
  )
  for c in 0..<col_down {
    for r in 0..<row_down {
      for i in 0..<in_channel {
        for o in 0..<out_channel {
          let v = kernel.data[c *
            col_rate *
            (kernel_rows * in_channel * out_channel) +
            r * row_rate * (in_channel * out_channel) +
            i * out_channel +
            o]
          new_data[c * (row_down * in_channel * out_channel) +
          r * (in_channel * out_channel) +
          i * out_channel +
          o] = v
        }
      }
    }
  }
  { shape: [col_down, row_down, in_channel, out_channel], data: new_data }
}

///|
/// Dilated conv2d backward input.
#warnings("-unused_error_type")
pub fn dilated_conv2d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let upsampled = _upsample_kernel2d(kernel, rate)
  conv2d_backward_input(input, upsampled, stride, output_grad)
}

///|
/// Dilated conv2d backward kernel.
#warnings("-unused_error_type")
pub fn dilated_conv2d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let kernel_4d = kernel
  let grad = conv2d_backward_kernel(input, kernel_4d, stride, output_grad)
  _downsample_kernel2d(grad, rate)
}

///|
/// Downsample a 3D kernel.
fn _downsample_kernel3d(kernel : Ndarray, rate : Array[Int]) -> Ndarray {
  if rate[0] == 1 && rate[1] == 1 && rate[2] == 1 {
    return kernel
  }
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let kernel_dpts = kernel_shp[2]
  let in_channel = kernel_shp[3]
  let out_channel = kernel_shp[4]
  let col_rate = rate[0]
  let row_rate = rate[1]
  let dpt_rate = rate[2]
  let col_down = (kernel_cols + col_rate - 1) / col_rate
  let row_down = (kernel_rows + row_rate - 1) / row_rate
  let dpt_down = (kernel_dpts + dpt_rate - 1) / dpt_rate
  let total = col_down * row_down * dpt_down * in_channel * out_channel
  let new_data = FixedArray::make(total, 0.0)
  for c in 0..<col_down {
    for r in 0..<row_down {
      for d in 0..<dpt_down {
        for i in 0..<in_channel {
          for o in 0..<out_channel {
            let v = kernel.data[c *
              col_rate *
              (kernel_rows * kernel_dpts * in_channel * out_channel) +
              r * row_rate * (kernel_dpts * in_channel * out_channel) +
              d * dpt_rate * (in_channel * out_channel) +
              i * out_channel +
              o]
            new_data[c * (row_down * dpt_down * in_channel * out_channel) +
            r * (dpt_down * in_channel * out_channel) +
            d * (in_channel * out_channel) +
            i * out_channel +
            o] = v
          }
        }
      }
    }
  }
  {
    shape: [col_down, row_down, dpt_down, in_channel, out_channel],
    data: new_data,
  }
}

///|
/// Dilated conv3d backward input.
#warnings("-unused_error_type")
pub fn dilated_conv3d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let upsampled = _upsample_kernel3d(kernel, rate)
  conv3d_backward_input(input, upsampled, stride, output_grad)
}

///|
/// Dilated conv3d backward kernel.
#warnings("-unused_error_type")
pub fn dilated_conv3d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let grad = conv3d_backward_kernel(input, kernel, stride, output_grad)
  _downsample_kernel3d(grad, rate)
}

///|
/// Transpose conv1d backward input.
pub fn transpose_conv1d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let out_channel = kernel_shp[2]
  let kernel_4d = reshape(kernel, [1, kernel_cols, in_channel, out_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let transposed_kernel = _transpose_axis(kernel_4d, [0, 1, 3, 2])
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    out_channel,
  ])
  let result = conv2d_backward_kernel(
    input_4d, transposed_kernel, stride_2d, output_grad_4d,
  )
  reshape(result, [batches, input_cols, in_channel])
}

///|
/// Transpose conv1d backward kernel.
pub fn transpose_conv1d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let out_channel = kernel_shp[2]
  let kernel_4d = reshape(kernel, [1, kernel_cols, in_channel, out_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let transposed_kernel = _transpose_axis(kernel_4d, [0, 1, 3, 2])
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    out_channel,
  ])
  let result = conv2d_backward_input(
    output_grad_4d, transposed_kernel, stride_2d, input_4d,
  )
  reshape(result, [kernel_cols, in_channel, out_channel])
}

///|
/// Transpose conv2d backward input.
pub fn transpose_conv2d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 3, 2])
  conv2d_backward_kernel(input, transposed_kernel, stride, output_grad)
}

///|
/// Transpose conv2d backward kernel.
pub fn transpose_conv2d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 3, 2])
  conv2d_backward_input(output_grad, transposed_kernel, stride, input)
}

///|
/// Transpose conv3d backward input.
pub fn transpose_conv3d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 2, 4, 3])
  conv3d_backward_kernel(input, transposed_kernel, stride, output_grad)
}

///|
/// Transpose conv3d backward kernel.
pub fn transpose_conv3d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 2, 4, 3])
  conv3d_backward_input(output_grad, transposed_kernel, stride, input)
}
