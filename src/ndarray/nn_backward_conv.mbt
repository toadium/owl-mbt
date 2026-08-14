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
                          (kernel_rows * kernel_dpts * in_channel * out_channel) +
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
